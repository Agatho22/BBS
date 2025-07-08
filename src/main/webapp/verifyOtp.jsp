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
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        body {
            background-color: #f7f7f7;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .container {
            max-width: 400px;
            margin-top: 100px;
            background-color: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0px 0px 10px rgba(0,0,0,0.1);
        }
        h2 {
            margin-bottom: 20px;
            text-align: center;
        }
        .form-control {
            height: 45px;
            font-size: 16px;
        }
        .btn-primary {
            width: 100%;
            font-size: 18px;
            padding: 10px;
        }
    </style>
</head>
<body>

<div class="container">
    <h2>OTP 2차 인증</h2>
    <form method="post" action="verifyOtp">
        <div class="form-group">
            <label for="otpCode">6자리 OTP 코드</label>
            <input type="text" class="form-control" id="otpCode" name="otpCode" maxlength="6" pattern="\\d{6}" required>
        </div>
        <button type="submit" class="btn btn-primary">인증</button>
    </form>
</div>

</body>
</html>
