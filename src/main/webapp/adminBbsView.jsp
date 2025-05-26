<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="bbs.Bbs" %>
<%@ page import="bbs.BbsDAO" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700&display=swap">
    <title>게시판 상세 보기</title>
    <style>
        body {
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #111;
            color: #fff;
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
        }
    </style>
</head>
<body>
<%
    // 세션에서 사용자 ID 가져오기
    String userID = (String) session.getAttribute("userID");

    // 로그인 상태가 아닌 경우
    if (userID == null) {
        response.sendRedirect("login.jsp");
        return;
    }

 // 🔒 admin 계정이 아니면 차단
    if (!"admin".equals(userID)) {
        response.sendRedirect("main.jsp"); // main.jsp
        return;
    }

    // 게시글 ID 가져오기 및 유효성 검사
    int bbsID = 0;
    try {
        bbsID = Integer.parseInt(request.getParameter("bbsID"));
    } catch (Exception e) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('유효하지 않은 요청입니다.');");
        script.println("location.href = 'bbs.jsp';");
        script.println("</script>");
        return;
    }

    if (bbsID == 0) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('유효하지 않은 글입니다.');");
        script.println("location.href = 'bbs.jsp';");
        script.println("</script>");
        return;
    }

    // 게시글 정보 가져오기
    Bbs bbs = new BbsDAO().getBbs(bbsID);
    if (bbs == null) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('존재하지 않는 글입니다.');");
        script.println("location.href = 'bbs.jsp';");
        script.println("</script>");
        return;
    }
%>

    <!-- 네비게이션 바 -->
     <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container">
             <a class="navbar-brand" href="adminMain.jsp">
    			<img src="flower.jpg" alt="Admin page" style="height: 30px;">
				</a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav mr-auto">
                    <li class="nav-item"><a class="nav-link" href="adminUser.jsp">회원 관리</a></li>
                    <li class="nav-item"><a class="nav-link" href="adminBbs.jsp">게시판 관리</a></li>
                </ul>
                <ul class="navbar-nav ml-auto">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">메뉴</a>
                        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                            <% if (userID == null) { %>
                            <a class="dropdown-item" href="login.jsp">로그인</a>
                            <a class="dropdown-item" href="join.jsp">회원가입</a>
                            <% } else { %>
                            <a class="dropdown-item" href="logoutAction.jsp">로그아웃</a>
                            <% } %>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- 게시글 상세 내용 -->
    <div class="container mt-5">
        <h2 class="mb-4">게시글 상세 보기</h2>
        <table class="table table-bordered">
            <tbody>
                <tr>
                    <th style="width: 20%;">글 제목</th>
                    <td><%= bbs.getBbsTitle().replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>") %></td>
                </tr>
                <tr>
                    <th>작성자</th>
                    <td><%= bbs.getUserID() %></td>
                </tr>
                <tr>
                    <th>작성일자</th>
                    <td><%= bbs.getBbsDate().substring(0, 16) %></td>
                </tr>
                <tr>
                    <th>내용</th>
                    <td style="min-height: 150px;"><%= bbs.getBbsContent().replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>") %></td>
                </tr>
            </tbody>
        </table>

        <!-- 버튼 섹션 -->
        <div class="d-flex justify-content-between mt-4">
            <a href="fileDownload.jsp?bbsID=<%= bbsID %>" class="btn btn-primary">파일 다운로드</a>
            <div>
                <% if (userID != null && userID.equals(bbs.getUserID())) { %>
                    <a href="adminBbsUpdate.jsp?bbsID=<%= bbsID %>" class="btn btn-primary">수정</a>
                    <a onclick="return confirm('정말로 삭제하시겠습니까?')" href="adminBbsDeleteAction.jsp?bbsID=<%= bbsID %>" class="btn btn-primary">삭제</a>
                <% } %>
                <a href="adminBbs.jsp" class="btn btn-primary">목록</a>
                <a href="adminBbsWrite.jsp" class="btn btn-primary">작성</a>
            </div>
        </div>
    </div>

    <!-- 푸터 -->
    <div class="footer mt-5">
        <p>© 2024 JSP 게시판 웹 사이트. 모든 권리 보유.</p>
    </div>

    <!-- 스크립트 -->
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>