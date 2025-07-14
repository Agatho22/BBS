<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.io.PrintWriter"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>JSP 게시판 웹 사이트</title>
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet"
	href="https://fonts.googleapis.com/css2?family=San+Francisco:wght@400;700&display=swap">
<style>
body {
	font-family: 'San Francisco', -apple-system, BlinkMacSystemFont,
		"Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
	background-color: #ffffff;
	color: #000000;
}

.navbar {
	background-color: #ffffff;
	border-bottom: 1px solid #dddddd;
}

.navbar-brand, .nav-link {
	color: #000000 !important;
	font-weight: 600;
}

.navbar-brand:hover, .nav-link:hover {
	color: #555555 !important;
}

.dropdown-menu {
	background-color: #ffffff;
	border: 1px solid #eeeeee;
	box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}

.dropdown-item {
	color: #000000;
}

.dropdown-item:hover {
	background-color: #f8f9fa;
	color: #000000;
}

.container {
	padding-top: 40px;
}

.carousel-inner img {
	width: 100%;
	height: 700px;
	object-fit: cover;
}

.carousel {
	user-select: none;
}
</style>
</head>
<body>
	<%
	String userID = null;
	if (session.getAttribute("userID") != null) {
		userID = (String) session.getAttribute("userID");
	}
	%>

	<jsp:include page="includes/user_nav.jsp" />

	<!--  Bootstrap 필수 스크립트 -->
	<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
	<script
		src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js"></script>
	<script
		src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

</body>
</html>
