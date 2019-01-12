// pages/cart/cart.js
//var postData = require("../index/cart.js");
var app = getApp()


Page({
  data: {
    cartListShow: true,
    showModal: false,
    postList: app.globalData.local_database,
    total_price:0
  },

  calculate_sun: function () {
    var sum =0;
    for (var x in app.globalData.local_database) {
      sum += app.globalData.local_database[x].price * 1.0 * app.globalData.local_database[x].num*1.0 
    }
    return sum;
  },

  onLoad: function (options) {
    //this.setData({
    // postList: postData.postList
    //});

    if (app.globalData.local_database < 1) {
      this.setData({
        showModal: true,
        total_price: this.calculate_sun()
      });
    }
  },
  onShow: function () {
    var that = this;
    var carts = app.globalData.local_database;
    that.setData({
      postList: carts,
      total_price: that.calculate_sun()
    });
    if (app.globalData.local_database < 1) {
      this.setData({
        showModal: true,
        total_price: this.calculate_sun()
      });
    }
    else{
      this.setData({
        cartListShow: true,
        total_price: this.calculate_sun()
      });
    }
  },
  payBtn: function () {
    if (app.globalData.local_database.length < 1) {
      wx.showToast({
        title: '购物车为空',
        //icon: 'loading',
        duration: 1000,
        mask: true
      })
    }
    else{
      wx.navigateTo({
        url: '/pages/nopay/nopay'
      })
    }
    
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
              postList: carts,
              total_price: that.calculate_sun()
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
      postList: carts,
      total_price: that.calculate_sun()
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
      postList: carts,
      total_price: this.calculate_sun()
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
            postList: carts,
            total_price: that.calculate_sun()
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