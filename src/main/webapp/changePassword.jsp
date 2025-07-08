<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.io.PrintWriter"%>

<%
    // 세션에서 로그인된 사용자 ID 확인
    String userID = null;
    if (session.getAttribute("userID") != null) {
        userID = (String) session.getAttribute("userID");
    } else {
        // 로그인되지 않은 사용자는 로그인 페이지로 리디렉션
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('로그인이 필요합니다.')");
        script.println("location.href = 'login.jsp'");
        script.println("</script>");
        return; // 더 이상 페이지 실행하지 않음
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>비밀번호 변경</title>

<!-- 부트스트랩 CSS 불러오기 -->
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

<style>
/* 스타일 설정 */
body {
    padding-top: 60px;
    background-color: #f8f9fa;
}

.container {
    max-width: 500px;
    background: white;
    padding: 30px;
    border-radius: 10px;
    box-shadow: 0 0 10px rgba(0,0,0,0.1);
}
</style>
</head>
<body>

<!-- 비밀번호 변경 폼 컨테이너 -->
<div class="container">
    <h3 class="text-center">비밀번호 변경</h3>

    <!-- 비밀번호 변경 입력 폼 -->
    <!-- 입력값은 changePasswordAction.jsp로 전송됨 -->
    <form method="post" action="ChangePasswordAction">
        <!-- 현재 비밀번호 입력 -->
         <div class="form-group">
            <label for="currentPassword">현재 비밀번호</label>
            <input type="password" class="form-control" id="currentPassword" name="currentPassword" required>
        </div>

        <!-- 새 비밀번호 입력 -->
        <div class="form-group">
            <label for="newPassword">새 비밀번호</label>
            <input type="password" class="form-control" id="newPassword" name="newPassword" required>
        </div>

        <!-- 새 비밀번호 확인 입력 -->
        <div class="form-group">
            <label for="confirmPassword">새 비밀번호 확인</label>
            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
        </div>

        <!-- 제출 버튼 -->
        <button type="submit" class="btn btn-primary btn-block">변경하기</button>
    </form>
</div>

</body>
</html>
