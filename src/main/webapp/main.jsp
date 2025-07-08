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

	<nav class="navbar navbar-expand-lg navbar-light">
		<a class="navbar-brand" href="main.jsp">JSP Board</a>
		<button class="navbar-toggler" type="button" data-toggle="collapse"
			data-target="#navbarNav" aria-controls="navbarNav"
			aria-expanded="false" aria-label="Toggle navigation">
			<span class="navbar-toggler-icon"></span>
		</button>
		<div class="collapse navbar-collapse" id="navbarNav">
			<ul class="navbar-nav mr-auto">
				<li class="nav-item active"><a class="nav-link" href="main.jsp">Home</a></li>
			
				<li class="nav-item active"><a class="nav-link" href="bbs">Board</a></li>
			</ul>
			<ul class="navbar-nav ml-auto">
				<%
				// 로그인 여부에 따라 Account 메뉴와 Sign In 메뉴를 구분해서 출력
				if (userID == null) {
				%>
				<!-- 로그인하지 않은 사용자에게는 로그인 메뉴만 보여줌 -->
				<li class="nav-item dropdown"><a
					class="nav-link dropdown-toggle" href="#" id="navbarDropdown"
					role="button" data-toggle="dropdown" aria-haspopup="true"
					aria-expanded="false"> Sign In </a>
					<div class="dropdown-menu" aria-labelledby="navbarDropdown">
						<a class="dropdown-item" href="login.jsp">Login</a>
					</div></li>
				<%
				} else {
				%>
				<!-- 로그인한 사용자에게는 Account 메뉴 보여줌 -->
				<li class="nav-item dropdown"><a
					class="nav-link dropdown-toggle" href="#" id="navbarDropdown"
					role="button" data-toggle="dropdown" aria-haspopup="true"
					aria-expanded="false"> Account </a>
					<div class="dropdown-menu" aria-labelledby="navbarDropdown">
						<!-- 로그아웃 메뉴 항목 -->
						<a class="dropdown-item" href="logoutAction.jsp">Logout</a>
						<!-- [추가된 부분] 비밀번호 변경 페이지로 이동하는 메뉴 항목 -->
						<!-- 로그인한 사용자만 볼 수 있으며, changePassword.jsp로 이동함 -->
						<a class="dropdown-item" href="changePassword.jsp">Change
							Password</a>
						<!-- 계정 삭제 메뉴 항목, 삭제 전 확인 알림 표시 -->
						<a class="dropdown-item" href="userDelete.jsp?userID=<%=userID%>"
							onclick="return confirm('정말로 계정을 삭제하시겠습니까?');">Delete ID</a>
					</div></li>
				<%
				}
				%>
			</ul>
		</div>
	</nav>

	<!--  Bootstrap 필수 스크립트 -->
	<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
	<script
		src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js"></script>
	<script
		src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

</body>
</html>
