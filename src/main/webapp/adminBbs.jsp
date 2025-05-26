<%@page import="user.User"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs"%>
<%@ page import="bbs.BbsDAO"%>
<%@ page import="user.UserDAO"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.io.PrintWriter"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap 및 FontAwesome 아이콘 사용 -->
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">

<title>admin</title>

<!-- 어두운 배경에 맞춘 관리자 페이지 전용 스타일 -->
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

.footer {
	text-align: center;
	padding: 20px 0;
	background-color: #000;
}

.table-hover tbody tr:hover {
	background-color: #222;
}

.table th, .table td {
	color: #fff;
}
</style>
</head>
<body>

	<%
    // 현재 세션에서 로그인된 userID 가져오기
    String userID = (String) session.getAttribute("userID");

    // 로그인하지 않았거나 관리자가 아니면 메인 페이지로 리다이렉트
    if (userID == null || !userID.equals("admin")) {
        response.sendRedirect("main.jsp");
        return;
    }

    // 페이지 번호 설정 (기본: 1페이지)
    int pageNumber = 1;
    if (request.getParameter("pageNumber") != null) {
        pageNumber = Integer.parseInt(request.getParameter("pageNumber"));
    }
%>

	<!-- 상단 네비게이션 바 -->
	<nav class="navbar navbar-expand-lg navbar-dark">
		<div class="container">
			<!-- 로고 -->
			<a class="navbar-brand" href="adminMain.jsp"> <img
				src="flower.jpg" alt="Admin page" style="height: 30px;">
			</a>

			<!-- 모바일용 메뉴 토글 -->
			<button class="navbar-toggler" type="button" data-toggle="collapse"
				data-target="#navbarNav" aria-controls="navbarNav"
				aria-expanded="false" aria-label="Toggle navigation">
				<span class="navbar-toggler-icon"></span>
			</button>

			<!-- 메뉴 항목 -->
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
							<%-- 로그인 여부에 따라 로그인/로그아웃 표시 --%>
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

	<!-- 본문 영역 -->
	<div class="container">
		<!-- 관리자 환영 메시지 -->
		<h2>
			관리자 :
			<%=userID%>님
		</h2>

		<div class="row">
			<!-- 게시글 관리 테이블 -->
			<form method="post" action="adminUpdateAction.jsp" class="w-100">
				<table class="table table-hover">
					<thead>
						<tr>
							<th>번호</th>
							<th>제목</th>
							<th>작성자</th>
							<th>작성일</th>
							<th>글 수정</th>
							<th>글 삭제</th>
						</tr>
					</thead>
					<tbody>
						<%
                        // 게시글 목록 조회
                        BbsDAO bbsDAO = new BbsDAO();
                        ArrayList<Bbs> list = bbsDAO.getList(pageNumber);

                        // 게시글 출력
                        for (int i = 0; i < list.size(); i++) {
                    %>
						<tr>
							<td><%=list.get(i).getBbsID()%></td>
							<td><a
								href="adminBbsView.jsp?bbsID=<%=list.get(i).getBbsID()%>"
								style="color: #1E90FF; text-decoration: none;"> <%=list.get(i).getBbsTitle()%>
							</a></td>
							<td><%=list.get(i).getUserID()%></td>
							<td><%=list.get(i).getBbsDate().substring(0, 11)%> <%=list.get(i).getBbsDate().substring(11, 13)%>시
								<%=list.get(i).getBbsDate().substring(14, 16)%>분</td>
							<td><a
								href="adminBbsUpdate.jsp?bbsID=<%=list.get(i).getBbsID()%>"
								class="btn btn-warning btn-sm">수정</a></td>
							<td><a onclick="return confirm('정말로 삭제하시겠습니까?')"
								href="adminBbsDeleteAction.jsp?bbsID=<%=list.get(i).getBbsID()%>"
								class="btn btn-danger btn-sm">삭제</a></td>
						</tr>
						<% } %>
					</tbody>
				</table>
			</form>
		</div>

		<!-- 페이지네이션 버튼 -->
		<div
			class="pagination d-flex justify-content-between align-items-center mt-4">
			<% if (pageNumber != 1) { %>
			<a href="adminBbs.jsp?pageNumber=<%=pageNumber - 1%>"
				class="btn btn-success">이전</a>
			<% } else { %>
			<span class="btn btn-success disabled">이전</span>
			<% } %>

			<% if (bbsDAO.nextPage(pageNumber + 1)) { %>
			<a href="adminBbs.jsp?pageNumber=<%=pageNumber + 1%>"
				class="btn btn-success">다음</a>
			<% } else { %>
			<span class="btn btn-success disabled">다음</span>
			<% } %>
		</div>

		<!-- 게시글 작성 버튼 -->
		<div class="mt-4 text-right">
			<a href="adminBbsWrite.jsp" class="btn btn-primary">작성</a>
		</div>
	</div>

	<!-- 하단 푸터 -->
	<div class="footer">&copy; 2024 관리자 페이지. 모든 권리 보유.</div>

	<!-- JS 종속 라이브러리 -->
	<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
	<script
		src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
	<script
		src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
