<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="user.UserDAO" %>
<%@ page import="java.security.MessageDigest" %>
<%
    // 로그인된 사용자가 관리자(admin)인지 확인
    String loginUserID = (String) session.getAttribute("userID");
    if (loginUserID == null || !"admin".equals(loginUserID)) {
        // 비로그인 또는 관리자가 아닐 경우 메인 페이지로 리다이렉트
        response.sendRedirect("main.jsp");
        return;
    }

    // 초기화할 대상 사용자 ID 가져오기
    String userID = request.getParameter("userID");

    // 초기화할 임시 비밀번호 정의 (고정값 test1234)
    String testPassword = "test1234";

    // 비밀번호 초기화 요청 (주의: hashedPassword를 넘기지 않고 원문 testPassword를 넘기고 있음)
    UserDAO userDAO = new UserDAO();
    int result = userDAO.updatePassword(userID, testPassword); // 내부에서 해싱이 적용되어야 함

    // 응답 인코딩 및 출력 설정
    response.setContentType("text/html;charset=UTF-8");
    PrintWriter writer = response.getWriter();

    // 결과에 따라 alert 출력 및 이동 처리
    if (result == 1) {
        out.println("<script>alert('비밀번호가 임시값(test1234)으로 초기화되었습니다.'); location.href='adminUser.jsp';</script>");
    } else {
        out.println("<script>alert('비밀번호 초기화에 실패했습니다.'); history.back();</script>");
    }
    
    writer.close();
%>

