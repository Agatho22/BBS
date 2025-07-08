<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>비밀번호 찾기</title></head>
<body>
<h2>비밀번호 찾기</h2>
<form action="FindPwdServlet" method="post">
  <label>아이디: <input type="text" name="userId" required></label><br>
  <label>이름: <input type="text" name="userName" required></label><br>
  <label>이메일: <input type="email" name="userEmail" required></label><br>
  <button type="submit">임시 비밀번호 발급</button>
</form>
</body>
</html>
