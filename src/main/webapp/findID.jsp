<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>아이디 찾기</title></head>
<body>
<h2>아이디 찾기</h2>
<form action="findIDAction" method="post">
  <p><label>이름: <input type="text" name="userName" required></label></p>
  
  <fieldset>
    <legend>아이디 찾기 방법 선택</legend>
    <label><input type="radio" name="method" value="email" checked> 이메일로 찾기</label><br>
    <label><input type="radio" name="method" value="phone"> 휴대전화로 찾기</label>
  </fieldset>
  
  <div id="emailDiv">
    <label>이메일: <input type="email" name="userEmail"></label>
  </div>
  <div id="phoneDiv" style="display:none;">
    <label>휴대전화: <input type="text" name="userPhone"></label>
  </div>
  
  <button type="submit">아이디 찾기</button>
</form>

<script>
  const emailDiv = document.getElementById('emailDiv');
  const phoneDiv = document.getElementById('phoneDiv');
  document.querySelectorAll('input[name="method"]').forEach(r => {
    r.addEventListener('change', e => {
      if (e.target.value === 'email') {
        emailDiv.style.display = ''; phoneDiv.style.display = 'none';
      } else {
        emailDiv.style.display = 'none'; phoneDiv.style.display = '';
      }
    });
  });
</script>
</body>
</html>
