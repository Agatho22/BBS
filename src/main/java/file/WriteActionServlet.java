package file;

import bbs.BbsDAO;
import user.UserDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.*;

@WebServlet("/file/writeActionServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,  // 1MB
        maxFileSize = 1024 * 1024 * 100,  // 100MB
        maxRequestSize = 1024 * 1024 * 150 // 150MB
)
public class WriteActionServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

    private static final String TEMP_DIR = "/opt/upload/temp";
    private static final String FINAL_DIR = "/opt/upload";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");
        if (userID == null) {
            String contextPath = request.getContextPath();
            out.println("<script>");
            out.println("alert('로그인을 하세요.');");
            out.println("location.href='" + contextPath + "/login.jsp';");
            out.println("</script>");
            return;
        }

        // 디렉토리 생성
        File tempDir = new File(TEMP_DIR);
        if (!tempDir.exists()) tempDir.mkdirs();
        File finalDir = new File(FINAL_DIR);
        if (!finalDir.exists()) finalDir.mkdirs();

        String bbsTitle = null;
        String bbsContent = null;
        String isSecret = "N";
        String originalFileName = null;
        String storedFileName = null;
        File tempFile = null;
        File finalFile = null;

        try {
            for (Part part : request.getParts()) {
                if (part.getName().equals("bbsTitle")) {
                    bbsTitle = readPartValue(part);
                } else if (part.getName().equals("bbsContent")) {
                    bbsContent = readPartValue(part);
                } else if (part.getName().equals("isSecret")) {
                    isSecret = readPartValue(part);
                } else if (part.getName().equals("file") && part.getSize() > 0) {
                    originalFileName = getFileName(part);
                    String ext = getExtension(originalFileName);

                    List<String> allowedExt = Arrays.asList("jpg", "jpeg", "png", "gif", "pdf", "txt");
                    if (!allowedExt.contains(ext)) {
                        out.println("<script>alert('허용되지 않은 파일 형식입니다.'); history.back();</script>");
                        return;
                    }

                    if (originalFileName.toLowerCase().matches(".*(\\.jsp|\\.php|\\.asp|\\.exe).*")) {
                        out.println("<script>alert('파일명에 허용되지 않은 문자열이 포함되어 있습니다.'); history.back();</script>");
                        return;
                    }

                    storedFileName = UUID.randomUUID().toString() + "." + ext;
                    tempFile = new File(TEMP_DIR, storedFileName);
                    part.write(tempFile.getAbsolutePath());

                    String mimeType = getServletContext().getMimeType(tempFile.getAbsolutePath());
                    if (mimeType == null || !mimeType.startsWith("image/")) {
                        tempFile.delete();
                        out.println("<script>alert('이미지 파일만 업로드 가능합니다.'); history.back();</script>");
                        return;
                    }

                    try (Scanner scanner = new Scanner(tempFile)) {
                        while (scanner.hasNextLine()) {
                            String line = scanner.nextLine().toLowerCase();
                            if (line.contains("<%") || line.contains("java.lang.") || line.contains("request.getparameter") || line.contains("eval(")) {
                                tempFile.delete();
                                out.println("<script>alert('파일 내용에 악성 코드가 포함되어 있습니다.'); history.back();</script>");
                                return;
                            }
                        }
                    }

                    finalFile = new File(FINAL_DIR, storedFileName);
                    Files.move(tempFile.toPath(), finalFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    finalFile.setExecutable(false, false);
                    finalFile.setReadable(true, false);
                    finalFile.setWritable(true, false);
                }
            }

            if (bbsTitle == null || bbsContent == null || bbsTitle.trim().isEmpty() || bbsContent.trim().isEmpty()) {
                if (finalFile != null) finalFile.delete();
                out.println("<script>alert('입력이 안 된 항목이 있습니다.'); history.back();</script>");
                return;
            }

            // 게시글 저장
            BbsDAO bbsDAO = new BbsDAO();
            int newBbsID = bbsDAO.write(bbsTitle, userID, bbsContent, isSecret);
            if (newBbsID == -1) {
                if (finalFile != null) finalFile.delete();
                out.println("<script>alert('글 작성 실패'); history.back();</script>");
                return;
            }

            // 파일 정보 저장
            if (originalFileName != null && storedFileName != null) {
                FileDAO fileDAO = new FileDAO();
                int fileResult = fileDAO.upload(originalFileName, storedFileName, newBbsID);
                if (fileResult <= 0) {
                    if (finalFile != null) finalFile.delete();
                    out.println("<script>alert('파일 저장 실패'); history.back();</script>");
                    return;
                }
            }

            // 관리자 여부 확인
            UserDAO userDAO = new UserDAO();
            boolean isAdmin = (userDAO.adminCheck(userID) != 0);

            String contextPath = request.getContextPath();
            out.println("<script>");
            out.println("alert('글 작성 완료');");
            out.println("location.href='" + (isAdmin ? contextPath + "/adminBbs.jsp" : contextPath + "/bbs") + "';");
            out.println("</script>");
            
        } catch (Exception e) {
            e.printStackTrace();
            if (finalFile != null) finalFile.delete();
            out.println("<script>alert('오류가 발생했습니다.'); history.back();</script>");
        }
    }

    private String readPartValue(Part part) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(part.getInputStream(), "UTF-8"));
        StringBuilder value = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) value.append(line);
        return value.toString();
    }

    private String getFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header != null) {
            for (String content : header.split(";")) {
                if (content.trim().startsWith("filename")) {
                    return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
                }
            }
        }
        return null;
    }

    private String getExtension(String filename) {
        return filename.substring(filename.lastIndexOf(".") + 1).toLowerCase();
    }
}
