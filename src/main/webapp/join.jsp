<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
<style>
body {
    background: #f8f9fa;
    font-family: 'Segoe UI', sans-serif;
}
.signup-box {
    max-width: 460px;
    margin: 50px auto;
    padding: 40px;
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}
.signup-box h2 {
    font-weight: 700;
    margin-bottom: 30px;
    text-align: center;
}
.form-control {
    margin-bottom: 10px;
}
#id-check-message {
    font-size: 0.9rem;
    margin-bottom: 10px;
    padding-left: 5px;
}
.text-success {
    color: green;
}
.text-danger {
    color: red;
}
.btn-block {
    background-color: #03c75a;
    border: none;
}
.btn-block:hover {
    background-color: #029e49;
}
</style>
<script>
function validateUserID(input) {
    input.value = input.value.replace(/[A-Zㄱ-ㅎㅏ-ㅣ가-힣]/g, '').slice(0, 20);
    checkDuplicateID();
}

function checkDuplicateID() {
    const userID = document.getElementById("userID").value;
    const msg = document.getElementById("id-check-message");

    if (!userID) {
        msg.textContent = "";
        return;
    }
    if (/[A-Z]/.test(userID) || /[ㄱ-ㅎㅏ-ㅣ가-힣]/.test(userID)) {
        msg.textContent = "아이디에는 대문자와 한글을 사용할 수 없습니다.";
        msg.className = "text-danger";
        return;
    }
    if (userID.length > 20) {
        msg.textContent = "아이디는 최대 20자까지 입력할 수 있습니다.";
        msg.className = "text-danger";
        return;
    }
    fetch("checkId.jsp?userID=" + encodeURIComponent(userID))
        .then(response => response.text())
        .then(data => {
            msg.textContent = data.trim();
            msg.className = data.includes("사용 가능") ? "text-success" : "text-danger";
        })
        .catch(error => {
            msg.textContent = "중복 확인 중 오류 발생";
            msg.className = "text-danger";
        });
}
</script>
</head>
<body>
    <div class="signup-box">
        <h2>회원가입</h2>
        <form method="post" action="joinAction">
            <div class="input-group">
                <input type="text" name="userID" id="userID" class="form-control" placeholder="아이디 (최대 20자)" maxlength="20" required oninput="validateUserID(this)">
            </div>
            <div id="id-check-message"></div>
            <input type="password" name="userPassword" class="form-control" placeholder="비밀번호" required>
            <input type="text" name="userName" class="form-control" placeholder="이름" required>
            <input type="email" name="userEmail" class="form-control" placeholder="이메일 주소" required>
            <button type="submit" class="btn btn-success btn-block">회원가입</button>
        </form>
        <div class="text-center mt-3">
            <a href="login.jsp">이미 계정이 있으신가요? 로그인</a>
        </div>
    </div>
</body>
</html>
