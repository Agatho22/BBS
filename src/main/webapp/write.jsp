<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.UUID" %>
<%@ page import="bbs.BbsDAO" %>
<%
    String csrfToken = UUID.randomUUID().toString();
    session.setAttribute("csrfToken", csrfToken);
    String userID = (String) session.getAttribute("userID");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>게시판 작성</title>

    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:400,700&display=swap">
    <link rel="stylesheet" href="css/write_style.css">

</head>
<body>

<jsp:include page="includes/user_nav.jsp" />

<div class="container mt-5">
    <form method="post" action="file/writeActionServlet" enctype="multipart/form-data">
        <!-- CSRF 토큰 -->
        <input type="hidden" name="csrfToken" value="<%=csrfToken%>">

        <table class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
            <thead>
                <tr>
                    <th colspan="2">게시판 작성</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><input type="text" class="form-control" placeholder="제 목" name="bbsTitle" maxlength="50" required></td>
                </tr>
                <tr>
                    <td>
                        <textarea class="form-control" placeholder="내 용" name="bbsContent" maxlength="2048" style="height: 350px;" required></textarea>
                    </td>
                </tr>
                <tr>
                    <td style="text-align: left;">
                        <input type="checkbox" name="isSecret" value="Y"> 비밀글로 설정
                    </td>
                </tr>
            </tbody>
        </table>

        <!-- 드래그 앤 드롭 영역 -->
        <div class="form-group">
            <label>첨부파일</label>
            <div id="drop-zone">
                <p>여기에 마우스로 파일을 끌어다 놓을 수 있습니다.</p>
                <input type="file" name="file" id="fileInput" style="display: none;" accept="image/*">
                <button type="button" class="btn btn-danger" onclick="document.getElementById('fileInput').click();">+ 파일선택</button>
                <p id="fileName" class="mt-2 text-muted"></p>
                <div id="file-preview"></div>
            </div>
        </div>

        <div class="button-group text-right">
            <input type="submit" class="btn btn-primary" value="작성 완료">
        </div>
    </form>
</div>

<!-- JavaScript -->
<script>
    const dropZone = document.getElementById("drop-zone");
    const fileInput = document.getElementById("fileInput");
    const fileNameDisplay = document.getElementById("fileName");
    const preview = document.getElementById("file-preview");

    // 기본 이벤트 제거
    ["dragenter", "dragover", "dragleave", "drop"].forEach(eventName => {
        dropZone.addEventListener(eventName, e => e.preventDefault(), false);
        dropZone.addEventListener(eventName, e => e.stopPropagation(), false);
    });

    // 스타일 처리
    ["dragenter", "dragover"].forEach(eventName => {
        dropZone.addEventListener(eventName, () => dropZone.classList.add("bg-light"), false);
    });
    ["dragleave", "drop"].forEach(eventName => {
        dropZone.addEventListener(eventName, () => dropZone.classList.remove("bg-light"), false);
    });

    // 파일 드롭 시 처리
    dropZone.addEventListener("drop", e => {
        const files = e.dataTransfer.files;
        if (files.length > 0) {
            fileInput.files = files;
            handleFilePreview(files[0]);
        }
    });

    // 수동 선택 시 처리
    fileInput.addEventListener("change", () => {
        if (fileInput.files.length > 0) {
            handleFilePreview(fileInput.files[0]);
        }
    });

    function handleFilePreview(file) {
        fileNameDisplay.textContent = `선택된 파일: ${file.name}`;
        preview.innerHTML = "";

        if (file.type.startsWith("image/")) {
            const reader = new FileReader();
            reader.onload = function(e) {
                const img = document.createElement("img");
                img.src = e.target.result;
                preview.appendChild(img);
            };
            reader.readAsDataURL(file);
        } else {
            preview.textContent = "이미지 파일만 미리보기가 지원됩니다.";
        }
    }
</script>

<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
