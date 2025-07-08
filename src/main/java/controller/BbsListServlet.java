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

    // 직렬화 버전 UID (클래스 버전 식별자 역할)
    private static final long serialVersionUID = 1L;

    // 클라이언트 입력값에 포함되면 안 되는 특수문자 정규표현식 (XSS·SQLi 등 방지 목적)
    private static final String SPECIAL_CHAR_PATTERN = ".*[\\'\"‘“!^@*~:;`\\\\].*";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 로그인한 사용자 정보 전달 (JSP에서 출력 시 사용)
        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");
        request.setAttribute("userID", userID);

        // 페이지 번호 처리
        int pageNumber = 1;
        try {
            if (request.getParameter("pageNumber") != null) {
                pageNumber = Integer.parseInt(request.getParameter("pageNumber"));
            }
        } catch (NumberFormatException e) {
            pageNumber = 1;
        }

        // 검색어 입력 처리
        String search = request.getParameter("search");

        // [서버 측 XSS 방지] 검색어에 XSS에 사용될 수 있는 특수문자가 포함되어 있는지 확인
        if (search != null && search.matches(SPECIAL_CHAR_PATTERN)) {
            // 검색어에 금지된 특수문자가 포함된 경우 사용자에게 오류 메시지 전달
            request.setAttribute("errorMsg", "검색어에 특수문자는 입력할 수 없습니다.");

            // 빈 목록 전달 (오류가 난 경우에는 검색 결과 없음)
            request.setAttribute("bbsList", new ArrayList<Bbs>());

            // 입력값 유지
            request.setAttribute("search", search);
            request.setAttribute("pageNumber", pageNumber);
            request.setAttribute("hasNext", false);

            // bbs.jsp로 포워딩
            request.getRequestDispatcher("/WEB-INF/views/bbs.jsp").forward(request, response);
            return;
        }

        // DB에서 검색 또는 목록 조회
        BbsDAO bbsDAO = new BbsDAO();
        ArrayList<Bbs> list = (search != null && !search.trim().isEmpty())
                ? bbsDAO.searchList(search, pageNumber)
                : bbsDAO.getList(pageNumber);

        // JSP에서 사용할 데이터 설정
        request.setAttribute("bbsList", list);
        request.setAttribute("search", search);
        request.setAttribute("pageNumber", pageNumber);
        request.setAttribute("hasNext", bbsDAO.nextPage(pageNumber + 1));

        // JSP로 포워딩
        request.getRequestDispatcher("/WEB-INF/views/bbs.jsp").forward(request, response);
    }
}
