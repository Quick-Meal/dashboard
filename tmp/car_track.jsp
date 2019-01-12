<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>     
<%@page import="car.CarInfo"%>
<%@page import="java.util.Vector" %>
<%@page import="car.Site" %>
<%@page import="java.util.Random" %>
<% Vector<Site> site=CarInfo.getSiteList();
   Vector<CarInfo> info=CarInfo.getCarInfo();
   Random random=new Random();
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
						<input type="text"  name="curId" class="form-control" placeholder="search all information ">
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
					<li >
						<a href="car_information.jsp"><strong style="font-size: 18px;"> Car-information </strong></a>
						<!--ul class="dropdown-menu">
		                    <li>ff</li>
		                </ul-->
					</li>
					<li class="active">
						<a href="car_track.jsp"><strong style="font-size: 18px;"> Car-track </strong></a>
					</li>
					
				</ul>

			</div>
			
			<div class="list-group">
				
			    <table class="table">
			    	<caption><a style="text-decoration: none;">车辆轨迹<strong></strong></a></caption>
			    	<thead>
		                <tr class="success" style="text-align: center;">
			                <th><strong>车牌号</strong></th>
			                <th><strong>当前位置</strong></th>
			                <th colspan="10" style="text-align: center;"><strong style="text-align: center;">运行轨迹(最近10个地点)</strong></th>
		                </tr>
	                </thead>
	                <tbody>


	                <!--此处循环，需修改-->
	                <%for(int i=0;i<5;++i){ %>
		                <tr>
			                <th rowspan="2"><strong><%=i%></strong></th>
			                <th class="danger"><%=site.get(i*10+info.get(i).getSite()).getName()%></th> 
			                <th><%=site.get(i*10).getName()%></th>
			                <th><%=site.get(i*10+1).getName()%></th>
			                <th><%=site.get(i*10+2).getName()%></th>
			                <th><%=site.get(i*10+3).getName()%></th>
			                <th><%=site.get(i*10+4).getName()%></th>
			                <th><%=site.get(i*10+5).getName()%></th>
			                <th><%=site.get(i*10+6).getName()%></th>
			                <th><%=site.get(i*10+7).getName()%></th>
			                <th><%=site.get(i*10+8).getName()%></th>
			                <th><%=site.get(i*10+9).getName()%></th>
		                </tr>
		                <tr>
			                <th>速度(km/h)</th> <!-- 此行不用修改-->
			                <th><%=info.get(i).getSite()==0?info.get(i).getSpeed():(random.nextInt(110)%(70) + 40) %></th>
			                <th><%=info.get(i).getSite()==1?info.get(i).getSpeed():(random.nextInt(110)%(70) + 40) %></th>
			                <th><%=info.get(i).getSite()==2?info.get(i).getSpeed():(random.nextInt(110)%(70) + 40) %></th>
			                <th><%=info.get(i).getSite()==3?info.get(i).getSpeed():(random.nextInt(110)%(70) + 40) %></th>
			                <th><%=info.get(i).getSite()==4?info.get(i).getSpeed():(random.nextInt(110)%(70) + 40) %></th>
			                <th><%=info.get(i).getSite()==5?info.get(i).getSpeed():(random.nextInt(110)%(70) + 40) %></th>
			                <th><%=info.get(i).getSite()==6?info.get(i).getSpeed():(random.nextInt(110)%(70) + 40) %></th>
			                <th><%=info.get(i).getSite()==7?info.get(i).getSpeed():(random.nextInt(110)%(70) + 40) %></th>
			                <th><%=info.get(i).getSite()==8?info.get(i).getSpeed():(random.nextInt(110)%(70) + 40) %></th>
			                <th><%=info.get(i).getSite()==9?info.get(i).getSpeed():(random.nextInt(110)%(70) + 40) %></th>
		                </tr>
                    <%} %>
	                </tbody>
			    </table>
			   
			</div>
				
		</div>
	
	</body>
</html>

