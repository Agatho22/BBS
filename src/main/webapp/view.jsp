<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="bbs.Bbs" %>
<%@ page import="util.HtmlUtil" %>
<%@ page import="util.BbsUtil" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>게시판 상세 보기</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700&display=swap">
    <link rel="stylesheet" href="css/view_style.css"> <!-- 외부 CSS -->
</head>
<body>

<%
    String userID = (String) session.getAttribute("userID");
    Bbs bbs = BbsUtil.validateAndGetBbs(request, response, userID);
    if (bbs == null) return;
    int bbsID = bbs.getBbsID();
%>

<!-- 네비게이션 바 -->
<jsp:include page="includes/user_nav.jsp" />

<!-- 게시글 상세 보기 -->
<div class="container mt-5">
    <h2 class="mb-4">게시글 상세 보기</h2>
    <table class="table table-bordered">
        <tbody>
            <tr>
                <th style="width: 20%;">글 제목</th>
                <td><%= HtmlUtil.escapeHtmlWithFormat(bbs.getBbsTitle()) %> 
                    <% if ("Y".equals(bbs.getIsSecret())) { %> 🔒 <% } %>
                </td>
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

    <div class="d-flex justify-content-between mt-4">
        <div>
            <a href="bbs.jsp" class="btn btn-primary mr-2">목록</a>
            <a href="fileDownload.jsp?bbsID=<%=bbsID%>" class="btn btn-primary">파일 다운로드</a>
        </div>
        <% if (userID != null && userID.equals(bbs.getUserID())) { %>
        <div>
            <a href="update.jsp?bbsID=<%=bbsID%>" class="btn btn-primary mr-2">수정</a>
            <a onclick="return confirm('정말로 삭제하시겠습니까?');"
               href="deleteAction.jsp?bbsID=<%=bbsID%>" class="btn btn-primary">삭제</a>
        </div>
        <% } %>
    </div>
</div>

<!-- 푸터 -->
<div class="footer">
    <p>© 2024 JSP 게시판 웹 사이트. 모든 권리 보유.</p>
</div>

<!-- JS 스크립트 -->
<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
