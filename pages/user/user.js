// pages/user/user.js
//获取应用实例
var util = require('../../utils/util.js');
var app = getApp();
Page({
  data: {
    userInfo: {},
    timeCounter: null,
    postList: app.globalData.local_database,
    if_order: false,
    if_history_order:false,
    total_price: 0,
    time: null,
    time_reset_flag: false
  },

  calculate_sun: function () {
    var sum = 0;
    for (var x in app.globalData.local_database) {
      sum += app.globalData.local_database[x].price * 1.0 * app.globalData.local_database[x].num * 1.0
    }
    return sum;
  },

  if_order_exits: function () {
    if (app.globalData.local_database.length < 1) {
      return false;
    }
    else{
      return true;
    }
  },

  onLoad: function (options) {
    // 页面初始化 options为页面跳转所带来的参数
    var that = this
    //调用应用实例的方法获取全局数据
    that.countDown(1800);
    var time = util.formatTime(new Date());
    that.setData({
      userInfo: app.globalData.userInfo,
      total_price: that.calculate_sun(),
      if_order: that.if_order_exits(),
      if_history_order: false,
      time: time
    })
  },

  onShow: function () {
    this.setData({
      userInfo: app.globalData.userInfo,
      postList: app.globalData.local_database,
      total_price: this.calculate_sun(),
      if_order: this.if_order_exits(),
      if_history_order: false,
      time: util.formatTime(new Date())
    })

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
      if_order: that.if_order_exits()
    });
    if (total <= 0) {
      that.setData({
        timeCounter: "已经截止",
        total_price: that.calculate_sun(),
        if_order: that.if_order_exits()
      });
      return;
    }
    setTimeout(function () {
      total--;
      that.countDown(total);
    }, 1000)
  },
  payBtn:function(){
    wx.navigateTo({
      url: '/pages/nopay/nopay'
    })
  }
})