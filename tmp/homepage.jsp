<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>     
<%@page import="car.CarInfo"%>
<%@page import="java.util.Vector" %>
<%@page import="car.Site" %>
<%@page import="java.util.Random" %>
<% Vector<Site> site=CarInfo.getSiteList();
   Vector<CarInfo> info=CarInfo.getCarInfo();
   int curId=request.getParameter("curId")==null?0:Integer.parseInt(request.getParameter("curId"));
   Random random=new Random();
   String danger=new String();
   for(int i=0;i<5;++i){
	   if(info.get(i).getSpeed()>=90){
		  if(!danger.isEmpty())
			  danger+=",";
          danger+=i;
	   }
   }
   if(danger.isEmpty())
	   danger="无";
%>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8" />
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="icon" type="image/x-icon" href="img/favicon.jpg">
        <title>GPS Vehicle Monitoring System</title>
		<link rel="stylesheet" href="https://cdn.static.runoob.com/libs/bootstrap/3.3.7/css/bootstrap.min.css">  
        <script src="https://cdn.static.runoob.com/libs/jquery/2.1.1/jquery.min.js"></script>
        <script src="https://cdn.static.runoob.com/libs/bootstrap/3.3.7/js/bootstrap.min.js"></script>
        <script src="https://a.alipayobjects.com/g/datavis/g2/2.2.4/g2.js"></script>
        <meta http-equiv="X-UA-Compatible" content="chrome=1">
        <meta name="viewport" content="initial-scale=1.0, user-scalable=no, width=device-width">
        <style type="text/css">
        body,html,#containerss{
        height: 700px;
        margin: 0px;
        }
        </style>
	</head>
	
	
	<body>
		
		<!--网站头部-->

		<div class="contmodal-header" style="background:#563d7c;">
			<div class="container">
		
				<h2><a href="homepage.jsp"><strong style="color:#FFFFFF; font-size: 30px;"> GPS Vehicle Monitoring System </strong></a>
				
				<form class="navbar-form navbar-right" style="margin:0px;display:inline;" role="search" method="get" action="homepage.jsp">
					<div class="form-group">
						<input type="text" name="curId" class="form-control" placeholder="search all information ">
					</div>
					<button type="submit" class="btn btn-default" ><strong> Search </strong></button>
					
					
				    
				</form>
				
				</h2>
			</div>

		</div>
		
		<div class="container">
			
			<!--胶囊式导航-->
			<div class="row" style="margin-top: 5px;">
				<ul class="nav nav-tabs nav-tabs-justified">
					<li class="active">
						<a href="homepage.jsp"><strong style="font-size: 18px;"> Homepage </strong></a>
					</li>
					<li>
						<a href="car_information.jsp" ><strong style="font-size: 18px;"> Car-information </strong></a>
						<!--ul class="dropdown-menu">
		                    <li>ff</li>
		                </ul-->
					</li>
					<li>
						<a href="car_track.jsp"><strong style="font-size: 18px;"> Car-track </strong></a>
					</li>
					
				</ul>

			</div>
			
			<div class="col-lg-3 list-group">
				 <table class="table">
			    	<caption style="color: red;"><a href="#"><strong>超速车辆警示(车牌号)</strong></a></caption><br />
			    	<tr class="danger">
			    		<th><%=danger%></th>
			    	</tr>
			    </table>
				
			    <table class="table">
			    	<caption><a href="car_information.jsp" target="_blank"><strong>当前车辆信息</strong></a></caption>
			    	<thead>
		                <tr class="success">
			                <th><strong>类型</strong></th>
			                <th><strong>信息</strong></th>
		                </tr>
	                </thead>
	                <tbody>
		                <tr>
			                <th>车牌号</th>
			                <th><%=curId%></th>
		                </tr>
		                <tr>
			                <th>经纬度</th>
			                <th><%=site.get(curId*10+info.get(curId).getSite()).getLatitude()%>,
			                <%=site.get(curId*10+info.get(curId).getSite()).getLongtitude()%></th>
		                </tr>
		                <tr>
			                <th>速度(km/h)</th>
			                <th><%=info.get(curId).getSpeed()%></th>
		                </tr>
		                <tr>
			                <th>液面高度(cm)</th>
			                <th><%=info.get(curId).getHeight()%></th>
		                </tr>
		                <tr>
			                <th>车辆状态</th>
			                <th><%=info.get(curId).getSpeed()<90?"正常":"超速"%></th>
		                </tr>
	                </tbody>
			    </table>
			    
			    
			    
			    <table class="table">
			    	<caption><a href="car_track.jsp" target="_blank"><strong>当前车辆速度曲线</strong></a></caption>
			    	<!-- 创建图表容器 -->
			    	<thead>
		                <tr>
			                <th id="c1"><strong>速度-地点图表</strong></th>
		                </tr>
	                </thead>
			    	
                </table>
			    
			   
			</div>
			
			
			
		<!--显示地图-->
		
			<div class="col-lg-9">
				<div id="containerss" tabindex="0">
					
				</div>
			</div>
			
		</div>
		
		
		
		
		<!--地图js api-->
        <script type="text/javascript" src="http://webapi.amap.com/maps?v=1.3&key=您申请的key值"></script>
        <script type="text/javascript" src="http://cache.amap.com/lbs/static/addToolbar.js"></script>
        <script type="text/javascript">
        
        // 创建地图
	    var map = new AMap.Map('containerss', {
		    resizeEnable: true,
		    zoom: 5,
		    center: [113.302234, 23.090035]
	    });
	    
	    // 绘制路径折线
	    <%
	    for(int i=0;i<5;++i){
	    %>
	    var lineArr = [
	    	 [<%=site.get(i*10).getLongtitude()%>, <%=site.get(i*10).getLatitude()%>],
	         [<%=site.get(i*10+1).getLongtitude()%>, <%=site.get(i*10+1).getLatitude()%>],
	         [<%=site.get(i*10+2).getLongtitude()%>, <%=site.get(i*10+2).getLatitude()%>],
	         [<%=site.get(i*10+3).getLongtitude()%>, <%=site.get(i*10+3).getLatitude()%>],
	         [<%=site.get(i*10+4).getLongtitude()%>, <%=site.get(i*10+4).getLatitude()%>],
	         [<%=site.get(i*10+5).getLongtitude()%>, <%=site.get(i*10+5).getLatitude()%>],
	         [<%=site.get(i*10+6).getLongtitude()%>, <%=site.get(i*10+6).getLatitude()%>],
	         [<%=site.get(i*10+7).getLongtitude()%>, <%=site.get(i*10+7).getLatitude()%>],
	         [<%=site.get(i*10+8).getLongtitude()%>, <%=site.get(i*10+8).getLatitude()%>],
	         [<%=site.get(i*10+9).getLongtitude()%>, <%=site.get(i*10+9).getLatitude()%>],
        ];
        var polyline = new AMap.Polyline({
            path: lineArr,          //设置线覆盖物路径
            strokeColor: "#3366FF", //线颜色
            strokeOpacity: 1,       //线透明度
            strokeWeight: 5,        //线宽
            strokeStyle: "solid",   //线样式
            strokeDasharray: [10, 5] //补充线样式
        });
         polyline.setMap(map);
       <%
	    }
	    %>
	    map.plugin(["AMap.Scale","AMap.MapType"], function() {
            map.addControl(new AMap.Scale());
            map.addControl(new AMap.MapType());
       });
       
       
	    // 地图覆盖物 位置 经纬度
        var lnglats = [
        [<%=site.get(info.get(0).getSite()).getLongtitude()%>, <%=site.get(info.get(0).getSite()).getLatitude()%>],
        [<%=site.get(10+info.get(1).getSite()).getLongtitude()%>, <%=site.get(10+info.get(1).getSite()).getLatitude()%>],
        [<%=site.get(20+info.get(2).getSite()).getLongtitude()%>, <%=site.get(20+info.get(2).getSite()).getLatitude()%>],
        [<%=site.get(30+info.get(3).getSite()).getLongtitude()%>, <%=site.get(30+info.get(3).getSite()).getLatitude()%>],
        [<%=site.get(40+info.get(4).getSite()).getLongtitude()%>, <%=site.get(40+info.get(4).getSite()).getLatitude()%>],
        ];
	    
	    // infs[]:存储：车辆速度-传感器信息-车辆状态
        var infs = [
        [<%=info.get(0).getSpeed()%>,<%=info.get(0).getHeight()%>,],
        [<%=info.get(1).getSpeed()%>,<%=info.get(1).getHeight()%>,1],
        [<%=info.get(2).getSpeed()%>,<%=info.get(2).getHeight()%>,0],
        [<%=info.get(3).getSpeed()%>,<%=info.get(3).getHeight()%>,1],
        [<%=info.get(4).getSpeed()%>,<%=info.get(4).getHeight()%>,1],
        ];
	    
          
        var infoWindow = new AMap.InfoWindow({ offset: new AMap.Pixel(0, -30) });

        for (var i = 0, marker; i < lnglats.length; i++) {
            var marker = new AMap.Marker({
                position: lnglats[i],
                map: map
            });
            
            if(infs[i][0]<90){
            	marker.content = '车辆信息\n 编号：' + (i) + '\n 速度:'+infs[i][0]
                    +'\n 传感器信息：'+infs[i][1]+'\n 状态：'+'正常';
            }
            else{
            	marker.content = '车辆信息\n 编号：' + (i) + '\n 速度:'+infs[i][0]
                    +'\n 传感器信息：'+infs[i][1]+'\n 状态：'+'超速';
            }
            
            marker.on('click', markerClick);
            marker.on('dblclick', markerClickDouble);
            marker.emit('click', {target: marker});
        }

        function markerClick(e) {
            infoWindow.setContent(e.target.content);
            infoWindow.open(map, e.target.getPosition());}
        function markerClickDouble(e) {
            alert(e.target.getPosition());}
        
        map.setFitView();
	    
        </script>
        
        
        <!-- 创建图表容器 -->
        <script>
        	var data = [
        {genre: 'p1', sold:<%=info.get(curId).getSite()==0?info.get(curId).getSpeed():(random.nextInt(110)%(70) + 40)%>},
        {genre: 'p2', sold:<%=info.get(curId).getSite()==1?info.get(curId).getSpeed():(random.nextInt(110)%(70) + 40)%>},
        {genre: 'p3', sold:<%=info.get(curId).getSite()==2?info.get(curId).getSpeed():(random.nextInt(110)%(70) + 40)%>},
        {genre: 'p3', sold:<%=info.get(curId).getSite()==3?info.get(curId).getSpeed():(random.nextInt(110)%(70) + 40)%>},
        {genre: 'p5', sold: <%=info.get(curId).getSite()==4?info.get(curId).getSpeed():(random.nextInt(110)%(70) + 40)%>},
        {genre: 'p6', sold: <%=info.get(curId).getSite()==5?info.get(curId).getSpeed():(random.nextInt(110)%(70) + 40)%>},
        {genre: 'p7', sold: <%=info.get(curId).getSite()==6?info.get(curId).getSpeed():(random.nextInt(110)%(70) + 40)%>},
        {genre: 'p8', sold: <%=info.get(curId).getSite()==7?info.get(curId).getSpeed():(random.nextInt(110)%(70) + 40)%>},
        {genre: 'p9', sold: <%=info.get(curId).getSite()==8?info.get(curId).getSpeed():(random.nextInt(110)%(70) + 40)%>},
        {genre: 'p10', sold: <%=info.get(curId).getSite()==9?info.get(curId).getSpeed():(random.nextInt(110)%(70) + 40)%>},
      ]; // G2 对数据源格式的要求，仅仅是 JSON 数组，数组的每个元素是一个标准 JSON 对象。
      // Step 1: 创建 Chart 对象
      var chart = new G2.Chart({
        id: 'c1', // 指定图表容器 ID
        width : 300, // 指定图表宽度
        height : 300 // 指定图表高度
      });
      // Step 2: 载入数据源
      chart.source(data, {
        genre: {
          alias: '地点' // 列定义，定义该属性显示的别名
        },
        sold: {
          alias: '速度km/h'
        }
      });
      // Step 3：创建图形语法，绘制柱状图，由 genre 和 sold 两个属性决定图形位置，genre 映射至 x 轴，sold 映射至 y 轴
      chart.interval().position('genre*sold').color('genre')
      // Step 4: 渲染图表复制代码
      chart.render();
        </script>
	</body>
</html>
