// pages/cart/cart.js
//var postData = require("../index/cart.js");
var app = getApp()


Page({
  data: {
    cartListShow: true,
    showModal: false,
    postList: app.globalData.local_database
  },
  onLoad: function (options) {
    //this.setData({
    // postList: postData.postList
    //});
    if (app.globalData.local_database < 1) {
      this.setData({
        showModal: true
      });
    }
  },
  onShow: function () {
    var that = this;
    var carts = app.globalData.local_database;
    that.setData({
      postList: carts
    });
  },

  plus: function (e) {
    var that = this;
    var index = e.currentTarget.dataset.index;
    var num = app.globalData.local_database[index].num;
    if (num > 1) {
      num--;
    } else {
      wx.showModal({
        title: '',
        content: '是否删除此菜品?',
        success: function (res) {
          if (res.confirm) {
            carts.splice(index, 1);
            that.setData({
              postList: carts
            });
            if (app.globalData.local_database.length < 1) {
              that.setData({
                cartListShow: false,
                showModal: true
              });
            }
          } else if (res.cancel) {
            return;
          }
        }
      })
    }
    var carts = app.globalData.local_database;
    carts[index].num = num;
    that.setData({
      postList: carts
    });
    //app.globalData.local_database[index].num;
  },
  add: function (e) {
    var index = e.currentTarget.dataset.index;
    var num = app.globalData.local_database[index].num;
    num++;
    var carts = app.globalData.local_database;
    carts[index].num = num;
    this.setData({
      postList: carts
    });
  },
  delThisFood: function (e) {
    var that = this;
    var index = e.currentTarget.dataset.index;
    var carts = app.globalData.local_database;
    wx.showModal({
      title: '',
      content: '是否删除此菜品?',
      success: function (res) {
        if (res.confirm) {
          carts.splice(index, 1);
          that.setData({
            postList: carts
          });
          if (app.globalData.local_database.length < 1) {
            that.setData({
              cartListShow: false,
              showModal: true
            });
          }
        } else if (res.cancel) {
          return;
        }
      }
    })
  }
})