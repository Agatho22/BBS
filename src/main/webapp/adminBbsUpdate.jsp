<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="bbs.Bbs" %>
<%@ page import="bbs.BbsDAO" %>
<%@ page import="user.UserDAO" %>
<%@ page import="util.HtmlUtil" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="org.apache.logging.log4j.Logger, org.apache.logging.log4j.LogManager" %>

<%
out.println("<script>alert('권한이 없습니다.'); location.href='adminBbs.jsp';</script>");
return;
%>

<%
Logger logger = LogManager.getLogger("AdminBbsUpdate");

String userID = (String) session.getAttribute("userID");
if (userID == null) {
    response.sendRedirect("login.jsp");
    return;
}

// 관리자 권한 확인
try (UserDAO userDAO = new UserDAO()) {
    if (userDAO.adminCheck(userID) == 0) {
        alertAndRedirect(out, "권한이 없습니다.", "adminBbs.jsp");
        return;
    }
} catch (Exception e) {
    logger.error("관리자 권한 확인 중 예외 발생", e);
    alertAndRedirect(out, "사용자 권한 확인 중 오류 발생", "adminBbs.jsp");
    return;
}

// bbsID 파라미터 확인
int bbsID = 0;
try {
    bbsID = Integer.parseInt(request.getParameter("bbsID"));
    if (bbsID <= 0) throw new NumberFormatException();
} catch (NumberFormatException e) {
    logger.warn("잘못된 bbsID 요청: " + request.getParameter("bbsID"));
    alertAndRedirect(out, "유효하지 않은 글입니다.", "adminBbs.jsp");
    return;
}

// 게시글 가져오기
Bbs bbs;
try (BbsDAO bbsDAO = new BbsDAO()) {
    bbs = bbsDAO.getBbs(bbsID);
    if (bbs == null) {
        logger.info("존재하지 않는 게시글 요청: bbsID=" + bbsID);
        alertAndRedirect(out, "해당 글을 찾을 수 없습니다.", "adminBbs.jsp");
        return;
    }
} catch (Exception e) {
    logger.error("게시글 조회 중 예외 발생", e);
    alertAndRedirect(out, "글 조회 중 오류 발생", "adminBbs.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>관리자</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="css/bootstrap.css">
    <link rel="stylesheet" href="css/custom.css">
</head>
<body>

<nav class="navbar navbar-default">
    <div class="navbar-header">
        <a class="navbar-brand" href="adminMain.jsp">JSP 게시판 웹 사이트</a>
    </div>
    <ul class="nav navbar-nav">
        <li><a href="adminMain.jsp">회원 관리</a></li>
        <li class="active"><a href="adminBbs.jsp">게시판 관리</a></li>
    </ul>
    <ul class="nav navbar-nav navbar-right">
        <li class="dropdown">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">메뉴 <span class="caret"></span></a>
            <ul class="dropdown-menu">
                <li><a class="dropdown-item" href="logoutAction">로그아웃</a></li>
            </ul>
        </li>
    </ul>
</nav>

<div class="container">
    <div class="row">
        <form method="post" action="updateAdminBbs" enctype="multipart/form-data">
            <table class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
                <thead>
                    <tr>
                        <th colspan="2" style="background-color: #eeeeee;">게시판 수정</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <input type="text" class="form-control" placeholder="제 목" name="bbsTitle" maxlength="50"
                                   value="<%= HtmlUtil.escapeHtml(bbs.getBbsTitle()) %>">
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <textarea class="form-control" placeholder="내 용" name="bbsContent" maxlength="2048"
                                      style="height: 350px;"><%= HtmlUtil.escapeHtml(bbs.getBbsContent()) %></textarea>
                        </td>
                    </tr>
                </tbody>
            </table>
            파일 업로드: <input type="file" name="file"><br>
            <input type="hidden" name="bbsID" value="<%= bbsID %>">
            <input type="submit" class="btn btn-primary pull-right" value="완료">
        </form>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script src="js/bootstrap.js"></script>
</body>
</html>
