<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bbs.BbsDAO" %>
<%@ page import="bbs.Bbs" %>
<%@ page import="user.UserDAO" %>
<%@ page import="user.User" %>
<%@ page import="java.io.PrintWriter" %>

<% 
// 요청 파라미터를 UTF-8로 인코딩 처리 (POST 방식 대비)
request.setCharacterEncoding("UTF-8"); 
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>JSP 게시판 웹 사이트</title>
</head>
<body>
<%
    // 로그인한 사용자 ID 확인
    String userID = null;
    if (session.getAttribute("userID") != null) {
        userID = (String) session.getAttribute("userID");
    }

    // 로그인하지 않은 사용자 접근 차단
    if (userID == null) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('로그인을 하세요.')");
        script.println("location.href = 'login.jsp'");
        script.println("</script>");
        return; // 이후 코드 실행 중단
    }

    // 게시글 ID (bbsID) 파라미터 유효성 검사
    int bbsID = 0;
    if (request.getParameter("bbsID") != null) {
        bbsID = Integer.parseInt(request.getParameter("bbsID"));
    }

    // bbsID가 없거나 잘못된 경우
    if (bbsID == 0) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('유효하지 않은 글입니다.')");
        script.println("location.href = 'bbs.jsp'");
        script.println("</script>");
        return;
    }

    // 사용자 권한 확인: 관리자 여부 체크
    UserDAO userDAO = new UserDAO();
    int adminCheckResult = userDAO.adminCheck(userID); // 1이면 관리자, 0이면 일반 사용자

    if (adminCheckResult == 0) {
        // 일반 사용자는 삭제 권한 없음
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('권한이 없습니다.')");
        script.println("location.href = 'adminBbs.jsp'");
        script.println("</script>");
        return;
    } else {
        // 관리자일 경우 삭제 진행
        BbsDAO bbsDAO = new BbsDAO();
        int result = bbsDAO.delete(bbsID); // 게시글 삭제 시도

        if (result == -1) {
            // 삭제 실패
            PrintWriter script = response.getWriter();
            script.println("<script>");
            script.println("alert('글 삭제 실패하였습니다.')");
            script.println("history.back()");
            script.println("</script>");
        } else {
            // 삭제 성공
            PrintWriter script = response.getWriter();
            script.println("<script>");
            script.println("alert('글 삭제 완료하였습니다.')");
            script.println("location.href = 'adminBbs.jsp'");
            script.println("</script>");
        }
    }
%>
</body>
</html>
