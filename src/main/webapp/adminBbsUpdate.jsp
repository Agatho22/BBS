<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs"%>
<%@ page import="bbs.BbsDAO"%>
<%@ page import="user.User"%>
<%@ page import="user.UserDAO"%>
<%@ page import="java.io.PrintWriter"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="css/bootstrap.css">
<link rel="stylesheet" href="css/custom.css">
<title>JSP 게시판 웹 사이트</title>
</head>
<body>

	<%
    // 1. 로그인 여부 확인
    String userID = (String) session.getAttribute("userID");

    if (userID == null) {
        // 로그인하지 않은 경우 로그인 페이지로 리디렉션
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. 관리자 권한 확인
    UserDAO userDAO = new UserDAO();
    int adminCheckResult = userDAO.adminCheck(userID);
    if (adminCheckResult == 0) {
        // 관리자가 아니면 접근 차단
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('권한이 없습니다.')");
        script.println("location.href = 'adminBbs.jsp';");
        script.println("</script>");
        script.close();
        return;
    }

    // 3. 게시글 ID 파라미터 유효성 검사
    int bbsID = 0;
    try {
        bbsID = Integer.parseInt(request.getParameter("bbsID"));
    } catch (Exception e) {
        // 숫자가 아닌 값이 들어올 경우
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('유효하지 않은 글입니다.')");
        script.println("location.href = 'adminBbs.jsp';");
        script.println("</script>");
        script.close();
        return;
    }

    if (bbsID == 0) {
        // bbsID가 0이면 잘못된 접근
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('유효하지 않은 글입니다.')");
        script.println("location.href = 'adminBbs.jsp';");
        script.println("</script>");
        script.close();
        return;
    }

    // 4. 게시글 정보 조회
    BbsDAO bbsDAO = new BbsDAO();
    Bbs bbs = bbsDAO.getBbs(bbsID);

    if (bbs == null) {
        // 게시글이 존재하지 않는 경우
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('해당 글을 찾을 수 없습니다.')");
        script.println("location.href = 'adminBbs.jsp';");
        script.println("</script>");
        script.close();
        return;
    }
%>

	<!-- 5. 상단 네비게이션 바 -->
	<nav class="navbar navbar-default">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle collapsed"
				data-toggle="collapse" data-target="#bs-example-navbar-collapse-1"
				aria-expanded="false">
				<span class="icon-bar"></span> <span class="icon-bar"></span> <span
					class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="adminMain.jsp">JSP 게시판 웹 사이트</a>
		</div>
		<div class="collapse navbar-collapse"
			id="bs-example-navbar-collapse-1">
			<ul class="nav navbar-nav">
				<li><a href="adminMain.jsp">회원 관리</a></li>
				<li class="active"><a href="adminBbs.jsp">게시판 관리</a></li>
			</ul>
			<ul class="nav navbar-nav navbar-right">
				<li class="dropdown"><a href="#" class="dropdown-toggle"
					data-toggle="dropdown" role="button" aria-haspopup="true"
					aria-expanded="false"> 메뉴 <span class="caret"></span>
				</a>
					<ul class="dropdown-menu">
						<li><a href="logoutAction.jsp">로그아웃</a></li>
					</ul></li>
			</ul>
		</div>
	</nav>

	<!-- 6. 게시글 수정 폼 -->
	<div class="container">
		<div class="row">
			<form method="post" action="updateAction.jsp"
				enctype="multipart/form-data">
				<table class="table table-striped"
					style="text-align: center; border: 1px solid #dddddd">
					<thead>
						<tr>
							<th colspan="2"
								style="background-color: #eeeeee; text-align: center;">게시판
								수정</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<!-- 제목 입력 필드 (기존 제목 출력) -->
							<td><input type="text" class="form-control"
								placeholder="제 목" name="bbsTitle" maxlength="50"
								value="<%=bbs.getBbsTitle()%>"></td>
						</tr>
						<tr>
							<!-- 내용 입력 필드 (기존 내용 출력 추가 필요 시 아래 코드 사용 가능) -->
							<td><textarea class="form-control" placeholder="내 용"
									name="bbsContent" maxlength="2048" style="height: 350px;"><%=bbs.getBbsContent()%></textarea>
							</td>
						</tr>
					</tbody>
				</table>

				<!-- 파일 첨부 필드 -->
				파일 업로드 <input type="file" name="file"><br>

				<!-- 숨겨진 게시글 ID 전달 -->
				<input type="hidden" name="bbsID" value="<%=bbsID%>">

				<!-- 제출 버튼 -->
				<input type="submit" class="btn btn-primary pull-right" value="완료">
			</form>
		</div>
	</div>

	<!-- 7. 스크립트 로딩 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="js/bootstrap.js"></script>
</body>
</html>
