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
<link rel="stylesheet" href="css/admin_write_style.css">
<!-- 외부 CSS -->

<title>관리자 글 작성 페이지</title>
<style>
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

	<jsp:include page="includes/admin_nav.jsp" /><!-- 네비게이션 바 -->

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
