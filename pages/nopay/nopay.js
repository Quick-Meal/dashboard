// pages/nopay/nopay.js
var app = getApp()

Page({
  data: {
    timeCounter: null,
    postList: app.globalData.local_database,
    total_price: 0,
    random_num:0,
    showModalStatus: false ,
    Length: 6,    //输入框个数 
    isFocus: true,  //聚焦 
    Value: "",    //输入的内容 
    ispassword: true, //是否密文显示 true为密文， false为明文。
  },

  Focus(e) {
    var that = this;
    console.log(e.detail.value);
    var inputValue = e.detail.value;
    that.setData({
      Value: inputValue,
    })
  },
  Tap() {
    var that = this;
    that.setData({
      isFocus: true,
    })
  },
  formSubmit(e) {
    console.log(e.detail.value.password);
  }, 
  powerDrawer: function (e) {
    var currentStatu = e.currentTarget.dataset.statu;
    this.util(currentStatu)
  },
  util: function (currentStatu) {
    /* 动画部分 */
    // 第1步：创建动画实例   
    var animation = wx.createAnimation({
      duration: 200,  //动画时长  
      timingFunction: "linear", //线性  
      delay: 0  //0则不延迟  
    });

    // 第2步：这个动画实例赋给当前的动画实例  
    this.animation = animation;

    // 第3步：执行第一组动画  
    animation.opacity(0).rotateX(-100).step();

    // 第4步：导出动画对象赋给数据对象储存  
    this.setData({
      animationData: animation.export()
    })

    // 第5步：设置定时器到指定时候后，执行第二组动画  
    setTimeout(function () {
      // 执行第二组动画  
      animation.opacity(1).rotateX(0).step();
      // 给数据对象储存的第一组动画，更替为执行完第二组动画的动画对象  
      this.setData({
        animationData: animation
      })

      //关闭  
      if (currentStatu == "close") {
        this.setData(
          {
            showModalStatus: false
          }
        );
      }
    }.bind(this), 200)

    // 显示  
    if (currentStatu == "open") {
      this.setData(
        {
          showModalStatus: true
        }
      );
    }
  } ,

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
