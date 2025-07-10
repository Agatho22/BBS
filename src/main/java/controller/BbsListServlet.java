package controller;

import bbs.Bbs;
import bbs.BbsDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;

@WebServlet("/bbs")
public class BbsListServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String SPECIAL_CHAR_PATTERN = ".*[\\'\"‘“!^@*~:;`\\\\].*";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");
        request.setAttribute("userID", userID);

        int pageNumber = 1;
        try {
            if (request.getParameter("pageNumber") != null) {
                pageNumber = Integer.parseInt(request.getParameter("pageNumber"));
            }
        } catch (NumberFormatException e) {
            pageNumber = 1;
        }

        String search = request.getParameter("search");

        // XSS 및 특수문자 방지
        if (search != null && search.matches(SPECIAL_CHAR_PATTERN)) {
            request.setAttribute("errorMsg", "검색어에 특수문자는 입력할 수 없습니다.");
            request.setAttribute("bbsList", new ArrayList<Bbs>());
            request.setAttribute("search", search);
            request.setAttribute("pageNumber", pageNumber);
            request.setAttribute("hasNext", false);
            request.getRequestDispatcher("/WEB-INF/views/bbs.jsp").forward(request, response);
            return;
        }

        // try-with-resources 사용해 BbsDAO 자동 close
        try (BbsDAO bbsDAO = new BbsDAO()) {
            ArrayList<Bbs> list = (search != null && !search.trim().isEmpty())
                    ? bbsDAO.searchList(search, pageNumber)
                    : bbsDAO.getList(pageNumber);

            request.setAttribute("bbsList", list);
            request.setAttribute("search", search);
            request.setAttribute("pageNumber", pageNumber);
            request.setAttribute("hasNext", bbsDAO.nextPage(pageNumber + 1));
        }

        // 포워딩
        request.getRequestDispatcher("/WEB-INF/views/bbs.jsp").forward(request, response);
    }
}
