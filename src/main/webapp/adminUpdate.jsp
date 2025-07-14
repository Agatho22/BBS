<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="user.User"%>

<%
    // 관리자 권한 확인
    String loginUserID = (String) session.getAttribute("userID");
    if (loginUserID == null || !"admin".equals(loginUserID)) {
        response.sendRedirect("main.jsp");
        return;
    }

    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect("adminUser.jsp?error=" + java.net.URLEncoder.encode("잘못된 접근입니다.", "UTF-8"));
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>사용자 정보 수정 (관리자)</title>
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet" href="css/admin_update_style.css">
</head>
<body>

	<jsp:include page="includes/admin_nav.jsp" />

	<div class="container mt-5">
		<div class="row justify-content-center">
			<div class="col-lg-6 custom-form-container">
				<div class="custom-jumbotron p-4 border rounded">
					<form method="post" action="adminUserUpdate">
						<h3 class="text-center mb-4">회원 정보 수정</h3>
						<input type="hidden" name="oldUserID"
							value="<%= user.getUserID() %>">

						<div class="form-group">
							<label>아이디</label> <input type="text" class="form-control"
								name="userID" value="<%= user.getUserID() %>" readonly>
						</div>

						<div class="form-group">
							<label>새 비밀번호 (변경 시 입력)</label> <input type="password"
								class="form-control" name="userPassword"
								placeholder="비밀번호 변경 시에만 입력">
						</div>

						<div class="form-group">
							<label>이름</label> <input type="text" class="form-control"
								name="userName" value="<%= user.getUserName() %>" required>
						</div>

						<div class="form-group">
							<label>이메일</label> <input type="email" class="form-control"
								name="userEmail" value="<%= user.getUserEmail() %>" required>
						</div>

						<div class="form-group">
							<label>권한</label><br>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" name="admin"
									value="user"
									<%= "user".equals(user.getAdmin()) ? "checked" : "" %>>
								<label class="form-check-label">일반 사용자</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" name="admin"
									value="admin"
									<%= "admin".equals(user.getAdmin()) ? "checked" : "" %>>
								<label class="form-check-label">관리자</label>
							</div>
						</div>

						<button type="submit" class="btn btn-primary btn-block">회원
							정보 수정</button>
					</form>
				</div>
			</div>
		</div>
	</div>

	<div class="footer text-center mt-5 py-3 bg-dark text-white">
		<p>© 2024 JSP 게시판 웹 사이트. 모든 권리 보유.</p>
	</div>

	<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
	<script
		src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
