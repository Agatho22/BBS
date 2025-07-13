package file;

import bbs.Bbs;
import bbs.BbsDAO;
import user.UserDAO;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import javax.servlet.ServletException;
import java.io.PrintWriter;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import javax.servlet.http.*;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.*;

@WebServlet("/file/writeActionServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 1024 * 1024 * 100,
        maxRequestSize = 1024 * 1024 * 150
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

        try (PrintWriter out = response.getWriter()) {

            if (userID == null) {
                redirectWithAlert(out, request.getContextPath() + "/login.jsp", "로그인을 하세요.");
                return;
            }

            createDirIfNotExists(TEMP_DIR);
            createDirIfNotExists(FINAL_DIR);

            String bbsTitle = null;
            String bbsContent = null;
            String isSecret = "N";
            String originalFileName = null;
            String storedFileName = null;
            File finalFile = null;

            for (Part part : request.getParts()) {
                String fieldName = part.getName();
                if (fieldName.equals("bbsTitle")) {
                    bbsTitle = readPartValue(part);
                } else if (fieldName.equals("bbsContent")) {
                    bbsContent = readPartValue(part);
                } else if (fieldName.equals("isSecret")) {
                    isSecret = readPartValue(part);
                } else if (fieldName.equals("file") && part.getSize() > 0) {
                    originalFileName = getFileName(part);
                    String ext = getExtension(originalFileName);

                    List<String> allowedExt = Arrays.asList("jpg", "jpeg", "png", "gif", "pdf", "txt");
                    if (!allowedExt.contains(ext) || originalFileName.toLowerCase().matches(".*(\\.jsp|\\.php|\\.asp|\\.exe).*")) {
                        redirectWithAlert(out, null, "허용되지 않은 파일 형식입니다.");
                        return;
                    }

                    storedFileName = UUID.randomUUID().toString() + "." + ext;
                    File tempFile = new File(TEMP_DIR, storedFileName);
                    part.write(tempFile.getAbsolutePath());

                    String mimeType = getServletContext().getMimeType(tempFile.getAbsolutePath());
                    if (mimeType == null || !mimeType.startsWith("image/")) {
                        tempFile.delete();
                        redirectWithAlert(out, null, "이미지 파일만 업로드 가능합니다.");
                        return;
                    }

                    try (Scanner scanner = new Scanner(tempFile)) {
                        while (scanner.hasNextLine()) {
                            String line = scanner.nextLine().toLowerCase();
                            if (line.contains("<%") || line.contains("java.lang.") || line.contains("request.getparameter") || line.contains("eval(")) {
                                tempFile.delete();
                                redirectWithAlert(out, null, "파일에 유해한 코드가 포함되어 있습니다.");
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
                redirectWithAlert(out, null, "입력이 안 된 항목이 있습니다.");
                return;
            }

            try (BbsDAO bbsDAO = new BbsDAO()) {
                Bbs bbs = new Bbs();
                bbs.setBbsTitle(bbsTitle);
                bbs.setUserID(userID);
                bbs.setBbsContent(bbsContent);
                bbs.setIsSecret(isSecret);

                int newBbsID = bbsDAO.write(bbs);
                if (newBbsID == -1) {
                    if (finalFile != null) finalFile.delete();
                    redirectWithAlert(out, null, "글 작성 실패");
                    return;
                }

                if (originalFileName != null && storedFileName != null) {
                    try (FileDAO fileDAO = new FileDAO()) {
                        int result = fileDAO.upload(originalFileName, storedFileName, newBbsID);
                        if (result <= 0) {
                            if (finalFile != null) finalFile.delete();
                            redirectWithAlert(out, null, "파일 저장 실패");
                            return;
                        }
                    }
                }

                try (UserDAO userDAO = new UserDAO()) {
                    boolean isAdmin = (userDAO.adminCheck(userID) != 0);
                    String target = isAdmin ? "/adminBbs.jsp" : "/bbs";
                    redirectWithAlert(out, request.getContextPath() + target, "글 작성 완료");
                }
            }

        } catch (Exception e) {
            logger.error("글 작성 중 예외 발생", e);
            response.getWriter().println("<script>alert('시스템 오류가 발생했습니다.'); history.back();</script>");
        }
    }

    private void redirectWithAlert(PrintWriter out, String location, String message) {
        out.println("<script>");
        out.println("alert('" + message + "');");
        if (location != null) {
            out.println("location.href='" + location + "';");
        } else {
            out.println("history.back();");
        }
        out.println("</script>");
    }

    private void createDirIfNotExists(String path) {
        File dir = new File(path);
        if (!dir.exists()) dir.mkdirs();
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
        for (String content : header.split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }

    private String getExtension(String filename) {
        return filename.substring(filename.lastIndexOf(".") + 1).toLowerCase();
    }
}
