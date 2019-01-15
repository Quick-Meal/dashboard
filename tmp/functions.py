import os
from glob import glob
import shutil
import datetime
import numpy as np
from skimage import io,transform

# time_1 - time_2
def caltime(time_1, time_2):
    date1=datetime.datetime(int(time_1[:4]),int(time_1[4:6]),int(time_1[6:]))
    date2=datetime.datetime(int(time_2[:4]),int(time_2[4:6]),int(time_2[6:]))
    return int((date1-date2).days)

#读取被分割后的文件
def read_img(data_dir,IMAGE_WIDTH,IMAGE_HIGH):
    imgs = []
    '''
    i=1
    for im in glob.glob(data_dir + '/*.*'):
        print(im)
        img = io.imread(im)
        img = transform.resize(img, (IMAGE_WIDTH,IMAGE_HIGH))
        imgs.append(img)
        i += 1
    '''
    for i in range(5):
        img = io.imread(data_dir+'/'+str(i+1)+'.bmp')
        img = transform.resize(img, (IMAGE_WIDTH,IMAGE_HIGH))
        imgs.append(img)
    return np.asarray(imgs)
    
# 静态框
def recover_boxes():
    true_boxes = []
    left = 0.07
    top = 0.1
    width = 0.17
    height = 0.8
    overlap = 0.02
    for i in range(5):
        true_boxes.append([top, left, height, left+width+2*overlap]) # ymin,xmin,ymax,xmax
        left += width
    return true_boxes

# 识别结果写入文本
def writetotext(data_path,result):
    textfilename = data_path + '.txt'
    with open(textfilename,'w') as f:
        for i in range(len(result)):
            f.write(result[i])
            
# 读取字典
def read_dict(filename):
    f = open(filename, 'r')
    dict_string = f.read()
    result = eval(dict_string)
    f.close()
    return result

# 写入字典
def write_dict(filename, dicts):
    f = open(filename, 'w')
    f.write(str(dicts))
    f.close()
    
# 将识别后的文件移到相应目录，以便收集数据继续学习
def movefiletotraining(data_dir,result,train_data_dir,train_data_index):
    if len(result)==0:
        return False
    #img_list = glob(data_dir + '/*.*')
    img_list = []
    for i in range(5):
        img_list.append(data_dir+'/'+str(i+1)+'.bmp')
    img_dict = read_dict(train_data_index)
    
    for i in range(len(result)):
        if result[i] == '?':
            new_dir = train_data_dir+ '/NG/'+ str(img_dict['NG']) + '.bmp'
            try:
                shutil.copyfile(img_list[i], new_dir)
                img_dict['NG'] += 1
            except:
                print('移动失败-',i)
        else:
            new_dir = train_data_dir+ '/' + str(result[i]) +'/'+ str(img_dict[result[i]]) + '.bmp'
            try:
                shutil.copyfile(img_list[i], new_dir)
                img_dict[result[i]] += 1
            except:
                print('移动失败-',i)
    write_dict(train_data_index, img_dict)

#如果存放裁剪后的图片目录不存在，则创建
def create_train(data_dir):
    # 如果不存在
    if os.path.exists(data_dir) == False:
        print('->Creating ',data_dir,' ...')
        os.mkdir(data_dir)
        for i in range(10):
            os.mkdir(data_dir+'/'+str(int(i)))
        
        index_dict = {}
        index_dict['NG'] = int(0)
        for i in range(10):
            index_dict[str(int(i))] = int(0)
        f = open(data_dir+'/index_dict.txt', 'w')
        f.write(str(index_dict))
        f.close()
        print('->Creating Successfully')
    else:
        print('There exists ',data_dir)
#create_train('training3/')

def split_multi_image():
    print('loading graph ...')
    detecotr = TOD()#初始化类，加载网络模型，仅需1次
    print('load successfully!')

    img_dir = 'examples/'
    file_list = os.listdir(img_dir)
    img_list = []
    for item in file_list:
        if item[-4:] =='.bmp' or item[-4:] =='.jpg':
            img_list.append(item)

    batch_size = 100
    start = 0
    end = 0
    total_num = 101 #len(img_list)
    print(len(img_list))
    while(end<total_num):
        start = end
        end += batch_size
        if end > total_num:
            end = total_num
        print(start, end, end-start)
