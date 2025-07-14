<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%
    String userID = (String) session.getAttribute("userID");
%>

<nav class="navbar navbar-expand-lg navbar-light">
	<a class="navbar-brand" href="main.jsp">JSP Board</a>
	<button class="navbar-toggler" type="button" data-toggle="collapse"
		data-target="#navbarNav" aria-controls="navbarNav"
		aria-expanded="false" aria-label="Toggle navigation">
		<span class="navbar-toggler-icon"></span>
	</button>

	<div class="collapse navbar-collapse" id="navbarNav">
		<ul class="navbar-nav mr-auto">
			<li class="nav-item active"><a class="nav-link" href="main.jsp">Home</a></li>
			<li class="nav-item active"><a class="nav-link" href="bbs">Board</a></li>
		</ul>
		<ul class="navbar-nav ml-auto">
			<% if (userID == null) { %>
			<li class="nav-item dropdown"><a
				class="nav-link dropdown-toggle" href="#" id="navbarDropdown"
				role="button" data-toggle="dropdown" aria-haspopup="true"
				aria-expanded="false">Sign In</a>
				<div class="dropdown-menu" aria-labelledby="navbarDropdown">
					<a class="dropdown-item" href="login.jsp">Login</a>
				</div></li>
			<% } else { %>
			<li class="nav-item dropdown"><a
				class="nav-link dropdown-toggle" href="#" id="navbarDropdown"
				role="button" data-toggle="dropdown" aria-haspopup="true"
				aria-expanded="false">Account</a>
				<div class="dropdown-menu" aria-labelledby="navbarDropdown">
					<a class="dropdown-item" href="/logoutAction">Logout</a> <a
						class="dropdown-item" href="changePassword.jsp">Change
						Password</a>

					<form id="deleteForm" method="post" action="deleteUser"
						style="display: inline;">
						<input type="hidden" name="userID"
							value="<%= HtmlUtil.escapeHtml(userID) %>"> 
							<input type="hidden" name="csrfToken"
							value="<%= session.getAttribute("csrfToken") %>">
						<button type="submit" class="dropdown-item"
							onclick="return confirm('정말로 계정을 삭제하시겠습니까?');">Delete ID
						</button>
					</form>
				</div></li>
			<% } %>
		</ul>
	</div>
</nav>
