<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.UUID"%>
<%@ page import="bbs.BbsDAO"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet"
	href="https://fonts.googleapis.com/css?family=Roboto:400,700&display=swap">

<%
String csrfToken = UUID.randomUUID().toString();
session.setAttribute("csrfToken", csrfToken);

String userID = (String) session.getAttribute("userID");
%>

<link rel="stylesheet" href="css/write_style.css"><!-- 외부 CSS -->

<title>JSP 게시판 웹 사이트</title>
</head>
<body>

	<!-- 네비게이션 바 -->
	<jsp:include page="includes/write_nav.jsp" />

	<div class="container mt-5">
		<div class="row">
			<form method="post" action="file/writeActionServlet"
				enctype="multipart/form-data" class="col-12">
				<!-- CSRF 토큰 -->
				<input type="hidden" name="csrfToken" value="<%=csrfToken%>">

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
