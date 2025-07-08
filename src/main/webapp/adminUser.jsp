<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="user.UserDAO"%>
<%@ page import="user.User"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.io.PrintWriter"%>

<%
String userID = (String) session.getAttribute("userID");
if (userID == null || !userID.equals("admin")) {
	PrintWriter script = response.getWriter();
	script.println("<script>");
	script.println("alert('관리자만 접근할 수 있습니다.');");
	script.println("location.href = 'main.jsp';");
	script.println("</script>");
	script.close();
	return;
}

// CSRF 토큰 생성
String csrfToken = java.util.UUID.randomUUID().toString();
session.setAttribute("csrfToken", csrfToken);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>admin 사용자 관리</title>
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
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
.dropdown-item:hover {
	background-color: #444444;
	color: #ffffff;
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
.footer {
	text-align: center;
	padding: 20px 0;
	background-color: #000;
}
table {
	color: #ffffff;
}
table tbody tr:hover {
	background-color: #444;
}
</style>
</head>
<body>

<!-- 네비게이션 바 -->
<nav class="navbar navbar-expand-lg navbar-dark">
	<div class="container">
		<a class="navbar-brand" href="adminMain.jsp">
			<img src="cuteduck.png" alt="Admin page" style="height: 30px;">
		</a>
		<button class="navbar-toggler" type="button" data-toggle="collapse"
			data-target="#navbarNav" aria-controls="navbarNav"
			aria-expanded="false" aria-label="Toggle navigation">
			<span class="navbar-toggler-icon"></span>
		</button>
		<div class="collapse navbar-collapse" id="navbarNav">
			<ul class="navbar-nav mr-auto">
				<li class="nav-item"><a class="nav-link" href="adminUser.jsp">회원 관리</a></li>
				<li class="nav-item"><a class="nav-link" href="adminBbs.jsp">게시판 관리</a></li>
			</ul>
			<ul class="navbar-nav ml-auto">
				<li class="nav-item dropdown">
					<a class="nav-link dropdown-toggle" href="#" id="navbarDropdown"
						role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">메뉴</a>
					<div class="dropdown-menu" aria-labelledby="navbarDropdown">
						<a class="dropdown-item" href="logoutAction">로그아웃</a>
					</div>
				</li>
			</ul>
		</div>
	</div>
</nav>

<div class="container mt-4">
	<h2>관리자 : <%=userID%>님</h2>
	<table class="table table-hover">
		<thead>
			<tr>
				<th>아이디</th>
				<th>비밀번호</th>
				<th>이름</th>
				<th>이메일</th>
				<th>권한</th>
				<th>수정</th>
				<th>삭제</th>
			</tr>
		</thead>
		<tbody>
			<%
			UserDAO userDAO = new UserDAO();
			ArrayList<User> list = userDAO.getUserList();
			for (User user : list) {
				String ID = user.getUserID();
				int adminCheckResult = userDAO.adminCheck(ID);
			%>
			<tr>
				<td><%=user.getUserID()%></td>
				<td>
					●●●●●●
					<button type="button" class="btn btn-secondary btn-sm"
						onclick="alert('해시값: <%= user.getUserPassword() %>')">보기</button>
					<% if (!"admin".equals(ID)) { %>
						<button type="button" class="btn btn-info btn-sm"
							onclick="resetPassword('<%= ID %>')">비밀번호 초기화</button>
					<% } %>
				</td>
				<td><%=user.getUserName()%></td>
				<td><%=user.getUserEmail()%></td>
				<td><%=adminCheckResult == 1 ? "관리자" : "회원"%></td>
				<td>
					<% if ("admin".equals(ID)) { %>
						<button class="btn btn-secondary btn-sm" disabled>수정불가</button>
					<% } else { %>
						<a href="adminUpdate.jsp?userID=<%=ID%>&oldUserID=<%=ID%>" class="btn btn-warning btn-sm">
							<i class="fas fa-edit"></i> 수정
						</a>
					<% } %>
				</td>
				<td>
					<% if ("admin".equals(ID)) { %>
						<button class="btn btn-secondary btn-sm" disabled>삭제불가</button>
					<% } else { %>
						<a href="#" onclick="confirmDelete('<%=ID%>')" class="btn btn-danger btn-sm">
							<i class="fas fa-trash-alt"></i> 삭제
						</a>
					<% } %>
				</td>
			</tr>
			<% } %>
		</tbody>
	</table>
</div>

<div class="footer">&copy; 2024 관리자 페이지. 모든 권리 보유.</div>

<!-- CSRF 토큰 전달 -->
<script>const csrfToken = "<%= csrfToken %>";</script>

<script>
	function resetPassword(userID) {
		if (confirm("해당 회원의 비밀번호를 임시값(temp1234)으로 초기화하시겠습니까?")) {
			const form = document.createElement('form');
			form.method = 'post';
			form.action = 'adminResetPassword.jsp';

			const inputUser = document.createElement('input');
			inputUser.type = 'hidden';
			inputUser.name = 'userID';
			inputUser.value = userID;

			const inputToken = document.createElement('input');
			inputToken.type = 'hidden';
			inputToken.name = 'csrfToken';
			inputToken.value = csrfToken;

			form.appendChild(inputUser);
			form.appendChild(inputToken);
			document.body.appendChild(form);
			form.submit();
		}
	}

	function confirmDelete(userID) {
		if (confirm("정말로 이 회원을 삭제하시겠습니까?")) {
			const form = document.createElement('form');
			form.method = 'post';
			form.action = 'adminDeleteAction';

			const inputUser = document.createElement('input');
			inputUser.type = 'hidden';
			inputUser.name = 'userID';
			inputUser.value = userID;

			const inputToken = document.createElement('input');
			inputToken.type = 'hidden';
			inputToken.name = 'csrfToken';
			inputToken.value = csrfToken;

			form.appendChild(inputUser);
			form.appendChild(inputToken);
			document.body.appendChild(form);
			form.submit();
		}
	}
</script>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
