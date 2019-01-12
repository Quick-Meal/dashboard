<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%@page import="car.CarInfo"%>
<%@page import="java.util.Vector" %>
<%@page import="car.Site" %>

<% Vector<Site> site=CarInfo.getSiteList();
   Vector<CarInfo> info=CarInfo.getCarInfo();
   int curId=request.getParameter("curId")==null?0:Integer.parseInt(request.getParameter("curId"));

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
        
        <meta http-equiv="X-UA-Compatible" content="chrome=1">
        <meta name="viewport" content="initial-scale=1.0, user-scalable=no, width=device-width">
        <style type="text/css">
        body,html,#containerss{
        height: 600px;
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
					<li>
						<a href="homepage.jsp"><strong style="font-size: 18px;"> Homepage </strong></a>
					</li>
					<li class="active">
						<a href="car_information.jsp"><strong style="font-size: 18px;"> Car-information </strong></a>
						<!--ul class="dropdown-menu">
		                    <li>ff</li>
		                </ul-->
					</li>
					<li>
						<a href="car_track.jsp"><strong style="font-size: 18px;"> Car-track </strong></a>
					</li>
					
				</ul>

			</div>
			
			<div class="list-group">
				
			    <table class="table">
			    	<caption><a style="text-decoration: none;"><strong>车辆信息</strong></a></caption>
			    	
			    	<!--此处thead为表头，不用修改-->
			    	<thead>
		                <tr class="success">
			                <th><strong>车牌号</strong></th>
			                <th><strong>经度</strong></th>
			                <th><strong>纬度</strong></th>
			                <th><strong>瞬时速度(km/h)</strong></th>
			                <th><strong>液面高度(cm)</strong></th>
			                <th><strong>车辆状态</strong></th>
		                </tr>
	                </thead>
	                <tbody>



	                <!--此处循环，需修改-->
	                <%for(int i=0;i<5;++i){ %>
		                <tr>
			                <th><%=i %></th>
			                <th><%=site.get(i*10+info.get(i).getSite()).getLongtitude() %></th>
			                <th><%=site.get(i*10+info.get(i).getSite()).getLatitude() %></th>
			                <th><%=info.get(i).getSpeed() %></th>
			                <th><%=info.get(i).getHeight()%></th>
			                <th><%=info.get(i).getSpeed()>90?"超速":"正常" %></th>
		                </tr>
                    <%} %>


		                
	                </tbody>
			    </table>
			   
			</div>
				
		</div>
		
		
		
	
	</body>
</html>
