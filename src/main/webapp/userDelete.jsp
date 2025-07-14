<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원 탈퇴</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f0f2f5;
            margin: 0;
            padding: 0;
            display: flex;
            height: 100vh;
            justify-content: center;
            align-items: center;
        }

        .withdraw-box {
            background-color: #fff;
            padding: 40px 30px;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 380px;
            text-align: center;
            animation: fadeIn 0.6s ease-in-out;
        }

        .withdraw-box h2 {
            margin-bottom: 15px;
            color: #333;
        }

        .withdraw-box p {
            color: #666;
            font-size: 14px;
        }

        .withdraw-box input[type="password"] {
            width: 100%;
            padding: 12px;
            margin-top: 20px;
            border: 1px solid #ccc;
            border-radius: 8px;
            font-size: 15px;
        }

        .withdraw-box button {
            width: 100%;
            padding: 12px;
            margin-top: 20px;
            background-color: #e74c3c;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: bold;
            cursor: pointer;
        }

        .withdraw-box button:hover {
            background-color: #c0392b;
        }

        .withdraw-box .cancel-link {
            display: block;
            margin-top: 15px;
            color: #555;
            font-size: 13px;
            text-decoration: none;
        }

        .withdraw-box .cancel-link:hover {
            text-decoration: underline;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>

<div class="withdraw-box">
    <h2><i class="fas fa-user-times"></i> 회원 탈퇴</h2>
    <p>비밀번호를 입력하시면 탈퇴가 진행됩니다.</p>
    
    <form action="userDeleteAction" method="post">
        <input type="password" name="userPassword" placeholder="비밀번호" required>
        <button type="submit">탈퇴하기</button>
    </form>
    
    <a href="main.jsp" class="cancel-link">취소하고 돌아가기</a>
</div>

</body>
</html>
