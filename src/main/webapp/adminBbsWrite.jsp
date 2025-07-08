<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet"
	href="https://fonts.googleapis.com/css?family=Roboto:400,700&display=swap">

<title>JSP 게시판 웹 사이트</title>
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

.form-control {
	border-radius: 10px;
	background-color: #222;
	color: #fff;
	border: 1px solid #444;
}

.form-control::placeholder {
	color: #888;
}

.form-control:focus {
	background-color: #333;
	border-color: #555;
	outline: none;
	box-shadow: 0 0 5px rgba(255, 255, 255, 0.2);
}

.footer {
	text-align: center;
	padding: 20px 0;
	background-color: #000;
}

.form-container {
	background-color: #222;
	border-radius: 10px;
	padding: 30px;
	box-shadow: 0 5px 15px rgba(0, 0, 0, 0.5);
}
</style>
</head>
<body>
	<%
    String userID = (String) session.getAttribute("userID");

    // 로그인 안 한 경우 or 관리자(admin) 아닌 경우 차단
    if (userID == null || !userID.equals("admin")) {
        response.sendRedirect("main.jsp");
        return;
    }
%>

	<!-- 네비게이션 바 -->
	<nav class="navbar navbar-expand-lg navbar-dark">
		<div class="container">
			<a class="navbar-brand" href="adminMain.jsp"> <img
				src="flower.jpg" alt="Admin page" style="height: 30px;">
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
	<div class="container mt-5">
		<div class="row">
			<form method="post" action="writeAction.jsp"
				enctype="multipart/form-data" class="col-12">
				<table class="table table-striped"
					style="text-align: center; border: 1px solid #dddddd">
					<thead>
						<tr>
							<th colspan="2" style="text-align: center;">게시판 작성</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td><input type="text" class="form-control"
								placeholder="제 목" name="bbsTitle" maxlength="50"></td>
						</tr>
						<tr>
							<td><textarea class="form-control" placeholder="내 용"
									name="bbsContent" maxlength="2048" style="height: 350px;"></textarea></td>
						</tr>
					</tbody>
				</table>
				<div class="form-group">
					<label for="fileUpload">파일 업로드</label> <input type="file"
						name="file" id="fileUpload" class="form-control-file">
				</div>
				<div class="button-group">
					<input type="submit" class="btn btn-primary" value="완료">
				</div>
			</form>
		</div>

	</div>
	<div class="footer">&copy; 2024 관리자 페이지. 모든 권리 보유.</div>
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="js/bootstrap.js"></script>
</body>
</html>
