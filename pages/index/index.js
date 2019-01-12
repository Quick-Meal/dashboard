//index.js
//获取应用实例
var app = getApp()




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
      mask: false
    })
    var foodname = event.currentTarget.dataset.foodname;
    var picsource = event.currentTarget.dataset.picsource;
    var price = event.currentTarget.dataset.price;
    var num = 1;
    var flag = 0;
    for (var x in app.globalData.local_database)
    {
      if (app.globalData.local_database[x].foodName == foodname) { 
        app.globalData.local_database[x].num+=1;
        flag = 1;
      }
    }
    if(flag==0){
      app.globalData.local_database.push({ foodName: foodname, imgSrc: picsource, price: price, num:num})
    }

    for (var x in app.globalData.local_database){
      console.log(app.globalData.local_database[x].foodName + app.globalData.local_database[x].num)
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
