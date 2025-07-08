<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="util.HtmlUtil" %>
<%
// 관리자 권한 확인
String loginUserID = (String) session.getAttribute("userID");
if (loginUserID == null || !"admin".equals(loginUserID)) {
    response.sendRedirect("main.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet"
	href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700&display=swap">
<title>JSP 게시판 웹 사이트</title>
<style>
/* 스타일 생략 (네가 작성한 CSS 그대로 유지) */
</style>
</head>

<body>
	<nav class="navbar navbar-expand-lg navbar-dark">
		<div class="container">
			<a class="navbar-brand" href="adminMain.jsp"> <img
				src="cuteduck.png" alt="Admin page" style="height: 30px;">
			</a>
			<button class="navbar-toggler" type="button" data-toggle="collapse"
				data-target="#navbarNav">
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
						role="button" data-toggle="dropdown"> 메뉴 </a>
						<div class="dropdown-menu" aria-labelledby="navbarDropdown">
							<a class="dropdown-item" href="logoutAction">로그아웃</a>
						</div></li>
				</ul>
			</div>
		</div>
	</nav>

	<div class="container">
		<div class="row">
			<div class="col-lg-4"></div>
			<div class="col-lg-4 custom-form-container">
				<div class="custom-jumbotron">
					<%
					String oldUserID = request.getParameter("oldUserID");
					String targetUserID = oldUserID;
					String adminStatus = request.getParameter("admin");
					%>
					<form method="post" action="adminUserUpdate">
						<h3 class="text-center">회원 정보 수정</h3>
						<input type="hidden" name="oldUserID" value="<%= HtmlUtil.escapeHtml(oldUserID) %>">
						<div class="form-group">
							<input type="text" class="form-control" placeholder="아이디"
								name="userID" maxlength="20" readonly
								value="<%= HtmlUtil.escapeHtml(targetUserID) %>">
						</div>
						<div class="form-group">
							<input type="password" class="form-control" placeholder="비밀번호"
								name="userPassword" maxlength="20">
						</div>
						<div class="form-group">
							<input type="text" class="form-control" placeholder="이름"
								name="userName" maxlength="20">
						</div>
						<!-- 관리자 여부 스위치 -->
						<div class="form-group text-center">
							<div class="radio-container">
								<label class="switch mb-0"> <input type="radio"
									name="admin" value="user"
									<%="user".equals(adminStatus) ? "checked" : ""%>> <span
									class="slider"></span>
								</label> <span>일반 계정</span>
							</div>
							<div class="radio-container">
								<label class="switch mb-0"> <input type="radio"
									name="admin" value="admin"
									<%="admin".equals(adminStatus) ? "checked" : ""%>> <span
									class="slider"></span>
								</label> <span>관리자 계정</span>
							</div>
						</div>
						<div class="form-group">
							<input type="email" class="form-control" placeholder="이메일"
								name="userEmail" maxlength="20">
						</div>
						<input type="submit" class="btn btn-primary form-control"
							value="수정">
					</form>
				</div>
			</div>
			<div class="col-lg-4"></div>
		</div>
	</div>

	<div class="footer">
		<p>© 2024 JSP 게시판 웹 사이트. 모든 권리 보유.</p>
	</div>

	<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
	<script
		src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
