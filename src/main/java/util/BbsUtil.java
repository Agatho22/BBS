package util;

import bbs.Bbs;
import bbs.BbsDAO;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;

public class BbsUtil {

    public static Bbs validateAndGetBbs(HttpServletRequest request, HttpServletResponse response, String userID) throws Exception {
        String bbsIDParam = request.getParameter("bbsID");
        int bbsID;

        try {
            bbsID = Integer.parseInt(bbsIDParam);
        } catch (Exception e) {
            alertAndRedirect(response, "유효하지 않은 글입니다.", "bbs.jsp");
            return null;
        }

        Bbs bbs;
        try (BbsDAO dao = new BbsDAO()) {
            bbs = dao.getBbs(bbsID);
        }

        if (bbs == null) {
            alertAndRedirect(response, "존재하지 않는 글입니다.", "bbs.jsp");
            return null;
        }

        if ("Y".equals(bbs.getIsSecret()) &&
                (userID == null || !(userID.equals(bbs.getUserID()) || userID.equals("admin")))) {
            alertBack(response, "잘못된 접근입니다.");
            return null;
        }

        return bbs;
    }

    private static void alertAndRedirect(HttpServletResponse response, String msg, String to) throws Exception {
        response.setContentType("text/html;charset=UTF-8");
        @SuppressWarnings("resource")
        PrintWriter out = response.getWriter();
        out.println("<script>alert('" + msg + "'); location.href='" + to + "';</script>");
        out.flush(); // 명시적 flush (close는 하지 않음)
    }

    private static void alertBack(HttpServletResponse response, String msg) throws Exception {
        response.setContentType("text/html;charset=UTF-8");
        @SuppressWarnings("resource")
        PrintWriter out = response.getWriter();
        out.println("<script>alert('" + msg + "'); history.back();</script>");
        out.flush();
    }
}
