<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="user.UserDAO" %>
<%@ page import="user.User" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.security.SecureRandom" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="css/bootstrap.css">
<link rel="stylesheet" href="css/custom.css">
<title>admin</title>
</head>
<body>
<div class="container">
    <div class="col-lg-4"></div>
    <div class="col-lg-4">
        <div class="jumbotron" style="padding-top: 20px;">
            <%
                request.setCharacterEncoding("UTF-8");

                String oldUserID = request.getParameter("oldUserID");
                String userID = request.getParameter("userID");
                String userPassword = request.getParameter("userPassword");
                String userName = request.getParameter("userName");
                String userEmail = request.getParameter("userEmail");
                String admin = request.getParameter("admin");

                if (oldUserID == null || oldUserID.isEmpty()) {
                    out.println("<p>Error: oldUserID is missing or empty.</p>");
                    return;
                }

                // 1. 솔트 생성
                SecureRandom random = new SecureRandom();
                byte[] saltBytes = new byte[16];
                random.nextBytes(saltBytes);
                StringBuilder sbSalt = new StringBuilder();
                for (byte b : saltBytes) {
                    sbSalt.append(String.format("%02x", b));
                }
                String salt = sbSalt.toString();

                // 2. SHA-256 + 솔트 해싱
                String hashedPassword = null;
                try {
                    MessageDigest md = MessageDigest.getInstance("SHA-256");
                    byte[] hash = md.digest((userPassword + salt).getBytes("UTF-8"));
                    StringBuilder sb = new StringBuilder();
                    for (byte b : hash) {
                        sb.append(String.format("%02x", b));
                    }
                    hashedPassword = sb.toString();
                } catch (Exception e) {
                    out.println("<p>Error: 비밀번호 해싱 중 오류 발생</p>");
                    e.printStackTrace();
                    return;
                }

                // 3. 사용자 객체 설정
                UserDAO userDAO = new UserDAO();
                User user = new User();
                user.setUserID(userID);
                user.setUserPassword(hashedPassword);
                user.setUserName(userName);
                user.setUserEmail(userEmail);
                user.setAdmin(admin);

                // 4. 업데이트 (salt 포함)
                int updateResult = userDAO.userUpdate(user, oldUserID, salt);
            %>
            <%
                if (updateResult > 0) {
            %>
                <script>
                    alert("회원 정보 변경을 완료하였습니다.");
                    location.href = "adminUser.jsp";
                </script>
            <%
                } else {
            %>
                <script>
                    alert("회원 정보 변경을 실패하였습니다.");
                    location.href = "adminUser.jsp";
                </script>
            <%
                }
            %>
        </div>
    </div>
</div>
<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script src="js/bootstrap.js"></script>
</body>
</html>
