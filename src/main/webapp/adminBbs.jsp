<%@page import="user.User"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs"%>
<%@ page import="bbs.BbsDAO"%>
<%@ page import="user.UserDAO"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.io.PrintWriter"%>
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

// CSRF 토큰 생성
String csrfToken = java.util.UUID.randomUUID().toString();
session.setAttribute("csrfToken", csrfToken);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
<title>운영자 페이지</title>

<link rel="stylesheet" href="css/admin_bbs_style.css">
<!-- 외부 CSS -->

</head>
<body>

	<!-- 네비게이션 바 -->
	<jsp:include page="includes/admin_nav.jsp" />

	<div class="container">
		<h2>
			관리자 :
			<%=userID%>님
		</h2>
		<div class="row">
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
					BbsDAO bbsDAO = new BbsDAO();
					ArrayList<Bbs> list = bbsDAO.getList(pageNumber);
					for (int i = 0; i < list.size(); i++) {
					%>
					<tr>
						<td><%=list.get(i).getBbsID()%></td>
						<td><a
							href="adminBbsView.jsp?bbsID=<%=list.get(i).getBbsID()%>"
							style="color: #1E90FF; text-decoration: none;"> <%=list.get(i).getBbsTitle()%></a></td>
						<td><%=list.get(i).getUserID()%></td>
						<td><%=list.get(i).getBbsDate().substring(0, 11)%> <%=list.get(i).getBbsDate().substring(11, 13)%>시
							<%=list.get(i).getBbsDate().substring(14, 16)%>분</td>
						<td><a
							href="adminBbsUpdate.jsp?bbsID=<%=list.get(i).getBbsID()%>"
							class="btn btn-warning btn-sm">수정</a></td>
						<td>
							<form method="post" action="deleteBbs"
								onsubmit="return confirm('정말로 삭제하시겠습니까?')"
								style="display: inline;">
								<input type="hidden" name="bbsID"
									value="<%=list.get(i).getBbsID()%>"> <input
									type="hidden" name="csrfToken"
									value="<%=session.getAttribute("csrfToken")%>">
								<button type="submit" class="btn btn-danger btn-sm">삭제</button>
							</form>
						</td>
					</tr>
					<%
					}
					%>
				</tbody>
			</table>
		</div>
		<div
			class="pagination d-flex justify-content-between align-items-center mt-4">
			<%
			if (pageNumber != 1) {
			%>
			<a href="adminBbs.jsp?pageNumber=<%=pageNumber - 1%>"
				class="btn btn-success">이전</a>
			<%
			} else {
			%>
			<span class="btn btn-success disabled">이전</span>
			<%
			}
			%>
			<%
			if (bbsDAO.nextPage(pageNumber + 1)) {
			%>
			<a href="adminBbs.jsp?pageNumber=<%=pageNumber + 1%>"
				class="btn btn-success">다음</a>
			<%
			} else {
			%>
			<span class="btn btn-success disabled">다음</span>
			<%
			}
			%>
		</div>
		<div class="mt-4 text-right">
			<a href="adminBbsWrite.jsp" class="btn btn-primary">작성</a>
		</div>
	</div>
	<div class="footer">&copy; 2024 관리자 페이지. 모든 권리 보유.</div>
	<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
	<script
		src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
	<script
		src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
