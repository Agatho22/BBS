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

<link rel="stylesheet" href="css/admin_main_style.css">
<!-- 외부 CSS -->



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

	<!-- 네비게이션 바 -->
	<jsp:include page="includes/admin_nav.jsp" />

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