package file;

import bbs.BbsDAO;
import user.UserDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.*;
import java.io.File;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@WebServlet("/file/writeActionServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,  // 1MB
        maxFileSize = 1024 * 1024 * 100,  // 100MB
        maxRequestSize = 1024 * 1024 * 150 // 150MB
)
public class WriteActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = LogManager.getLogger(WriteActionServlet.class);

    private static final String TEMP_DIR = "/opt/upload/temp";
    private static final String FINAL_DIR = "/opt/upload";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");
        if (userID == null) {
            redirectWithAlert(response, "로그인이 필요합니다.", "login.jsp");
            return;
        }

        synchronized (this) {
            new File(TEMP_DIR).mkdirs();
            new File(FINAL_DIR).mkdirs();
        }

        String bbsTitle = null;
        String bbsContent = null;
        String isSecret = "N";
        String originalFileName = null;
        String storedFileName = null;
        File finalFile = null;

        try {
            for (Part part : request.getParts()) {
                switch (part.getName()) {
                    case "bbsTitle":
                        bbsTitle = readPartValue(part);
                        break;
                    case "bbsContent":
                        bbsContent = readPartValue(part);
                        break;
                    case "isSecret":
                        isSecret = readPartValue(part);
                        break;
                    case "file":
                        if (part.getSize() > 0) {
                            originalFileName = getFileName(part);
                            String ext = getExtension(originalFileName);

                            List<String> allowedExt = Arrays.asList("jpg", "jpeg", "png", "gif", "pdf", "txt");
                            if (!allowedExt.contains(ext)) {
                                redirectWithAlert(response, "허용되지 않은 파일 형식입니다.", null);
                                return;
                            }

                            if (originalFileName.toLowerCase().matches(".*(\\.jsp|\\.php|\\.asp|\\.exe).*")) {
                                redirectWithAlert(response, "파일명에 허용되지 않은 문자열이 포함되어 있습니다.", null);
                                return;
                            }

                            storedFileName = UUID.randomUUID().toString() + "." + ext;
                            File tempFile = new File(TEMP_DIR, storedFileName);
                            part.write(tempFile.getAbsolutePath());

                            String mimeType = getServletContext().getMimeType(tempFile.getAbsolutePath());
                            if (mimeType == null || !mimeType.startsWith("image/")) {
                                tempFile.delete();
                                redirectWithAlert(response, "이미지 파일만 업로드 가능합니다.", null);
                                return;
                            }

                            try (Scanner scanner = new Scanner(tempFile)) {
                                while (scanner.hasNextLine()) {
                                    String line = scanner.nextLine().toLowerCase();
                                    if (line.contains("<%") || line.contains("java.lang.") ||
                                            line.contains("request.getparameter") || line.contains("eval(")) {
                                        tempFile.delete();
                                        redirectWithAlert(response, "파일 내용에 악성 코드가 포함되어 있습니다.", null);
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
                        break;
                }
            }

            if (bbsTitle == null || bbsContent == null || bbsTitle.trim().isEmpty() || bbsContent.trim().isEmpty()) {
                if (finalFile != null) finalFile.delete();
                redirectWithAlert(response, "입력되지 않은 항목이 있습니다.", null);
                return;
            }

            try (BbsDAO bbsDAO = new BbsDAO()) {
                int newBbsID = bbsDAO.write(bbsTitle, userID, bbsContent, isSecret);
                if (newBbsID == -1) {
                    if (finalFile != null) finalFile.delete();
                    redirectWithAlert(response, "글 작성 실패", null);
                    return;
                }

                if (originalFileName != null && storedFileName != null) {
                    try (FileDAO fileDAO = new FileDAO()) {
                        int result = fileDAO.upload(originalFileName, storedFileName, newBbsID);
                        if (result <= 0) {
                            if (finalFile != null) finalFile.delete();
                            redirectWithAlert(response, "파일 저장 실패", null);
                            return;
                        }
                    }
                }

                try (UserDAO userDAO = new UserDAO()) {
                    boolean isAdmin = (userDAO.adminCheck(userID) != 0);
                    redirectWithAlert(response, "글 작성이 완료되었습니다.", isAdmin ? "adminBbs.jsp" : "bbs");
                }
            }

        } catch (Exception e) {
            logger.error("파일 업로드 처리 중 오류 발생: {}", e.toString());
            if (finalFile != null) finalFile.delete();
            redirectWithAlert(response, "일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요.", null);
        }
    }

    private void redirectWithAlert(HttpServletResponse response, String message, String location) throws IOException {
        try (PrintWriter out = response.getWriter()) {
            out.println("<script>alert('" + escapeJs(message) + "');");
            if (location != null) {
                out.println("location.href='" + location + "';");
            } else {
                out.println("history.back();");
            }
            out.println("</script>");
        }
    }

    private String readPartValue(Part part) throws IOException {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(part.getInputStream(), "UTF-8"))) {
            StringBuilder value = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) value.append(line);
            return value.toString();
        }
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
        int dotIndex = filename.lastIndexOf(".");
        return (dotIndex != -1) ? filename.substring(dotIndex + 1).toLowerCase() : "";
    }

    private String escapeJs(String s) {
        return s.replace("'", "\\'").replace("\"", "\\\"");
    }
}
