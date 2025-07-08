package bbs;

import file.FileDAO;
import org.apache.commons.io.FilenameUtils;
import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@WebServlet("/bbsUpdateAction")
@MultipartConfig
public class BbsUpdateServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private final String uploadDir = "/opt/upload";
	private static final Logger logger = LogManager.getLogger(BbsUpdateServlet.class);

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");
		response.setContentType("text/html;charset=UTF-8");

		HttpSession session = request.getSession();
		String userID = (String) session.getAttribute("userID");

		if (userID == null) {
			writeAlert(response, "로그인을 해주세요.", "login.jsp");
			return;
		}

		if (!isMultipart(request)) {
			writeAlert(response, "잘못된 요청 형식입니다.", "bbs.jsp");
			return;
		}

		File dir = new File(uploadDir);
		if (!dir.exists()) dir.mkdirs();

		try {
			MultipartRequest multi = new MultipartRequest(
				request, uploadDir, 1024 * 1024 * 100, "UTF-8", new DefaultFileRenamePolicy()
			);
			int bbsID = Integer.parseInt(multi.getParameter("bbsID"));

			try (BbsDAO bbsDAO = new BbsDAO()) {
				Bbs bbs = bbsDAO.getBbs(bbsID);
				if (bbs == null) {
					writeAlert(response, "게시글이 존재하지 않습니다.", "bbs.jsp");
					return;
				}
				boolean isAdmin = "admin".equals(userID);
				if (!userID.equals(bbs.getUserID()) && !isAdmin) {
					writeAlert(response, "권한이 없습니다.", "bbs.jsp");
					return;
				}

				String title = multi.getParameter("bbsTitle");
				String content = multi.getParameter("bbsContent");
				if (title == null || content == null || title.trim().isEmpty() || content.trim().isEmpty()) {
					writeBack(response, "입력이 안 된 항목이 있습니다.");
					return;
				}

				if (bbsDAO.update(bbsID, title, content) == -1) {
					writeBack(response, "게시글 수정에 실패했습니다.");
					return;
				}
			}

			Enumeration<?> files = multi.getFileNames();
			while (files.hasMoreElements()) {
				String param = (String) files.nextElement();
				String fileName = multi.getOriginalFileName(param);
				String fileRealName = multi.getFilesystemName(param);

				if (fileName == null || fileRealName == null)
					continue;

				if (isInvalidFileName(fileRealName)) {
					logger.warn("위험한 파일명 탐지: {}", fileRealName);
					writeBack(response, "위험한 파일명입니다.");
					return;
				}

				if (!isAllowedExtension(fileName)) {
					logger.warn("허용되지 않은 확장자: {}", fileName);
					writeBack(response, "허용되지 않은 파일 형식입니다.");
					return;
				}

				File uploadedFile = new File(uploadDir, FilenameUtils.getName(fileRealName));
				String canonicalDir = dir.getCanonicalPath();
				String canonicalPath = uploadedFile.getCanonicalPath();
				if (!canonicalPath.startsWith(canonicalDir + File.separator)) {
					logger.error("비정상적인 파일 경로 접근 시도: {}", canonicalPath);
					writeBack(response, "파일 경로가 유효하지 않습니다.");
					return;
				}

				try (FileDAO fileDAO = new FileDAO()) {
				    fileDAO.saveOrUpdate(fileName, fileRealName, bbsID);
				} catch (Exception e) {
				    logger.error("파일 처리 중 예외 발생", e);
				    deleteFile(uploadedFile);
				    writeBack(response, "파일 처리 중 오류가 발생했습니다.");
				    return;
				}
			}

			writeAlert(response, "수정이 완료되었습니다.", "bbs.jsp");

		} catch (NumberFormatException e) {
			logger.warn("잘못된 게시글 ID", e);
			writeBack(response, "유효하지 않은 게시글 ID입니다.");
		} catch (IOException e) {
			logger.error("파일 업로드 중 I/O 예외 발생", e);
			writeBack(response, "파일 업로드 중 문제가 발생했습니다.");
		} catch (RuntimeException e) {
			logger.error("런타임 예외 발생", e);
			writeBack(response, "요청 처리 중 오류가 발생했습니다.");
		} catch (Exception e) {
			logger.fatal("게시글 수정 중 알 수 없는 예외 발생", e);
			writeBack(response, "예기치 못한 오류가 발생했습니다. 관리자에게 문의하세요.");
		}
	}

	private boolean isMultipart(HttpServletRequest request) {
		String contentType = request.getContentType();
		return contentType != null && contentType.toLowerCase().startsWith("multipart/");
	}

	private boolean isInvalidFileName(String name) {
		return name == null || name.contains("..") || name.contains("/") || name.contains("\\");
	}

	private boolean isAllowedExtension(String fileName) {
		if (fileName == null) return false;
		int dotIndex = fileName.lastIndexOf(".");
		if (dotIndex == -1 || dotIndex == fileName.length() - 1) return false;
		String ext = fileName.substring(dotIndex + 1).toLowerCase();
		List<String> allowedExt = Arrays.asList("jpg", "jpeg", "png", "pdf", "doc", "hwp", "xls");
		return allowedExt.contains(ext);
	}

	private void deleteFile(File file) {
		try {
			if (!file.delete()) {
				logger.warn("파일 삭제 실패: {}", file.getAbsolutePath());
			}
		} catch (SecurityException e) {
			logger.error("파일 삭제 중 보안 예외 발생: {}", file.getAbsolutePath(), e);
		}
	}

	private void writeAlert(HttpServletResponse response, String msg, String url) throws IOException {
		try (PrintWriter out = response.getWriter()) {
			out.println("<script>alert('" + msg + "'); location.href='" + url + "';</script>");
		}
	}

	private void writeBack(HttpServletResponse response, String msg) throws IOException {
		try (PrintWriter out = response.getWriter()) {
			out.println("<script>alert('" + msg + "'); history.back();</script>");
		}
	}
}
