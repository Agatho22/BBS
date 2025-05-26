<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="user.UserDAO" %>
<%@ page import="java.io.PrintWriter" %>
<% request.setCharacterEncoding("UTF-8"); %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원 탈퇴</title>
</head>
<body>
<%
    // 세션에서 로그인된 사용자 ID를 가져옴
    String userID = (String) session.getAttribute("userID");

    // 폼에서 입력된 현재 비밀번호를 가져옴
    String userPassword = request.getParameter("userPassword");

    // 로그인되어 있지 않으면 로그인 페이지로 리디렉션
    if (userID == null) {
        out.println("<script>");
        out.println("alert('로그인이 필요합니다.');"); // 경고창
        out.println("location.href='login.jsp';");    // 로그인 페이지로 이동
        out.println("</script>");
        return; // 이후 코드 실행 중단
    }

    // 비밀번호가 입력되지 않았을 경우 처리
    if (userPassword == null || userPassword.trim().isEmpty()) {
        out.println("<script>");
        out.println("alert('비밀번호를 입력해주세요.');"); // 경고창
        out.println("history.back();"); // 이전 페이지로 이동
        out.println("</script>");
        return; // 이후 코드 실행 중단
    }

    // DB 처리를 위한 DAO 객체 생성
    UserDAO userDAO = new UserDAO();

    // 회원 탈퇴 시도 → 비밀번호가 일치하면 1, 틀리면 0, 오류 발생 시 -1 반환
    int result = userDAO.deleteUser(userID, userPassword);

    if (result == 1) {
        // 성공적으로 삭제된 경우 → 세션 초기화 후 메인 페이지로 이동
        session.invalidate(); // 로그인 세션 종료
        out.println("<script>");
        out.println("alert('회원님의 정보가 성공적으로 삭제되었습니다.');");
        out.println("location.href='index.jsp';"); // 탈퇴 후 이동할 페이지
        out.println("</script>");
    } else if (result == 0) {
        // 비밀번호 틀림
        out.println("<script>");
        out.println("alert('비밀번호가 틀렸습니다.');");
        out.println("history.back();");
        out.println("</script>");
    } else {
        // 탈퇴 처리 중 예외 발생
        out.println("<script>");
        out.println("alert('회원 탈퇴 중 오류가 발생했습니다.');");
        out.println("history.back();");
        out.println("</script>");
    }
%>
</body>
</html>
