<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="user.UserDAO"%>
<%@ page import="user.User"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.io.PrintWriter"%>

<%
String userID = (String) session.getAttribute("userID");
if (userID == null || !userID.equals("admin")) {
    PrintWriter script = response.getWriter();
    script.println("<script>");
    script.println("alert('관리자만 접근할 수 있습니다.');");
    script.println("location.href = 'main.jsp';");
    script.println("</script>");
    script.close();
    return;
}

// CSRF 토큰 생성
String csrfToken = java.util.UUID.randomUUID().toString();
session.setAttribute("csrfToken", csrfToken);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>admin 사용자 관리</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
<link rel="stylesheet" href="css/admin_user_style.css"><!-- 외부 CSS -->
</head>
<body>

<jsp:include page="includes/admin_nav.jsp" /><!-- 네비게이션 바 -->

<!-- 사용자 목록 테이블 -->
<div class="container mt-4">
    <h2>관리자 : <%=userID%>님</h2>
    <table class="table table-hover">
        <thead>
        <tr>
            <th>아이디</th>
            <th>비밀번호</th>
            <th>이름</th>
            <th>이메일</th>
            <th>권한</th>
            <th>수정</th>
            <th>삭제</th>
        </tr>
        </thead>
        <tbody>
        <%
        UserDAO userDAO = new UserDAO();
        ArrayList<User> list = userDAO.getUserList();
        for (User user : list) {
            String ID = user.getUserID();
            int adminCheckResult = userDAO.adminCheck(ID);
        %>
        <tr>
            <td><%=user.getUserID()%></td>
            <td>
                ●●●●●●
                <button type="button" class="btn btn-secondary btn-sm"
                        onclick="alert('해시값: <%= user.getUserPassword() %>')">보기</button>
                <% if (!"admin".equals(ID)) { %>
                <button type="button" class="btn btn-info btn-sm"
                        onclick="resetPassword('<%= ID %>')">비밀번호 초기화</button>
                <% } %>
            </td>
            <td><%=user.getUserName()%></td>
            <td><%=user.getUserEmail()%></td>
            <td><%=adminCheckResult == 1 ? "관리자" : "회원"%></td>
            <td>
                <% if ("admin".equals(ID)) { %>
                <button class="btn btn-secondary btn-sm" disabled>수정불가</button>
                <% } else { %>
                <a href="adminUserEditServlet?oldUserID=<%= ID %>" class="btn btn-warning btn-sm">
                    <i class="fas fa-edit"></i> 수정
                </a>
                <% } %>
            </td>
            <td>
                <% if ("admin".equals(ID)) { %>
                <button class="btn btn-secondary btn-sm" disabled>삭제불가</button>
                <% } else { %>
                <a href="#" onclick="confirmDelete('<%=ID%>')" class="btn btn-danger btn-sm">
                    <i class="fas fa-trash-alt"></i> 삭제
                </a>
                <% } %>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<div class="footer">&copy; 2024 관리자 페이지. 모든 권리 보유.</div>

<!-- CSRF 토큰 전달 -->
<script>const csrfToken = "<%= csrfToken %>";</script>

<!-- 삭제 및 비밀번호 초기화 스크립트 -->
<script>
function resetPassword(userID) {
    if (confirm("해당 회원의 비밀번호를 임시값(temp1234)으로 초기화하시겠습니까?")) {
        const form = document.createElement('form');
        form.method = 'post';
        form.action = 'adminResetPassword';

        form.innerHTML = `
            <input type="hidden" name="userID" value="${userID}">
            <input type="hidden" name="csrfToken" value="${csrfToken}">
        `;
        document.body.appendChild(form);
        form.submit();
    }
}

    function confirmDelete(userID) {
        if (confirm("정말로 이 회원을 삭제하시겠습니까?")) {
            const form = document.createElement('form');
            form.method = 'post';
            form.action = 'adminDeleteAction';

            form.innerHTML = `
                <input type="hidden" name="userID" value="${userID}">
                <input type="hidden" name="csrfToken" value="${csrfToken}">
            `;
            document.body.appendChild(form);
            form.submit();
        }
    }
</script>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
