<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, java.net.*"%>
<%@ page import="javax.xml.parsers.* ,org.w3c.dom.*, javax.xml.xpath.*, org.xml.sax.InputSource"%>
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" charset="UTF-8, width=device-width, initial-scale=1.0">
    <title>AED 지도</title>
    <script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
    <style>
html, body {
	height: 100%;
	margin: 0;
}

.map_wrap {
	position: relative;
	overflow: hidden;
	width: 100%;
	height: 100%;
}

button {
	width: 15%;
	position: absolute;
	overflow: hidden;
	right: 2%;
	bottom: 2%;
	z-index: 1;
	float: left;
	padding: 0;
}

button:after {
	content: "";
	display: block;
	padding-bottom: 100%;
	overflow: hidden;
	position: fixed;
}

#cur {
	width: 100%;
	height: 100%;
	margin: 0;
}

.radius_border {
	border: 1px solid #919191;
	border-radius: 5px;
}

.custom_typecontrol {
	position: absolute;
	top: 2%;
	right: 2%;
	overflow: hidden;
	width: 130px;  
	height: 30px;
	margin: 0;
	padding: 0;
	z-index: 1;
	font-size: 12px;
	font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
}

.custom_typecontrol span {
	display: block;
	width: 65px;
	height: 30px;
	float: left;
	text-align: center;
	line-height: 30px;
	cursor: pointer;
}

.custom_typecontrol .btn {
	background: #fff;
	background: linear-gradient(#fff, #e6e6e6);
}

.custom_typecontrol .btn:hover {
	background: #f5f5f5;
	background: linear-gradient(#f5f5f5, #e3e3e3);
}

.custom_typecontrol .btn:active {
	background: #e6e6e6;
	background: linear-gradient(#e6e6e6, #fff);
}

.custom_typecontrol .selected_btn {
	color: #fff;
	background: #425470;
	background: linear-gradient(#425470, #5b6d8a);
}

.custom_typecontrol .selected_btn:hover {
	color: #fff;
}

.box_wrap {
	position: absolute;
	left: 0;
	bottom: 40px;
	width: 300px;
	height: 150px;
	margin-left: -144px;
	text-align: left;
	overflow: hidden;
	font-size: 12px;
	font-family: 'Malgun Gothic', dotum, '돋움', sans-serif;
	line-height: 1.5;
	white-space: normal;
}

.box_wrap * {
	padding: 0;
	margin: 0;
}

.box_wrap .info {
	width: 100%;
	height: 92%;
	border-radius: 5px;
	border-bottom: 2px solid #ccc;
	border-right: 1px solid #ccc;
	overflow: hidden;
	background: #fff;
}

.box_wrap .info:nth-child(1) {
	border: 0;
	box-shadow: 0px 1px 2px #888;
}

.info .title {
	padding: 2% 0 0 2%;
	height: 30%;
	background: #b4b4b4;
	border-bottom: 1px solid #ddd;
	font-size: 13px;
	font-weight: bold;
}

.info .body {
	position: relative;
	overflow: hidden;
}

.info .desc {
	position: relative;
	margin: 2%;
	height: 80%;
}

.desc .ellipsis {
	overflow: hidden;
	text-overflow: ellipsis;
}

.desc .tel {
	font-size: 11px;
}

.info:after {
	content: '';
	position: absolute;
	margin-left: -16px;
	left: 50%;
	bottom: 0;
	width: 7%;
	height: 8%;
	background:
		url('https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/vertex_white.png')
}

.info .link {
	color: #5085BB;
}
</style>
</head>
<body>

<div class="map_wrap">
    <div id="map" style="width:100%;height:100%;position:relative;overflow:hidden;"></div> 
    <div class="custom_typecontrol radius_border">
        <span id="btnRoadmap" class="selected_btn" onclick="setMapType('roadmap')">지도</span>
        <span id="btnSkyview" class="btn" onclick="setMapType('skyview')">스카이뷰</span>
    </div>
    <button onclick="CurLoc()"><img id="cur" src="img/mark.png" alt=""></button> 
</div>

<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=c01da46b842a4cdd71330ffa97f00afd&libraries=services"></script>
<script>	
	
	var mapContainer = document.getElementById('map'), // 지도를 표시할 div 
	mapOption = { 
	    center: new daum.maps.LatLng(37.5642135, 127.0016985), // 지도의 중심좌표
	    level: 4 // 지도의 확대 레벨
	}; 
	
	var map = new daum.maps.Map(mapContainer, mapOption); // 지도를 생성합니다
	
	
	navigator.geolocation.getCurrentPosition(function(position) {
        
        var mylat = position.coords.latitude, 
            mylon = position.coords.longitude; 
        
        var moveLatLon = new kakao.maps.LatLng(mylat, mylon);
   
        var circle = new kakao.maps.Circle({
	        center : new kakao.maps.LatLng(mylat, mylon),  // 원의 중심좌표 입니다 
	        radius: 300, // 미터 단위의 원의 반지름입니다 
	        strokeWeight: 5, // 선의 두께입니다 
	        strokeColor: '#FE2EF7', // 선의 색깔입니다
	        strokeOpacity: 1, // 선의 불투명도 입니다 1에서 0 사이의 값이며 0에 가까울수록 투명합니다
	        strokeStyle: 'solid', // 선의 스타일 입니다
	        fillColor: '#F781F3', // 채우기 색깔입니다
	        fillOpacity: 0.7  // 채우기 불투명도 입니다   
	    }); 
        
        var circle2 = new kakao.maps.Circle({
        	center : new kakao.maps.LatLng(mylat, mylon),  
	        radius: 150, 
	        strokeWeight: 5, 
	        strokeColor: '#FE2E2E',
	        strokeOpacity: 1, 
	        strokeStyle: 'solid', 
	        fillColor: '#FA5858',
	        fillOpacity: 0.7   
	    }); 
            
        circle.setMap(map);
        circle2.setMap(map);
        
        map.setCenter(moveLatLon);
 	});
	
	
	$.get("js/AED data.json", function(data) {
	        var mark = [];
		   	 var markers = $(data.positions).map(function(i, position) {
		     var marker = new kakao.maps.Marker({
		        position : new kakao.maps.LatLng(position.lat, position.lon)
		     });
		     mark.push(marker);
		     
	        navigator.geolocation.getCurrentPosition(function(position) { 
				 
				 var mylat = position.coords.latitude, 
				 mylon = position.coords.longitude; 
				 var moveLatLon = new kakao.maps.LatLng(mylat, mylon);
				 map.setCenter(moveLatLon); 
				 var rad = 1000; 
			        
				 mark.forEach(function(m) {
				     var p1 = map.getCenter();
				     var p2 = m.getPosition();
				     var poly = new daum.maps.Polyline({
				       path: [p1, p2]
				     });
				     var dist = poly.getLength(); 
				    
				     if (dist < rad) {
				     	 m.setMap(map);
				     } 
				 });
				 
	        });
	        
	        var content = '<div class="box_wrap">' + 
            '    <div class="info">' + 
            '        <div class="title">' + 
                        position.org + ' ' + position.place +
            '        </div>' + 
            '        <div class="body">' + 
            '            <div class="desc">' + 
            '                <div class="ellipsis">'+position.address+'</div>' + 
            '                <div class="tel"><a href="tel:'+position.tel+'">'+position.tel+'</a></div>' + 
            '                <div><a href="https://map.kakao.com/link/to/'+position.org+','+position.lat+','+position.lon+'" style="color:blue" target="_blank">길찾기</a></div>' + 
            '            </div>' 
            '        </div>' + 
            '    </div>' +    
            '</div>';
            
            var overlay = new kakao.maps.CustomOverlay({
            	content: content,
            	position: marker.getPosition()       
            	});
            
            
            kakao.maps.event.addListener(marker, 'click', function click() {
            	marker.setMap(null);
            	var imageSrc = 'https://ifh.cc/g/leFJVp.png',
                imageSize = new kakao.maps.Size(29, 43), 
                imageOption = {offset: new kakao.maps.Point(14, 40)}; 
                
                var markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize, imageOption),
                markerPosition = new kakao.maps.LatLng(position.lat, position.lon); 

            	var m = new kakao.maps.Marker({
                	position: markerPosition, 
                	image: markerImage 
            	});
            
            	m.setMap(map);  
            	var poLoc = new kakao.maps.LatLng(position.lat, position.lon);   
            	map.panTo(poLoc);
            	overlay.setMap(map);      
            	kakao.maps.event.addListener(m, 'click', function() {
            		m.setMap(null);
            		overlay.setMap(null);
                	marker.setMap(map);
                	kakao.maps.event.addListener(marker, 'click', function() {
                    	click();
                    });
                });
            });
            
            
	    });    
	   	 	    
	    clusterer.addMarkers(markers); 
	});
	 
	 function setMapType(maptype) { 
		    var roadmapControl = document.getElementById('btnRoadmap');
		    var skyviewControl = document.getElementById('btnSkyview'); 
		    if (maptype === 'roadmap') {
		        map.setMapTypeId(kakao.maps.MapTypeId.ROADMAP);    
		        roadmapControl.className = 'selected_btn';
		        skyviewControl.className = 'btn';
		    } else {
		        map.setMapTypeId(kakao.maps.MapTypeId.HYBRID);    
		        skyviewControl.className = 'selected_btn';
		        roadmapControl.className = 'btn';
		    }
		}       
	 function CurLoc(){
		 window.location.reload()	
	}
	 
	 

</script>
</body>
</html>
