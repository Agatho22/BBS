<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="bbs.Bbs"%>
<%@ page import="util.HtmlUtil"%>
<%@ page import="util.BbsUtil"%>
<%@ page import="reply.ReplyDAO"%>
<%@ page import="reply.Reply"%>
<%@ page import="file.FileDAO"%>
<%@ page import="file.FileDTO"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="javax.servlet.RequestDispatcher"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>게시판 상세 보기</title>
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet"
	href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700&display=swap">
<link rel="stylesheet" href="css/view_style.css">
</head>
<body>

	<%
    String userID = (String) session.getAttribute("userID");
    Bbs bbs = BbsUtil.validateAndGetBbs(request, response, userID);
    if (bbs == null) return;
    int bbsID = bbs.getBbsID();
%>

	<jsp:include page="includes/user_nav.jsp" />

	<div class="container mt-5">
		<h2 class="mb-4">게시글 상세 보기</h2>
		<table class="table table-bordered">
			<tbody>
				<tr>
					<th style="width: 20%;">글 제목</th>
					<td><%= HtmlUtil.escapeHtmlWithFormat(bbs.getBbsTitle()) %> <% if ("Y".equals(bbs.getIsSecret())) { %>
						🔒 <% } %></td>
				</tr>
				<tr>
					<th>작성자</th>
					<td><%= HtmlUtil.escapeHtml(bbs.getUserID()) %></td>
				</tr>
				<tr>
					<th>작성일자</th>
					<td><%= bbs.getBbsDate().substring(0, 16) %></td>
				</tr>
				<tr>
					<th>내용</th>
					<td style="min-height: 150px;"><%= HtmlUtil.escapeHtmlWithFormat(bbs.getBbsContent()) %></td>
				</tr>
			</tbody>
		</table>

		<%-- 첨부파일 표시 --%>
		<%
        FileDTO file = null;
        try (FileDAO fileDAO = new FileDAO()) {
            file = fileDAO.getFile(bbsID);
        } catch (Exception e) {
            request.setAttribute("msg", "첨부파일을 불러오는 중 오류가 발생했습니다.");
            request.setAttribute("redirect", "bbs.jsp");
            RequestDispatcher dispatcher = request.getRequestDispatcher("error.jsp");
            dispatcher.forward(request, response);
            return;
        }
    %>
		<% if (file != null) { %>
		<div class="mt-4">
			<h5>첨부파일</h5>
			<p>
				📎 <a href="downloadFile?bbsID=<%=bbsID%>"
					class="text-decoration-none font-weight-bold"> <%= HtmlUtil.escapeHtml(file.getOriginalName()) %>
				</a> <span class="text-muted">(<%= new DecimalFormat("#,###.##").format(file.getSize() / 1024.0) %>
					KB)
				</span>
			</p>
			<% if (file.getMimeType() != null && file.getMimeType().startsWith("image/")) { %>
			<img src="previewFile?bbsID=<%=bbsID%>" alt="첨부 이미지 미리보기"
				class="img-thumbnail mt-2" style="max-width: 400px;">
			<% } %>
		</div>
		<% } %>

		<div class="d-flex justify-content-between mt-4">
			<div>
				<a href="bbs.jsp" class="btn btn-primary mr-2">목록</a>
			</div>
			<% if (userID != null && userID.equals(bbs.getUserID())) { %>
			<div>
				<a href="bbs/validateAccess?bbsID=<%=bbsID%>"
					class="btn btn-primary mr-2">수정</a>
				<form method="post" action="deleteMyBbs" style="display: inline;"
					onsubmit="return confirm('정말로 삭제하시겠습니까?');">
					<input type="hidden" name="bbsID" value="<%=bbsID%>">
					<button type="submit" class="btn btn-danger">삭제</button>
				</form>
			</div>
			<% } %>
		</div>

		<div class="mt-5">
			<h4>댓글</h4>
			<%
            ReplyDAO replyDAO = new ReplyDAO();
            List<Reply> replyList = replyDAO.getList(bbsID);
            for (Reply reply : replyList) {
        %>
			<div class="border rounded p-2 mb-2">
				<strong><%= HtmlUtil.escapeHtml(reply.getUserID()) %></strong> <small
					class="text-muted"> | <%= reply.getReplyDate().toString().substring(0, 16) %></small><br>
				<%= HtmlUtil.escapeHtmlWithFormat(reply.getReplyContent()) %>
			</div>
			<%
            }
        %>

			<% if (userID != null) { %>
			<form method="post" action="writeReply">
				<input type="hidden" name="bbsID" value="<%=bbsID%>">
				<div class="form-group mt-3">
					<textarea name="replyContent" class="form-control" rows="3"
						required></textarea>
				</div>
				<button type="submit" class="btn btn-success">댓글 작성</button>
			</form>
			<% } else { %>
			<p class="mt-3">
				댓글을 작성하려면 <a href="login.jsp">로그인</a>이 필요합니다.
			</p>
			<% } %>
		</div>
	</div>

	<div class="footer text-center mt-5 py-3">
		<p>© 2024 JSP 게시판 웹 사이트. 모든 권리 보유.</p>
	</div>

	<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
	<script
		src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
