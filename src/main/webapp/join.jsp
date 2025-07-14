<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="css/join_style.css">
<!-- 외부 CSS -->

<script>
// ID 입력 검증 및 중복 확인
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
fetch("checkId?userID=" + encodeURIComponent(userID))
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

// 비밀번호 일치 확인
function checkPasswordMatch() {
    const pw = document.querySelector('input[name="userPassword"]').value;
    const confirmPw = document.getElementById("confirmPassword").value;
    const msg = document.getElementById("password-match-message");

    if (!confirmPw) {
        msg.textContent = "";
        return;
    }
    if (pw === confirmPw) {
        msg.textContent = "비밀번호가 일치합니다.";
        msg.className = "text-success";
    } else {
        msg.textContent = "비밀번호가 일치하지 않습니다.";
        msg.className = "text-danger";
    }
}

// 비밀번호 보안 수준 시각화
function checkPasswordStrength(input) {
    const value = input.value;
    const msg = document.getElementById("password-strength-message");

    if (!value) {
        msg.textContent = "";
        return;
    }

    let strength = 0;
    if (value.length >= 8) strength++;
    if (/[A-Z]/.test(value)) strength++;
    if (/[a-z]/.test(value)) strength++;
    if (/[0-9]/.test(value)) strength++;
    if (/[\W_]/.test(value)) strength++;

    const levels = ["매우 약함", "약함", "보통", "강함", "매우 강함"];
    const colors = ["text-danger", "text-danger", "text-warning", "text-primary", "text-success"];

    msg.textContent = "보안 수준: " + levels[strength - 1];
    msg.className = colors[strength - 1];
}

// 이메일 형식 검증
function validateEmailFormat(input) {
    const email = input.value;
    const msg = document.getElementById("email-check-message");
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!email) {
        msg.textContent = "";
        return;
    }

    if (regex.test(email)) {
        msg.textContent = "올바른 이메일 형식입니다.";
        msg.className = "text-success";
    } else {
        msg.textContent = "잘못된 이메일 형식입니다.";
        msg.className = "text-danger";
    }
}

// Caps Lock 알림
function detectCapsLock(event) {
    const msg = document.getElementById("caps-lock-message");
    if (event.getModifierState("CapsLock")) {
        msg.textContent = "Caps Lock이 켜져 있습니다.";
        msg.className = "text-warning";
    } else {
        msg.textContent = "";
    }
}

// 전체 유효성 검사 (제출 전)
function validateForm(event) {
    const pw = document.querySelector('input[name="userPassword"]').value;
    const confirmPw = document.getElementById("confirmPassword").value;
    const email = document.querySelector('input[name="userEmail"]').value;
    const userID = document.getElementById("userID").value;

    if (pw !== confirmPw) {
        alert("비밀번호가 일치하지 않습니다.");
        event.preventDefault();
        return;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        alert("이메일 형식이 올바르지 않습니다.");
        event.preventDefault();
        return;
    }

    if (!userID || !pw || !confirmPw || !email) {
        alert("모든 필드를 입력해주세요.");
        event.preventDefault();
        return;
    }
}
</script>
</head>
<body>
	<div class="signup-box">
		<h2>회원가입</h2>
		<form method="post" action="joinAction" onsubmit="validateForm(event)">
			<!-- 아이디 입력 -->
			<div class="input-group">
				<input type="text" name="userID" id="userID" class="form-control"
					placeholder="아이디 (최대 20자)" maxlength="20" required
					oninput="validateUserID(this)">
			</div>
			<div id="id-check-message" class="mb-2"></div>

			<!-- 비밀번호 -->
			<input type="password" name="userPassword" class="form-control"
				placeholder="비밀번호" required oninput="checkPasswordStrength(this)"
				onkeyup="detectCapsLock(event)">
			<div id="password-strength-message" class="mb-2"></div>
			<div id="caps-lock-message" class="mb-2"></div>

			<!-- 비밀번호 확인 -->
			<input type="password" id="confirmPassword" class="form-control"
				placeholder="비밀번호 확인" required oninput="checkPasswordMatch()">
			<div id="password-match-message" class="mb-2"></div>

			<!-- 이름 -->
			<input type="text" name="userName" class="form-control"
				placeholder="이름" required>

			<!-- 이메일 -->
			<input type="email" name="userEmail" class="form-control"
				placeholder="이메일 주소" required oninput="validateEmailFormat(this)">
			<div id="email-check-message" class="mb-3"></div>

			<!-- 제출 버튼 -->
			<button type="submit" class="btn btn-success btn-block">회원가입</button>
		</form>

		<div class="text-center mt-3">
			<a href="login.jsp">이미 계정이 있으신가요? 로그인</a>
		</div>
	</div>
</body>
</html>
