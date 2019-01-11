//index.js
//获取应用实例
var app = getApp()

var cart_list = [];
Page({
  data: {
    status: 0,
    currentPosition: "order0",
    imgUrls: [
      "/images/1.jpg",
      "/images/1.jpg",
      "/images/1.jpg"
    ]
  },
  changeMenu: function (e) {
    var index = e.currentTarget.dataset.index;
    this.setData({
      status: index,
      currentPosition: "order" + index
    })
  },
  scrollBottom: function () {
    wx.showLoading({
      title: '加载中...',
      mask:true
    })
    setTimeout(function(){
      wx.hideLoading();
    },1000)
  },

  AddToCart: function (event) {
    wx.showToast({
      title: '购物车+1',
      icon: 'succes',
      duration: 500,
      mask: true
    })
    var foodname = event.currentTarget.dataset.foodname;
    var picsource = event.currentTarget.dataset.picsource;
    var price = event.currentTarget.dataset.price;
    var num = 1;
    var flag = 0;
    for (var x in cart_list)
    {
      if (cart_list[x][0] == foodname) { 
        cart_list[x][3]+=1;
        flag = 1;
      }
    }
    if(flag==0){
      cart_list.push([foodname, picsource, price, num])
    }
    for (var i in cart_list) {
      console.log(i + "-----" + cart_list[i]);
    }
    

  },



  previewImages: function () {
    wx.previewImage({
      current: 'http://p1.meituan.net/460.280/deal/5cae86dd953bc50457aea6219e85287d79414.jpg@460w_280h_1e_1c',
      urls: [
        'http://p1.meituan.net/460.280/deal/5cae86dd953bc50457aea6219e85287d79414.jpg@460w_280h_1e_1c',
        'http://p1.meituan.net/460.280/deal/5cae86dd953bc50457aea6219e85287d79414.jpg@460w_280h_1e_1c',
        'http://p1.meituan.net/460.280/deal/5cae86dd953bc50457aea6219e85287d79414.jpg@460w_280h_1e_1c',
        'http://p1.meituan.net/460.280/deal/5cae86dd953bc50457aea6219e85287d79414.jpg@460w_280h_1e_1c'
      ],
    })
  }
})
