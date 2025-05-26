<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="user.UserDAO" %>
<%
    String pendingAdmin = (String) session.getAttribute("pendingAdmin");
    if (pendingAdmin == null || new UserDAO().adminCheck(pendingAdmin) != 1) {
        out.println("<script>alert('관리자만 접근할 수 있습니다.'); location.href='login.jsp';</script>");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>OTP 인증</title>
</head>
<body>
    <h2>OTP 인증</h2>
    <form method="post" action="verifyOtp">
        <label>6자리 OTP 코드:</label>
        <input type="text" name="otpCode" maxlength="6" required>
        <input type="submit" value="인증">
    </form>
</body>
</html>
