<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원 탈퇴 확인</title>
    <style>
        body {
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f7f7f7;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            width: 350px;
            text-align: center;
        }
        input[type="password"] {
            width: 100%;
            padding: 10px;
            margin-top: 15px;
            border: 1px solid #ccc;
            border-radius: 6px;
        }
        button {
            margin-top: 20px;
            width: 100%;
            padding: 10px;
            background-color: #d9534f;
            color: white;
            border: none;
            border-radius: 6px;
            font-weight: bold;
            cursor: pointer;
        }
        button:hover {
            background-color: #c9302c;
        }
        .cancel {
            margin-top: 10px;
            display: inline-block;
            color: #555;
            text-decoration: none;
            font-size: 14px;
        }
        .cancel:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>회원 탈퇴 확인</h2>
        <p>탈퇴를 위해 비밀번호를 다시 입력해주세요.</p>
        <!-- 탈퇴 처리 form: POST 방식으로 userDeleteAction.jsp로 전송 -->
        <form action="userDeleteAction" method="post">
        	<!-- 비밀번호 입력 필드 (required: 미입력 시 전송 안 됨) -->
            <input type="password" name="userPassword" placeholder="비밀번호 입력" required>
            <button type="submit">회원 탈퇴</button>
        </form>
        <a href="main.jsp" class="cancel">취소하고 돌아가기</a>
    </div>
</body>
</html>
