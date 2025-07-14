<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs"%>
<%@ page import="bbs.BbsDAO"%>
<%@ page import="user.User"%>
<%@ page import="user.UserDAO"%>
<%@ page import="java.io.PrintWriter"%>
<!DOCTYPE html>
<html>
<%
// CSRF 토큰 생성 및 세션에 저장
String csrfToken = java.util.UUID.randomUUID().toString();
session.setAttribute("csrfToken", csrfToken);
%>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="css/bootstrap.css">
<link rel="stylesheet" href="css/custom.css">
<title>관리자 글 수정</title>
</head>
<body>

	<!-- 네비게이션 바 -->
	<jsp:include page="includes/admin_nav.jsp" />

	<%
	Bbs bbs = (Bbs) request.getAttribute("bbs");
	Integer bbsID = (Integer) request.getAttribute("bbsID");

	if (bbs == null || bbsID == null) {
	%>
	<script>
		alert('잘못된 접근입니다.');
		location.href = 'adminBbs.jsp';
	</script>
	<%
	return;
	}
	%>

	<!-- 게시글 수정 폼 -->
	<div class="container">
		<div class="row">
			<form method="post"
				action="<%=request.getContextPath()%>/file/writeActionServlet"
				enctype="multipart/form-data">
				<table class="table table-striped"
					style="text-align: center; border: 1px solid #dddddd">
					<thead>
						<tr>
							<th colspan="2"
								style="background-color: #eeeeee; text-align: center;">게시판
								수정</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td><input type="text" class="form-control"
								placeholder="제 목" name="bbsTitle" maxlength="50"
								value="<%=bbs.getBbsTitle()%>"></td>
						</tr>
						<tr>
							<td><textarea class="form-control" placeholder="내 용"
									name="bbsContent" maxlength="2048" style="height: 350px;"><%=bbs.getBbsContent()%></textarea>
							</td>
						</tr>
					</tbody>
				</table>

				<!-- 파일 첨부 필드 -->
				파일 업로드 <input type="file" name="file"><br>

				<!-- 숨겨진 게시글 ID 전달 -->
				<input type="hidden" name="bbsID" value="<%=bbsID%>"> <input
					type="hidden" name="csrfToken" value="<%=csrfToken%>">
				<!-- CSRF 토큰 추가 -->

				<!-- 제출 버튼 -->
				<input type="submit" class="btn btn-primary pull-right" value="완료">
			</form>
		</div>
	</div>

	<!-- 스크립트 로딩 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="js/bootstrap.js"></script>
</body>
</html>