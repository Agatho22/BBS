<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="bbs.Bbs"%>
<%@ page import="bbs.BbsDAO"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>JSP 게시판 웹 사이트</title>
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<style>
body {
	background-color: #121212;
	color: #FFFFFF;
	font-family: 'Arial', sans-serif;
}

.navbar {
	background-color: #1E1E1E;
}

.navbar-brand, .nav-link, .dropdown-toggle {
	color: #E0E0E0 !important;
}

.navbar-brand:hover, .nav-link:hover, .dropdown-toggle:hover {
	color: #B3B3B3 !important;
}

.card {
	border-radius: 15px;
	box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1);
	background-color: #1E1E1E;
	border: none;
}

.card-header {
	background-color: #282828;
	border-top-left-radius: 15px;
	border-top-right-radius: 15px;
	color: #FFFFFF;
}

.form-control, .form-control-file {
	background-color: #282828;
	color: #FFFFFF;
	border: 1px solid #444444;
}

.form-control:focus, .form-control-file:focus {
	background-color: #333333;
	color: #FFFFFF;
	border-color: #55C1D1;
	box-shadow: none;
}

.btn-primary {
	background-color: #55C1D1;
	border: none;
}

.btn-primary:hover {
	background-color: #43A2B2;
}

.dropdown-menu {
	background-color: #1E1E1E;
	border: none;
}

.dropdown-item {
	color: #E0E0E0;
}

.dropdown-item:hover {
	color: #FFFFFF;
	background-color: #282828;
}
</style>
</head>
<body>
	<%
    String userID = null;
    if (session.getAttribute("userID") != null) {
        userID = (String) session.getAttribute("userID");
    }

    if (userID == null) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('로그인을 하세요.')");
        script.println("location.href = 'login.jsp'");
        script.println("</script>");
        return;
    }

    int bbsID = 0;
    if (request.getParameter("bbsID") != null) {
        bbsID = Integer.parseInt(request.getParameter("bbsID"));
    }

    if (bbsID == 0) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('유효하지 않은 글입니다.')");
        script.println("location.href = 'bbs.jsp'");
        script.println("</script>");
        return;
    }

    Bbs bbs = new BbsDAO().getBbs(bbsID);
    if (!userID.equals(bbs.getUserID())) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('권한이 없습니다.')");
        script.println("location.href = 'bbs.jsp'");
        script.println("</script>");
        return;
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
					<li class="nav-item"><a class="nav-link" href="main.jsp">Home</a></li>
					<li class="nav-item active"><a class="nav-link" href="bbs.jsp">Board</a></li>
				</ul>
				<ul class="navbar-nav ml-auto">
					<% if (userID == null) { %>
					<li class="nav-item dropdown"><a
						class="nav-link dropdown-toggle" href="#" id="navbarDropdown"
						role="button" data-toggle="dropdown" aria-haspopup="true"
						aria-expanded="false"> Sign In </a>
						<div class="dropdown-menu" aria-labelledby="navbarDropdown">
							<a class="dropdown-item" href="login.jsp">Login</a>
						</div></li>
					<% } else { %>
					<li class="nav-item dropdown"><a
						class="nav-link dropdown-toggle" href="#"
						id="navbarDropdownAccount" role="button" data-toggle="dropdown"
						aria-haspopup="true" aria-expanded="false"> Account </a>
						<div class="dropdown-menu" aria-labelledby="navbarDropdownAccount">
							<a class="dropdown-item" href="logoutAction">Logout</a>
						</div></li>
					<% } %>
				</ul>
			</div>
		</div>
	</nav>

	<!-- 게시글 수정 폼 -->
	<div class="container my-5">
		<div class="row justify-content-center">
			<div class="col-md-8">
				<div class="card">
					<div class="card-header text-center">
						<h5>게시글 수정</h5>
					</div>
					<div class="card-body">
						<form method="post" action="updateAction"
							enctype="multipart/form-data">
							<div class="form-group">
								<label for="bbsTitle">제목</label> <input type="text"
									class="form-control" id="bbsTitle" name="bbsTitle"
									placeholder="제 목" maxlength="50" value="<%=bbs.getBbsTitle()%>">
							</div>
							<div class="form-group">
								<label for="bbsContent">내용</label>
								<textarea class="form-control" id="bbsContent" name="bbsContent"
									placeholder="내 용" maxlength="2048" style="height: 350px;"><%=bbs.getBbsContent()%></textarea>
							</div>
							<div class="form-group">
								<label for="fileUpload">파일 업로드</label> <input type="file"
									class="form-control-file" id="fileUpload" name="file">
							</div>
							<input type="hidden" name="bbsID" value="<%=bbsID%>">
							<button type="submit" class="btn btn-primary float-right">수정
								완료</button>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>

	<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
	<script
		src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
