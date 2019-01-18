
cmd:option('-style_image', 'examples/inputs/seated-nude.jpg', 'Style target image')
cmd:option('-content_image', 'examples/inputs/tubingen.jpg', 'Content target image')
cmd:option('-tmask_image', 'examples/inputs/t_mask.jpg', 'Content tight mask image')
cmd:option('-mask_image', 'examples/inputs/t_mask.jpg', 'Content loose mask image')
cmd:option('-image_size', 700, 'Maximum height / width of generated image')
cmd:option('-gpu', 0, 'Zero-indexed ID of the GPU to use; for CPU mode set -gpu = -1')

-- Optimization options
cmd:option('-content_weight', 5)
cmd:option('-style_weight', 100)
cmd:option('-tv_weight',   1e-3)
cmd:option('-num_iterations', 1000)
cmd:option('-normalize_gradients', false)
cmd:option('-init', 'image', 'random|image')
cmd:option('-optimizer', 'lbfgs', 'lbfgs|adam')
cmd:option('-learning_rate', 1e1)

-- Output options
cmd:option('-print_iter', 50)
cmd:option('-save_iter', 100)
cmd:option('-output_image', 'out.png')


-- Patchmatch
cmd:option('-patchmatch_size', 3)

local function main(params)
  cutorch.setDevice(params.gpu + 1)
  cutorch.setHeapTracking(true)

  torch.manualSeed(params.seed)

  idx = cutorch.getDevice()
  print('gpu, idx = ', params.gpu, idx)

  local content_image = image.load(params.content_image, 3)
  content_image = image.scale(content_image, params.image_size, 'bilinear')
  local c, h, w = content_image:size(1), content_image:size(2), content_image:size(3)
  local content_image_caffe = preprocess(content_image):float():cuda()
  local content_layers = params.content_layers:split(",")
  
  local style_image = image.load(params.style_image, 3)
  style_image = image.scale(style_image, w, h, 'bilinear')
  local style_image_caffe = preprocess(style_image):float():cuda()
  local style_layers = params.style_layers:split(",")

  -- Loose mask 
  local mask_image     = image.load(params.mask_image, 3)[1]
  mask_image           = image.scale(mask_image, params.image_size, 'bilinear'):float()
  local mask_image_ori = mask_image:clone()

  -- Tight mask
  local tmask_image     = image.load(params.tmask_image, 3)
  tmask_image           = image.scale(tmask_image, params.image_size, 'bilinear'):float()
  local tmask_image_ori = tmask_image:clone()

  local tr      = 3;
  local tkernel = image.gaussian(2*tr+1, tr, 1, true)
  tmask_image   = image.convolve(tmask_image, tkernel, 'same')
  
  -- Set up the network, inserting style and content loss modules
  local content_losses, style_losses = {}, {}
  local next_content_idx, next_style_idx = 1, 1
  local net = nn.Sequential()
  
  if params.tv_weight > 0 then
    local tv_mod = nn.TVLoss(params.tv_weight):float():cuda()
    net:add(tv_mod)
  end

  -- load VGG-19 network
  local cnn = loadcaffe.load(params.proto_file, params.model_file, params.backend):float():cuda()

  for i = 1, cnn:size() do
    if next_content_idx <= #content_layers or next_style_idx <= #style_layers then
      local layer = cnn:get(i)
      local name = layer.name
      local layer_type = torch.type(layer)
      local is_pooling = (layer_type == 'cudnn.SpatialMaxPooling' or layer_type == 'nn.SpatialMaxPooling')
      local is_conv    = (layer_type == 'nn.SpatialConvolution' or layer_type == 'cudnn.SpatialConvolution')
      
      net:add(layer)

      if is_pooling then
        mask_image = image.scale(mask_image, math.ceil(mask_image:size(2)/2), math.ceil(mask_image:size(1)/2))
      elseif is_conv then
        local sap = nn.SpatialAveragePooling(3,3,1,1,1,1):float()
        mask_image = sap:forward(mask_image:repeatTensor(1,1,1))[1]:clone()
      end

      if name == content_layers[next_content_idx] then
        print("Setting up content layer", i, ":", layer.name)
        local input = net:forward(content_image_caffe):clone()
        local norm = params.normalize_gradients
        local loss_module = nn.ContentLoss(params.content_weight, input, norm, mask_image):float():cuda()
        net:add(loss_module)
        table.insert(content_losses, loss_module)
        next_content_idx = next_content_idx + 1
      end
      if name == style_layers[next_style_idx] then
        print("Setting up style layer  ", i, ":", layer.name)
        local gram   = GramMatrix():float():cuda()
        local input  = net:forward(content_image_caffe):clone()
        local target = net:forward(style_image_caffe):clone()
        local mask   = mask_image:clone():repeatTensor(1,1,1):expandAs(target):cuda()

        local match, correspondence = 
            cuda_utils.patchmatch_r(input, target, params.patchmatch_size, 1)
        match:cmul(mask)
        local target_gram = gram:forward(match):clone()
        target_gram:div(mask:sum())

        local norm = params.normalize_gradients
        local loss_module = nn.StyleLoss(params.style_weight, target_gram, norm, mask_image):float():cuda()
        net:add(loss_module)
        table.insert(style_losses, loss_module)
        next_style_idx = next_style_idx + 1
      end
    end
  end

  -- We don't need the base CNN anymore, so clean it up to save memory.
  cnn = nil
  for i=1,#net.modules do
    local module = net.modules[i]
    if torch.type(module) == 'nn.SpatialConvolutionMM' then
        -- remove these, not used, but uses gpu memory
        module.gradWeight = nil
        module.gradBias = nil
    end
  end
  collectgarbage()
  
  -- Initialize the image
  if params.seed >= 0 then
    torch.manualSeed(params.seed)
  end
  local img = nil
  if params.init == 'random' then
    img = torch.randn(content_image:size()):float():cuda():mul(0.001)
  elseif params.init == 'image' then
    img = content_image_caffe:clone():float():cuda()
  else
    error('Invalid init type')
  end
   
  
  -- Run it through the network once to get the proper size for the gradient
  -- All the gradients will come from the extra loss modules, so we just pass
  -- zeros into the top of the net on the backward pass.
  local y = net:forward(img)
  local dy = img.new(#y):zero()

  -- Declaring this here lets us access it in maybe_print
  local optim_state = nil
  if params.optimizer == 'lbfgs' then
    optim_state = {
      maxIter = params.num_iterations,
      verbose=true,
    }
  elseif params.optimizer == 'adam' then
    optim_state = {
      learningRate = params.learning_rate,
    }
  else
    error(string.format('Unrecognized optimizer "%s"', params.optimizer))
  end

  local function maybe_print(t, loss)
    local verbose = (params.print_iter > 0 and t % params.print_iter == 0)
    if verbose then
      print(string.format('Iteration %d / %d', t, params.num_iterations))
      for i, loss_module in ipairs(content_losses) do
        print(string.format('  Content %d loss: %f', i, loss_module.loss))
      end
      for i, loss_module in ipairs(style_losses) do
        print(string.format('  Style %d loss: %f', i, loss_module.loss))
      end
      print(string.format('  Total loss: %f', loss))
    end
  end

  local function maybe_save(t)
    local should_save = params.save_iter > 0 and t % params.save_iter == 0
    should_save = should_save or t == params.num_iterations
    if should_save then
      -- local disp = deprocess(img:double())
      local disp = torch.cmul(img:double(), tmask_image:double())
      disp:add(torch.cmul(style_image_caffe:double(), 1.0 - tmask_image:double()))
      disp = deprocess(disp)
      disp = image.minmax{tensor=disp, min=0, max=1}

      local filename = build_filename(params.output_image, t)
      if t == params.num_iterations then
        filename = params.output_image
      end

      -- Maybe perform postprocessing for color-independent style transfer
      if params.original_colors == 1 then
        disp = original_colors(content_image, disp)
      end

      image.save(filename, disp)
    end
  end

  -- Function to evaluate loss and gradient. We run the net forward and
  -- backward to get the gradient, and sum up losses from the loss modules.
  -- optim.lbfgs internally handles iteration and calls this fucntion many
  -- times, so we manually count the number of iterations to handle printing
  -- and saving intermediate results.
  local num_calls = 0
  local function feval(x)
    num_calls = num_calls + 1
    net:forward(x)
    local grad = net:updateGradInput(x, dy)
    
    local msk = mask_image_ori:clone()
    msk = msk:repeatTensor(1,1,1):expandAs(x):cuda()
    grad:cmul(msk)

    local loss = 0
    for _, mod in ipairs(content_losses) do
      loss = loss + mod.loss
    end
    for _, mod in ipairs(style_losses) do
      loss = loss + mod.loss
    end
    maybe_print(num_calls, loss)
    maybe_save(num_calls)

    collectgarbage()
    -- optim.lbfgs expects a vector for gradients
    return loss, grad:view(grad:nElement())
  end

  -- Run optimization.
  if params.optimizer == 'lbfgs' then
    print('Running optimization with L-BFGS')
    local x, losses = optim.lbfgs(feval, img, optim_state)
  elseif params.optimizer == 'adam' then
    print('Running optimization with ADAM')
    for t = 1, params.num_iterations do
      local x, losses = optim.adam(feval, img, optim_state)
    end
  end
end

function build_filename(output_image, iteration)
  local ext = paths.extname(output_image)
  local basename = paths.basename(output_image, ext)
  local directory = paths.dirname(output_image)
  return string.format('%s/%s_%d.%s',directory, basename, iteration, ext)
end

-- Preprocess an image before passing it to a Caffe model.
-- We need to rescale from [0, 1] to [0, 255], convert from RGB to BGR,
-- and subtract the mean pixel.
function preprocess(img)
  local mean_pixel = torch.DoubleTensor({103.939, 116.779, 123.68})
  local perm = torch.LongTensor{3, 2, 1}
  img = img:index(1, perm):mul(256.0)
  mean_pixel = mean_pixel:view(3, 1, 1):expandAs(img)
  img:add(-1, mean_pixel)
  return img
end


-- Undo the above preprocessing.
function deprocess(img)
  local mean_pixel = torch.DoubleTensor({103.939, 116.779, 123.68})
  mean_pixel = mean_pixel:view(3, 1, 1):expandAs(img)
  img = img + mean_pixel
  local perm = torch.LongTensor{3, 2, 1}
  img = img:index(1, perm):div(256.0)
  return img
end


-- Combine the Y channel of the generated image and the UV channels of the
-- content image to perform color-independent style transfer.