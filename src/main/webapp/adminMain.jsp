<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="user.UserDAO"%>
<%@ page import="user.User"%>
<%@ page import="java.io.PrintWriter"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet"
	href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700&display=swap">
<title>운영자 페이지</title>
<style>
body {
	font-family: 'Noto Sans KR', sans-serif;
	background-color: #111;
	color: #fff;
}

.navbar {
	background-color: #000;
}

.navbar-brand, .nav-link {
	color: #fff !important;
}

.navbar-brand {
	font-weight: bold;
}

.nav-link {
	margin-right: 20px;
}

.dropdown-menu {
	background-color: #000;
}

.dropdown-item {
	color: #fff;
}

.jumbotron {
	background-color: #111;
	color: #fff;
	text-align: center;
}

.jumbotron h1 {
	font-size: 3rem;
	font-weight: bold;
}

.btn-primary {
	background-color: #fff;
	color: #000;
	border: none;
}

.btn-primary:hover {
	background-color: #ccc;
}

.carousel-inner img {
	width: 100%;
	height: 60vh;
}

.carousel-control-prev-icon, .carousel-control-next-icon {
	background-color: #000;
}

.footer {
	text-align: center;
	padding: 20px 0;
	background-color: #000;
}
</style>
</head>
<body>
	<%
    // 세션에서 로그인된 사용자 ID 가져오기
    String userID = (String) session.getAttribute("userID");

// admin 계정이 아니면 차단
if (!"admin".equals(userID)) {
 response.sendRedirect("main.jsp"); // "main.jsp"
 return;
}

    // 페이지 번호 파라미터 처리 (선택 사항)
    int pageNumber = 1;
    try {
        if (request.getParameter("pageNumber") != null) {
            pageNumber = Integer.parseInt(request.getParameter("pageNumber"));
        }
    } catch (NumberFormatException e) {
        pageNumber = 1;
    }
%>

	<nav class="navbar navbar-expand-lg navbar-dark">
		<div class="container">
			<a class="navbar-brand" href="adminMain.jsp"> 
			<img src="image/cuteduck.png" alt="duck" style="height: 30px;">
			</a>
			<button class="navbar-toggler" type="button" data-toggle="collapse"
				data-target="#navbarNav" aria-controls="navbarNav"
				aria-expanded="false" aria-label="Toggle navigation">
				<span class="navbar-toggler-icon"></span>
			</button>
			<div class="collapse navbar-collapse" id="navbarNav">
				<ul class="navbar-nav mr-auto">
					<li class="nav-item"><a class="nav-link" href="adminUser.jsp">회원
							관리</a></li>
					<li class="nav-item"><a class="nav-link" href="adminBbs.jsp">게시판
							관리</a></li>
				</ul>
				<ul class="navbar-nav ml-auto">
					<li class="nav-item dropdown"><a
						class="nav-link dropdown-toggle" href="#" id="navbarDropdown"
						role="button" data-toggle="dropdown" aria-haspopup="true"
						aria-expanded="false">메뉴</a>
						<div class="dropdown-menu" aria-labelledby="navbarDropdown">
							<% if (userID == null) { %>
							<a class="dropdown-item" href="login.jsp">로그인</a> <a
								class="dropdown-item" href="join.jsp">회원가입</a>
							<% } else { %>
							<a class="dropdown-item" href="logoutAction.jsp">로그아웃</a>
							<% } %>
						</div></li>
				</ul>
			</div>
		</div>
	</nav>
	<div class="jumbotron">
		<h1>관리자 메인 페이지</h1>
		<p>관리자 입니다</p>
	</div>
	<div class="footer">
		<p>© 2024 JSP 게시판 웹 사이트. 모든 권리 보유.</p>
	</div>
	<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
	<script
		src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>