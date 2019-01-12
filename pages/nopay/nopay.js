// pages/nopay/nopay.js
var app = getApp()

Page({
  data: {
    timeCounter: null,
    postList: app.globalData.local_database,
    total_price: 0,
    random_num:0
  },

  goto_logs: function () {
    var random = Math.floor(Math.random() * (99999999 - 10000000 + 1) + 10000000);
    this.setData({
      random_num: random
    })

  },


  calculate_sun: function () {
    var sum = 0;
    for (var x in app.globalData.local_database) {
      sum += app.globalData.local_database[x].price * 1.0 * app.globalData.local_database[x].num * 1.0
    }
    return sum;
  },

  

  onLoad:function(options){
    // 页面初始化 options为页面跳转所带来的参数
    var that = this
    //调用应用实例的方法获取全局数据
    that.countDown(300);
    that.goto_logs();
    that.setData({
      total_price: that.calculate_sun(),
    })
  },


  onReady:function(){
    // 页面渲染完成
  },


  onShow:function(){
    // 页面显示
  },

  onHide:function(){
    // 页面隐藏
  },

  onUnload:function(){
    // 页面关闭
  },

  formateTime: function (total) {
    var s = (total % 60) < 10 ? ('0' + total % 60) : total % 60;
    var h = total / 3600 < 10 ? ('0' + parseInt(total / 3600)) : parseInt(total / 3600);
    var m = (total - h * 3600) / 60 < 10 ? ('0' + parseInt((total - h * 3600) / 60)) : parseInt((total - h * 3600) / 60);
    return h + ' : ' + m + ' : ' + s;
  },

  countDown: function (total) {
    var that = this;
    that.setData({
      timeCounter: that.formateTime(total),
      total_price: that.calculate_sun(),
    });
    if (total <= 0) {
      that.setData({
        timeCounter: "已经截止",
        total_price: that.calculate_sun(),
      });
      return;
    }
    setTimeout(function () {
      total--;
      that.countDown(total);
    }, 1000)
  },

})