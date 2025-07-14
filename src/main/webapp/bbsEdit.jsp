<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>게시글 수정</title>
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet" href="css/update_style.css">
</head>
<body>

	<jsp:include page="includes/dark_nav.jsp" />

	<%
    Bbs bbs = (Bbs) request.getAttribute("bbs");
    if (bbs == null) {
%>
	<script>
        alert("유효하지 않은 요청입니다.");
        location.href = "bbs.jsp";
    </script>
	<%
        return;
    }
%>

	<div class="container my-5">
		<div class="row justify-content-center">
			<div class="col-md-8">
				<div class="card">
					<div class="card-header text-center">
						<h5>게시글 수정</h5>
					</div>
					<div class="card-body">
						<form method="post" action="bbsupdateAction"
							enctype="multipart/form-data">
							<div class="form-group">
								<label for="bbsTitle">제목</label> <input type="text"
									class="form-control" id="bbsTitle" name="bbsTitle"
									placeholder="제 목" maxlength="50"
									value="<%= bbs.getBbsTitle() %>">
							</div>
							<div class="form-group">
								<label for="bbsContent">내용</label>
								<textarea class="form-control" id="bbsContent" name="bbsContent"
									placeholder="내 용" maxlength="2048" style="height: 350px;"><%= bbs.getBbsContent() %></textarea>
							</div>
							<div class="form-group">
								<label for="fileUpload">파일 업로드</label> <input type="file"
									class="form-control-file" id="fileUpload" name="file">
							</div>
							<input type="hidden" name="bbsID" value="<%= bbs.getBbsID() %>">
							<button type="submit" class="btn btn-primary float-right">수정
								완료</button>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>

	<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
	<script
		src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
