package file;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Apache Commons IO 사용
import org.apache.commons.io.FilenameUtils;

@WebServlet("/downloadAction")
public class downloadAction extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fileName = request.getParameter("file");

        // 입력값 null 또는 비정상 길이 검사
        if (fileName == null || fileName.length() < 1) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "파일명이 비어있거나 잘못되었습니다.");
            return;
        }

        // 디코딩 (URL 인코딩 우회, 이중 인코딩 대응)
        // 1. 클라이언트가 URL 인코딩한 파일명을 정상 문자열로 복원
        //    예: %2e%2e%2fpasswd → ../passwd
        // 2. 공격자가 %252e%252e 와 같이 이중 인코딩(%25 → %)한 경우도 복원
        //    예: %252e%252e → %2e%2e → ..
        //    따라서 URLDecoder를 두 번 호출해 모든 인코딩 우회 시도를 정상 문자열로 변환시켜 검사 가능하게 함
        String decodedName = URLDecoder.decode(fileName, "UTF-8");
        decodedName = URLDecoder.decode(decodedName, "UTF-8");

        // Apache Commons IO로 파일명만 안전하게 추출 (디렉토리 제거)
        // getName - 디렉터리 부분은 제거하고 파일명만 남김
        // FilenameUtils - 디렉터리 이동 문자열(../)을 포함한 경로 우회 차단 및 탐지
        String safeFileName = FilenameUtils.getName(decodedName);

        // 위험 문자열 필터링 (이중 방어)
        // 파일명 검증을 통해 디렉터리 조작, 특수문자, 제어문자 등을 포함한 악의적 파일명을 차단
        // - ".." : 상위 디렉터리로 탈출 시도 (../etc/passwd 등)
        // - "/" , "\\" : 디렉터리 구분 문자 (경로 조작에 사용됨)
        // - [%\\\\/:*?"<>|] : Windows/Unix에서 허용되지 않거나 위험한 특수문자 (예: 파일 경로 생성, 명령어 주입 등)
        // - [\\x00-\\x1F\\x7F] : 제어문자 (NULL, 백스페이스 등), 로그 위조·우회 시도에 사용될 수 있음
        // → 위 조건에 해당하면 비정상 파일명으로 판단하고 요청을 차단함
        if (safeFileName.contains("..") || safeFileName.contains("/") || safeFileName.contains("\\") ||
            safeFileName.matches(".*[%\\\\/:*?\"<>|].*") ||  // 특수문자
            safeFileName.matches(".*[\\x00-\\x1F\\x7F].*")) {  // 제어문자
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "위험한 파일명입니다.");
            return;
        }

        // 기준 디렉터리 설정 (DocumentRoot 외부 경로)
        // 기준 디렉터리 경로 설정 (웹 루트 외부의 안전한 저장소 위치)
        // - basePath: 허용된 파일 저장 루트 디렉터리 (/opt/upload)
        // - baseDir: 해당 경로를 File 객체로 생성
        // - targetFile: 사용자가 요청한 파일명(safeFileName)을 기준 디렉터리(baseDir)에 결합하여 실제 접근 경로 생성
        //   예: safeFileName이 "report.pdf"이면 /opt/upload/report.pdf
        //   이 방식은 사용자 입력값을 기준 디렉터리에 강제로 결합시켜 허용된 경로 밖으로 나가지 못하게 함
        String basePath = "/opt/upload";
        File baseDir = new File(basePath);
        File targetFile = new File(baseDir, safeFileName);

        // CanonicalPath 비교로 디렉터리 탈출 완전 차단
        // getCanonicalPath() - 실제로 운영체제에서 접근하게 되는 경로
        String canonicalBase = baseDir.getCanonicalPath();
        String canonicalTarget = targetFile.getCanonicalPath();

        if (!canonicalTarget.startsWith(canonicalBase)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "디렉터리 탈출 시도 차단됨");
            return;
        }

        // 파일 존재 여부 확인
        if (!targetFile.exists() || !targetFile.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "파일을 찾을 수 없습니다.");
            return;
        }

        // MIME 타입 설정
        String mimeType = getServletContext().getMimeType(targetFile.getName());
        if (mimeType == null) {
            mimeType = "application/octet-stream";
        }
        response.setContentType(mimeType);

        // 다운로드 파일명 브라우저 호환 인코딩
        String encodedName = URLEncoder.encode(safeFileName, "UTF-8").replaceAll("\\+", "%20");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + encodedName + "\"");

        // 파일 전송
        byte[] buffer = new byte[4096];
        try (FileInputStream fis = new FileInputStream(targetFile);
             ServletOutputStream os = response.getOutputStream()) {
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
            os.flush();
        }
    }
}
