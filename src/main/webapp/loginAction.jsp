<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="user.UserDAO"%>
<%@ page import="java.io.PrintWriter"%>
<% request.setCharacterEncoding("UTF-8"); %>

<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>JSP 게시판 웹 사이트</title>
</head>
<body>
<%
    String sessionUserID = (String) session.getAttribute("userID");
    if (sessionUserID != null) {
        out.println("<script>alert('이미 로그인 되어 있습니다.'); location.href = 'main.jsp';</script>");
        return;
    }

    String userID = request.getParameter("userID");
    String userPassword = request.getParameter("userPassword");

    if (userID == null || userPassword == null || userID.trim().isEmpty() || userPassword.trim().isEmpty()) {
        out.println("<script>alert('아이디와 비밀번호를 입력해주세요.'); history.back();</script>");
        return;
    }

    UserDAO userDAO = new UserDAO();

    // 계정 잠금 여부 확인
    if (userDAO.isAccountLocked(userID)) {
        out.println("<script>alert('로그인 3회 실패로 계정이 15분간 잠겼습니다.'); history.back();</script>");
        return;
    }

    int result = userDAO.login(userID, userPassword);

    if (result == 1) {
        userDAO.resetFailCount(userID);
        int isAdmin = userDAO.adminCheck(userID);

        if (isAdmin == 1) {
            // 관리자: 로그인 유예 → 2차 인증 페이지로
            session.setAttribute("pendingAdmin", userID);
            session.removeAttribute("userID"); // 혹시 남아 있을 경우 방지
            out.println("<script>location.href = 'registerOtp';</script>"); // registerOtp 서블릿
        } else {
            // 일반 사용자: 즉시 로그인
            session.setAttribute("userID", userID);
            out.println("<script>location.href = 'main.jsp';</script>");
        }

    } else if (result == 0) {
        userDAO.increaseFailCount(userID);
        out.println("<script>alert('비밀번호가 틀렸습니다.'); history.back();</script>");
    } else if (result == -1) {
        out.println("<script>alert('존재하지 않는 아이디입니다.'); history.back();</script>");
    } else {
        out.println("<script>alert('알 수 없는 오류가 발생했습니다.'); history.back();</script>");
    }
%>
</body>
</html>
