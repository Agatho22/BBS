<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs"%>
<%@ page import="bbs.BbsDAO"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="file.FileDAO"%>
<%@ page import="java.io.File"%>
<%@ page import="java.io.IOException"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<%@ page import="com.oreilly.servlet.MultipartRequest"%>
<%@ page import="java.util.ArrayList"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet"
	href="https://fonts.googleapis.com/css?family=Roboto:400,700&display=swap">
<style type="text/css">
body 
<%
    String csrfToken = java.util.UUID.randomUUID().toString(); // 간단한 예측 가능한 토큰
    session.setAttribute("csrfToken", csrfToken);
%>
{
	font-family: 'Roboto', sans-serif;
	background-color: #000000;
	color: #ffffff;
	margin: 0;
}

.navbar {
	background-color: #000000;
	border-bottom: 1px solid #333333;
}

.navbar-brand, .nav-link {
	color: #ffffff !important;
	font-weight: 600;
}

.navbar-brand:hover, .nav-link:hover {
	color: #777777 !important;
}

.dropdown-menu {
	background-color: #333333;
	border: none;
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
}

.dropdown-item {
	color: #ffffff;
}

.dropdown-item:hover {
	background-color: #444444;
}

.table th, .table td {
	background-color: #111111;
	color: #ffffff;
	border-color: #333333;
}

.table-striped tbody tr:nth-of-type(odd) {
	background-color: #222222;
}

.table-striped tbody tr:hover {
	background-color: #444444;
}

.table th {
	background-color: #555555;
}

a, a:hover {
	color: #ffffff;
	text-decoration: none;
}

.btn {
	background-color: #333333;
	color: #ffffff;
}

.btn:hover {
	background-color: #444444;
}

.button-group {
	display: flex;
	justify-content: flex-end;
	margin-top: 20px;
}
</style>
<title>JSP 게시판 웹 사이트</title>
</head>
<body>
	<%
        String userID = null;
        if (session.getAttribute("userID") != null) {
            userID = (String) session.getAttribute("userID");
        }

        int bbsID = 0;
        if (request.getParameter("bbsID") != null) {
            bbsID = Integer.parseInt(request.getParameter("bbsID"));

            BbsDAO bbsDAO = new BbsDAO();
            int maxBbsID = bbsDAO.getMaxBbsID();
            int newBbsID = maxBbsID + 1;
        }
    %>

	<!-- 네비게이션 바 -->
	<nav class="navbar navbar-expand-lg navbar-dark">
		<div class="container">
			<a class="navbar-brand" href="main.jsp">JSP Board</a>
			<button class="navbar-toggler" type="button" data-toggle="collapse"
				data-target="#navbarNav" aria-controls="navbarNav"
				aria-expanded="false" aria-label="Toggle navigation">
				<span class="navbar-toggler-icon"></span>
			</button>
			<div class="collapse navbar-collapse" id="navbarNav">
				<ul class="navbar-nav mr-auto">
					<li class="nav-item"><a class="nav-link" href="main.jsp">Home</a>
					</li>
					<li class="nav-item active"><a class="nav-link" href="bbs.jsp">Board</a>
					</li>
				</ul>
				<ul class="navbar-nav ml-auto">
					<%
                        if (userID == null) {
                    %>
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
					<li class="nav-item dropdown"><a
						class="nav-link dropdown-toggle" href="#"
						id="navbarDropdownAccount" role="button" data-toggle="dropdown"
						aria-haspopup="true" aria-expanded="false"> Account </a>
						<div class="dropdown-menu" aria-labelledby="navbarDropdownAccount">
							<a class="dropdown-item" href="logoutAction">Logout</a>
						</div></li>
					<%
                        }
                    %>
				</ul>
			</div>
		</div>
	</nav>

	<div class="container mt-5">
		<div class="row">
			<form method="post" action="file/writeActionServlet"
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
						<tr>
							<td style="text-align: left;"><input type="checkbox"
								name="isSecret" value="Y"> 비밀글로 설정</td>
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

	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script
		src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
