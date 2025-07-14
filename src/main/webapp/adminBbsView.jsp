<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs, bbs.BbsDAO"%>
<%@ page import="reply.ReplyDAO, reply.Reply"%>
<%@ page import="file.FileDAO"%>
<%@ page import="file.FileDTO" %>
<%@ page import="util.HtmlUtil"%>
<%@ page import="javax.servlet.RequestDispatcher"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.DecimalFormat"%>

<%
    String userID = (String) session.getAttribute("userID");
    if (userID == null || !"admin".equals(userID)) {
        response.sendRedirect("main.jsp");
        return;
    }

    int bbsID = 0;
    try {
        bbsID = Integer.parseInt(request.getParameter("bbsID"));
    } catch (NumberFormatException e) {
        request.setAttribute("msg", "유효하지 않은 게시글 요청입니다.");
        request.setAttribute("redirect", "bbs.jsp");
        RequestDispatcher dispatcher = request.getRequestDispatcher("error.jsp");
        dispatcher.forward(request, response);
        return;
    }

    BbsDAO dao = new BbsDAO();
    Bbs bbs = dao.getBbs(bbsID);
    if (bbs == null) {
        request.setAttribute("msg", "존재하지 않는 게시글입니다.");
        request.setAttribute("redirect", "bbs.jsp");
        RequestDispatcher dispatcher = request.getRequestDispatcher("error.jsp");
        dispatcher.forward(request, response);
        return;
    }

    FileDTO file = null;
    try (FileDAO fileDAO = new FileDAO()) {
        file = fileDAO.getFile (bbsID);
    } catch (Exception e) {
        e.printStackTrace();
    }

    ReplyDAO replyDAO = new ReplyDAO();
    List<Reply> replyList = replyDAO.getList(bbsID);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>관리자 게시판 상세 보기</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet" href="css/admin_view_style.css">
</head>
<body>

	<jsp:include page="includes/admin_nav.jsp" />

	<div class="container mt-5">
		<h2 class="mb-4">게시글 상세 보기</h2>
		<table class="table table-bordered">
			<tr>
				<th style="width: 20%;">글 제목</th>
				<td><%= HtmlUtil.escapeHtmlWithFormat(bbs.getBbsTitle()) %></td>
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
				<td><%= HtmlUtil.escapeHtmlWithFormat(bbs.getBbsContent()) %></td>
			</tr>
		</table>

		<% if (file != null) { %>
		<div class="mt-4">
			<h5>첨부파일</h5>
			<p>
				📎 <a href="downloadFile?bbsID=<%=bbsID%>"> <%= HtmlUtil.escapeHtml(file.getOriginalName()) %>
				</a> <span class="text-muted">(<%= new DecimalFormat("#,###.##").format(file.getSize() / 1024.0) %>
					KB)
				</span>
			</p>
			<% if (file.getMimeType() != null && file.getMimeType().startsWith("image/")) { %>
			<img src="previewFile?bbsID=<%=bbsID%>" class="img-thumbnail mt-2"
				style="max-width: 400px;">
			<% } %>
		</div>
		<% } %>

		<div class="d-flex justify-content-between mt-4">
			<a href="adminBbs.jsp" class="btn btn-secondary">목록</a>
			<div>
				<a href="adminBbsUpdate.jsp?bbsID=<%=bbsID%>"
					class="btn btn-warning">수정</a>
				<form method="post" action="adminBbsDeleteAction"
					onsubmit="return confirm('정말로 삭제하시겠습니까?')" style="display: inline;">
					<input type="hidden" name="bbsID" value="<%=bbsID%>">
					<button type="submit" class="btn btn-danger">삭제</button>
				</form>
			</div>
		</div>

		<div class="mt-5">
			<h4>댓글 목록</h4>
			<% if (replyList.isEmpty()) { %>
			<p class="text-muted">등록된 댓글이 없습니다.</p>
			<% } else {
            for (Reply reply : replyList) { %>
			<div class="border rounded p-3 mb-2">
				<div class="d-flex justify-content-between">
					<div>
						<strong><%= HtmlUtil.escapeHtml(reply.getUserID()) %></strong> <small
							class="text-muted"> | <%= reply.getReplyDate().toString().substring(0, 16) %></small>
					</div>
					<form method="post" action="adminDeleteReply"
						onsubmit="return confirm('댓글을 삭제하시겠습니까?');" style="margin: 0;">
						<input type="hidden" name="replyID"
							value="<%= reply.getReplyID() %>"> <input type="hidden"
							name="bbsID" value="<%= bbsID %>">
						<button class="btn btn-sm btn-danger">삭제</button>
					</form>
				</div>
				<div class="mt-2"><%= HtmlUtil.escapeHtmlWithFormat(reply.getReplyContent()) %></div>
			</div>
			<% } } %>
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
