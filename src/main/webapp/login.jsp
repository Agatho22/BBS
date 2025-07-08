<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;600&display=swap">
<style>
body {
	font-family: 'Roboto', sans-serif;
	background-color: #f8f9fa;
	margin: 0;
	height: 100vh;
	display: flex;
	justify-content: center;
	align-items: center;
}
.login-wrapper {
	width: 100%;
	max-width: 380px;
	background: #fff;
	border-radius: 10px;
	padding: 30px;
	box-shadow: 0 4px 20px rgba(0,0,0,0.1);
	text-align: center;
}
.login-wrapper img.logo {
	height: 40px;
	margin-bottom: 30px;
}
.input-group {
	margin-bottom: 15px;
	text-align: left;
}
.input-group input {
	width: 100%;
	padding: 12px;
	border: 1px solid #ccc;
	border-radius: 4px;
	font-size: 14px;
}
.options {
	display: flex;
	justify-content: space-between;
	align-items: center;
	font-size: 0.9rem;
	margin-bottom: 20px;
}
.options .custom-control-label {
	padding-left: 5px;
}
.btn-login {
	width: 100%;
	padding: 12px;
	background-color: #03c75a;
	color: white;
	font-weight: bold;
	border: none;
	border-radius: 4px;
	font-size: 16px;
}
.links {
	margin-top: 20px;
	font-size: 0.9rem;
	display: flex;
	justify-content: space-around;
	color: #555;
}
.links a {
	color: #03c75a;
	text-decoration: none;
}
.links a:hover {
	text-decoration: underline;
}
</style>
</head>
<body>
	<div class="login-wrapper">
		<a href="main.jsp">
    		<img src="image/cuteduck.png" alt="duck" class="logo">
		</a>
		<form method="post" action="loginAction" onsubmit="return validateLogin();">			
		<div class="input-group">
				<input type="text" name="userID" id="loginUserID" placeholder="아이디 " required>
			</div>
			<div class="input-group">
				<input type="password" name="userPassword" id="loginUserPassword" placeholder="비밀번호" required>
			</div>
			<div class="options">
				<div class="form-check">
					<input class="form-check-input" type="checkbox" id="keepLogin">
					<label class="form-check-label" for="keepLogin">로그인 상태 유지</label>
				</div>
			</div>
			<button type="submit" class="btn-login">로그인</button>
		</form>
		<div class="links">
			<a href="find.jsp">비밀번호 찾기</a>
			<a href="find.jsp">아이디 찾기</a>
			<a href="join.jsp">회원가입</a>
		</div>
	</div>
	<script>
		function validateLogin() {
			const userID = document.getElementById('loginUserID').value; // 입력된 아이디 가져옴
			if (/[A-Z]/.test(userID)) { // 정규표현식으로 대문자 검사
				alert('아이디에는 영문 대문자를 사용할 수 없습니다.'); // 대문자 발견 시 경고
				return false; // 폼 제출 중단
			}
			return true; // 통과 시 제출 허용
		}
	</script>
</body>
</html>
