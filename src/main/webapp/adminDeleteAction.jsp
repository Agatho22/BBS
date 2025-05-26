<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="user.UserDAO" %>
<%@ page import="java.io.PrintWriter" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원 삭제 결과</title>
</head>
<body>
<%
    // 관리자가 삭제할 사용자 ID를 파라미터로 받아옴
    String userID = request.getParameter("userID");

    // 사용자 정보 삭제를 위한 DAO 객체 생성
    UserDAO userDAO = new UserDAO();

    // 오버로드된 deleteUser(String userID) 메서드를 호출하여 삭제 시도
    boolean result = userDAO.deleteUser(userID);

    // 클라이언트에 스크립트 출력 준비
    PrintWriter script = response.getWriter();

    if (result) {
        // 삭제 성공 시 알림 후 관리자 사용자 목록 페이지로 이동
        script.println("<script>");
        script.println("alert('회원님의 정보가 성공적으로 삭제되었습니다.')");
        script.println("location.href = 'adminUser.jsp'");
        script.println("</script>");
    } else {
        // 삭제 실패 시 알림 후 이전 페이지로 돌아가기
        script.println("<script>");
        script.println("alert('정보 삭제에 실패했습니다.')");
        script.println("history.back()");
        script.println("</script>");
    }

    // 스트림 종료
    script.close();
%>

</body>
</html>