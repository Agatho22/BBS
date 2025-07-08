<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="bbs.Bbs" %>
<%@ page import="bbs.BbsDAO" %>
<%@ page import="util.HtmlUtil" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>게시판 상세 보기</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700&display=swap">
    <style>
        body {
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #111;
            color: #fff;
            margin-bottom: 50px;
        }

        .navbar {
            background-color: #000;
            border-bottom: 1px solid #333;
        }

        .navbar-brand, .nav-link {
            color: #fff !important;
            font-weight: bold;
        }

        .navbar-brand:hover, .nav-link:hover {
            color: #ccc !important;
        }

        .table th, .table td {
            background-color: #222;
            color: #fff;
            border-color: #444;
        }

        .btn-primary {
            background-color: #444;
            color: #fff;
            border: none;
        }

        .btn-primary:hover {
            background-color: #555;
        }

        .footer {
            text-align: center;
            padding: 20px 0;
            background-color: #000;
            color: #fff;
            position: fixed;
            bottom: 0;
            width: 100%;
        }
    </style>
</head>
<body>
<%
    String userID = (String) session.getAttribute("userID");

    int bbsID = 0;
    if (request.getParameter("bbsID") != null) {
        bbsID = Integer.parseInt(request.getParameter("bbsID"));
    }

    if (bbsID == 0) {
        PrintWriter script = response.getWriter();
        script.println("<script>alert('유효하지 않은 글입니다.'); location.href='bbs.jsp';</script>");
        return;
    }

    Bbs bbs = new BbsDAO().getBbs(bbsID);
    if (bbs == null) {
        PrintWriter script = response.getWriter();
        script.println("<script>alert('존재하지 않는 글입니다.'); location.href='bbs.jsp';</script>");
        return;
    }

    if ("Y".equals(bbs.getIsSecret())) {
        if (userID == null || !(userID.equals(bbs.getUserID()) || userID.equals("admin"))) {
%>
<script>
    alert("잘못된 접근입니다.");
    history.back();
</script>
<%
            return;
        }
    }
%>

<!-- 네비게이션 바 -->
<nav class="navbar navbar-expand-lg navbar-dark">
    <a class="navbar-brand" href="main.jsp">JSP Board</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav">
        <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav mr-auto">
            <li class="nav-item active"><a class="nav-link" href="main.jsp">Home</a></li>
            <li class="nav-item active"><a class="nav-link" href="bbs">Board</a></li>
        </ul>
        <ul class="navbar-nav ml-auto">
            <% if (userID == null) { %>
            <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown"> Sign In </a>
                <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                    <a class="dropdown-item" href="login.jsp">Login</a>
                </div>
            </li>
            <% } else { %>
            <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown"> Account </a>
                <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                    <a class="dropdown-item" href="logoutAction">Logout</a>
                    <a class="dropdown-item" href="userDeleteAction.jsp?userID=<%= HtmlUtil.escapeHtml(userID) %>" onclick="return confirm('정말로 계정을 삭제하시겠습니까?');">Delete ID</a>
                </div>
            </li>
            <% } %>
        </ul>
    </div>
</nav>

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
            <a onclick="return confirm('정말로 삭제하시겠습니까?');" href="deleteAction.jsp?bbsID=<%=bbsID%>" class="btn btn-primary">삭제</a>
        </div>
        <% } %>
    </div>
</div>

<!-- 푸터 -->
<div class="footer">
    <p>© 2024 JSP 게시판 웹 사이트. 모든 권리 보유.</p>
</div>

<!-- 스크립트 -->
<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
