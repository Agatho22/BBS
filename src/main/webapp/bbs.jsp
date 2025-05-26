<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="bbs.BbsDAO"%>
<%@ page import="bbs.Bbs"%>
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
/* 기본 스타일 설정 */
body {
	font-family: 'Roboto', sans-serif;
	background-color: #ffffff;
	color: #000000;
}

.navbar {
	background-color: #f8f9fa;
	border-bottom: 1px solid #e0e0e0;
}

.navbar-brand, .nav-link {
	color: #000000 !important;
	font-weight: 600;
}

.navbar-brand:hover, .nav-link:hover {
	color: #555555 !important;
}

.table th, .table td {
	background-color: #ffffff;
	color: #000000;
	border-color: #dee2e6;
}

.table-hover tbody tr:hover td {
	background-color: #f2f2f2;
}

a, a:hover {
	color: #000000;
	text-decoration: none;
}

.btn {
	background-color: #e0e0e0;
	color: #000000;
	border: none;
}

.btn:hover {
	background-color: #d0d0d0;
}
</style>
<title>JSP 게시판 웹 사이트</title>
</head>
<body>

	<%-- ✅ XSS 방지를 위한 HTML 이스케이프 함수 정의 --%>
	<%!public String escapeHtml(String str) {
		if (str == null)
			return "";
		return str.replace("&", "&amp;")// & → &amp; &	&amp;	HTML 엔티티의 시작이기 때문
				.replace("<", "&lt;")// < → &lt; <	&lt;	태그 열림 방지
				.replace(">", "&gt;")// > → &gt; >	&gt;	태그 닫힘 방지
				.replace("\"", "&quot;")// " → &quot; "	&quot;	속성값 중단 방지
				.replace("'", "&#x27;"); // ' → &#x27; '	&#x27;	속성값 중단 + JS 인젝션 방지
	}%>

	<%
	// 로그인한 사용자 ID 확인 (세션에서 userID 가져오기)
	String userID = null;
	if (session.getAttribute("userID") != null) {
		userID = (String) session.getAttribute("userID");
	}
	// 페이지 번호 기본값 설정 (기본값은 1)
	int pageNumber = 1;
	if (request.getParameter("pageNumber") != null) {
		pageNumber = Integer.parseInt(request.getParameter("pageNumber"));
	}
	// 검색어 파라미터 가져오기 (null일 수도 있음)
	String search = request.getParameter("search");
	%>

	<!-- ✅ 네비게이션 바 -->
	<nav class="navbar navbar-expand-lg navbar-light">
		<a class="navbar-brand" href="main.jsp">JSP Board</a>
		<button class="navbar-toggler" type="button" data-toggle="collapse"
			data-target="#navbarNav" aria-controls="navbarNav"
			aria-expanded="false" aria-label="Toggle navigation">
			<span class="navbar-toggler-icon"></span>
		</button>
		<div class="collapse navbar-collapse" id="navbarNav">
			<ul class="navbar-nav mr-auto">
				<li class="nav-item active"><a class="nav-link" href="main.jsp">Home</a></li>
				<li class="nav-item"><a class="nav-link" href="bbs.jsp">Board</a></li>
			</ul>
			<ul class="navbar-nav ml-auto">
				<%-- 로그인 여부에 따른 메뉴 표시 --%>
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
					class="nav-link dropdown-toggle" href="#" id="navbarDropdown"
					role="button" data-toggle="dropdown" aria-haspopup="true"
					aria-expanded="false"> Account </a>
					<div class="dropdown-menu" aria-labelledby="navbarDropdown">
						<a class="dropdown-item" href="logoutAction.jsp">Logout</a>
						<%-- ✅ userID를 escape 처리하여 XSS 방지 --%>
						<a class="dropdown-item"
							href="userDeleteAction.jsp?userID=<%=escapeHtml(userID)%>"
							onclick="return confirm('정말로 계정을 삭제하시겠습니까?');">Delete ID</a>
					</div></li>
				<%
				}
				%>
			</ul>
		</div>
	</nav>

	<div class="container mt-4">

		<!-- ✅ 검색어 입력값도 XSS 방지 위해 escape 처리 -->
		<form method="get" action="bbs.jsp" class="form-inline mb-3">
			<input type="text" name="search" class="form-control mr-2"
				placeholder="Search..."
				value="<%=escapeHtml(search != null ? search : "")%>">
			<button type="submit" class="btn">Search</button>
		</form>

		<!-- ✅ 게시글 리스트 -->
		<table class="table table-hover">
			<thead>
				<tr>
					<th>Number</th>
					<th>Title</th>
					<th>Author</th>
					<th>Date</th>
				</tr>
			</thead>
			<tbody>
				<%
				BbsDAO bbsDAO = new BbsDAO();
				ArrayList<Bbs> list = (search != null && !search.trim().equals("")) ? bbsDAO.searchList(search, pageNumber)
						: bbsDAO.getList(pageNumber);

				if (list.size() == 0) {
				%>
				<tr>
					<td colspan="4" class="text-center">검색 결과가 없습니다.</td>
				</tr>
				<%
				} else {
				for (Bbs b : list) {
				%>
				<tr>
					<td><%=b.getBbsID()%></td>
					<td><a href="view.jsp?bbsID=<%=b.getBbsID()%>"> <%=escapeHtml(b.getBbsTitle())%>
							<%-- ✅ 제목 출력 시 escape 처리로 XSS 방지 --%> <%
if ("Y".equals(b.getIsSecret())) {
 %> 🔒 <%
 }
 %>
					</a></td>
					<td><%=escapeHtml(b.getUserID())%></td>
					<%-- ✅ 작성자도 escape 처리 --%>
					<td><%=b.getBbsDate().substring(0, 11) + b.getBbsDate().substring(11, 13) + "시 " + b.getBbsDate().substring(14, 16)
		+ "분"%></td>
				</tr>
				<%
				}
				}
				%>
			</tbody>
		</table>

		<!-- ✅ 페이지 이동 및 글쓰기 버튼 -->
		<div class="d-flex justify-content-between">
			<div>
				<%
				if (pageNumber != 1) {
				%>
				<a
					href="bbs.jsp?pageNumber=<%=pageNumber - 1%>&search=<%=escapeHtml(search != null ? search : "")%>"
					class="btn">Previous</a>
				<%
				}
				%>
				<%
				if (bbsDAO.nextPage(pageNumber + 1)) {
				%>
				<a
					href="bbs.jsp?pageNumber=<%=pageNumber + 1%>&search=<%=escapeHtml(search != null ? search : "")%>"
					class="btn">Next</a>
				<%
				}
				%>
			</div>
			<a href="write.jsp" class="btn">Write</a>
		</div>
	</div>

	<!-- Bootstrap JS -->
	<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
	<script
		src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
