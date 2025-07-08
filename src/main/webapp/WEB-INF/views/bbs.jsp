<%@ page contentType="text/html; charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs" %>
<%@ page import="util.HtmlUtil" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.UUID" %>
<%
    // CSRF 토큰이 없으면 생성
    if (session.getAttribute("csrfToken") == null) {
        session.setAttribute("csrfToken", UUID.randomUUID().toString());
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시판 웹 사이트</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet"
          href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css?family=Roboto:400,700&display=swap">
    <link rel="stylesheet" href="css/style.css">
</head>

<body>

<%
    String userID = (String) request.getAttribute("userID");
    String search = (String) request.getAttribute("search");
    Integer pageNumber = (Integer) request.getAttribute("pageNumber");
    if (pageNumber == null) pageNumber = 1;
    ArrayList<Bbs> list = (ArrayList<Bbs>) request.getAttribute("bbsList");
    Boolean hasNext = (Boolean) request.getAttribute("hasNext");
    String errorMsg = (String) request.getAttribute("errorMsg");
    String csrfToken = (String) session.getAttribute("csrfToken");
%>

<nav class="navbar navbar-expand-lg navbar-light bg-light">
    <a class="navbar-brand" href="main.jsp">JSP Board</a>
    <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav mr-auto">
            <li class="nav-item active"><a class="nav-link" href="main.jsp">Home</a></li>
            <li class="nav-item"><a class="nav-link" href="bbs">Board</a></li>
        </ul>
        <ul class="navbar-nav ml-auto">
            <% if (userID == null) { %>
            <li class="nav-item"><a class="nav-link" href="login.jsp">Login</a></li>
            <% } else { %>
            <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle" href="#" data-toggle="dropdown">Account</a>
                <div class="dropdown-menu">
                    <a class="dropdown-item" href="logoutAction.jsp">Logout</a>

                    <!-- CSRF 방지 적용: POST 방식 삭제 -->
                    <form id="deleteForm" method="post" action="userDeleteAction.jsp" style="display: inline;">
                        <input type="hidden" name="userID" value="<%= HtmlUtil.escapeHtml(userID) %>">
                        <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                        <a class="dropdown-item" href="#" onclick="return confirmDelete();">Delete ID</a>
                    </form>

                </div>
            </li>
            <% } %>
        </ul>
    </div>
</nav>

<div class="container mt-4">

    <% if (errorMsg != null) { %>
    <div class="alert alert-danger">
        <%= HtmlUtil.escapeHtml(errorMsg) %>
    </div>
    <% } %>

    <form method="get" action="bbs" class="form-inline mb-3"
          onsubmit="return validateSearch()">
        <input type="text" name="search" id="searchInput"
               class="form-control mr-2" placeholder="Search..."
               oninput="blockSpecialChars(this)"
               value="<%= HtmlUtil.escapeHtml(search != null ? search : "") %>">
        <button type="submit" class="btn btn-primary">Search</button>
    </form>

    <table class="table table-hover">
        <thead>
        <tr>
            <th>Number</th>
            <th>Title</th>
            <th>Author</th>
            <th>Date</th>
        </tr>
        </thead>
        <tbody>
        <% if (list == null || list.isEmpty()) { %>
        <tr>
            <td colspan="4" class="text-center">검색 결과가 없습니다.</td>
        </tr>
        <% } else {
            for (Bbs b : list) { %>
        <tr>
            <td><%= HtmlUtil.escapeHtml(String.valueOf(b.getBbsID())) %></td>
            <td><a
                    href="view.jsp?bbsID=<%= HtmlUtil.escapeHtml(String.valueOf(b.getBbsID())) %>">
                <%= HtmlUtil.escapeHtml(b.getBbsTitle()) %>
                <% if ("Y".equals(b.getIsSecret())) { %> 🔒 <% } %>
            </a></td>
            <td><%= HtmlUtil.escapeHtml(b.getUserID()) %></td>
            <td><%= HtmlUtil.escapeHtml(
                    b.getBbsDate().substring(0, 11) +
                            b.getBbsDate().substring(11, 13) + "시 " +
                            b.getBbsDate().substring(14, 16) + "분"
            ) %></td>
        </tr>
        <% } } %>
        </tbody>
    </table>

    <div class="d-flex justify-content-between">
        <div>
            <% if (pageNumber > 1) { %>
            <a href="bbs?pageNumber=<%= pageNumber - 1 %>&search=<%= HtmlUtil.escapeHtml(search != null ? search : "") %>"
               class="btn btn-secondary">Previous</a>
            <% } %>
            <% if (hasNext != null && hasNext) { %>
            <a href="bbs?pageNumber=<%= pageNumber + 1 %>&search=<%= HtmlUtil.escapeHtml(search != null ? search : "") %>"
               class="btn btn-secondary">Next</a>
            <% } %>
        </div>
        <a href="write.jsp" class="btn btn-success">Write</a>
    </div>
</div>

<script>
    function confirmDelete() {
        if (confirm("정말로 계정을 삭제하시겠습니까?")) {
            document.getElementById("deleteForm").submit();
        }
        return false;
    }

    const forbiddenPattern = /['"‘“!^@*~:;`\\]/;

    function blockSpecialChars(input) {
        if (forbiddenPattern.test(input.value)) {
            alert("검색어에 금지된 특수문자가 포함되어 있습니다.");
            input.value = input.value.replace(forbiddenPattern, '');
        }
    }

    function validateSearch() {
        const input = document.getElementById("searchInput").value;
        if (forbiddenPattern.test(input)) {
            alert("검색어에 금지된 특수문자가 포함되어 있습니다.");
            return false;
        }
        return true;
    }
</script>

<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
