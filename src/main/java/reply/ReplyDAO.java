package reply;

import java.sql.*;

public class ReplyDAO {

    private static final Logger logger = LogManager.getLogger(ReplyDAO.class);

    public int write(int bbsID, String userID, String content) {
        String sql = "INSERT INTO REPLY (bbsID, userID, replyContent) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, bbsID);
            pstmt.setString(2, userID);
            pstmt.setString(3, content);
            return pstmt.executeUpdate();

        } catch (SQLException e) {
            logger.error("댓글 등록 중 SQL 오류: bbsID={}, userID={}", bbsID, userID, e);
        } catch (Exception e) {
            logger.error("댓글 등록 중 알 수 없는 오류 발생", e);
        }
        return -1;
    }

    public List<Reply> getList(int bbsID) {
        List<Reply> list = new ArrayList<>();
        String sql = "SELECT * FROM REPLY WHERE bbsID = ? AND isDeleted = 0 ORDER BY replyDate ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, bbsID);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Reply r = new Reply(
                        rs.getInt("replyID"),
                        rs.getInt("bbsID"),
                        rs.getString("userID"),
                        rs.getString("replyContent"),
                        rs.getTimestamp("replyDate")
                    );
                    list.add(r);
                }
            }

        } catch (SQLException e) {
            logger.error("댓글 목록 조회 중 SQL 오류: bbsID={}", bbsID, e);
        } catch (Exception e) {
            logger.error("댓글 목록 조회 중 알 수 없는 오류 발생", e);
        }
        return list;
    }

    public boolean delete(int replyID) {
        String SQL = "DELETE FROM REPLY WHERE replyID = ?";
        try (Connection conn = getConnection();
            PreparedStatement pstmt = conn.prepareStatement(SQL)) {

            pstmt.setInt(1, replyID);
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLIntegrityConstraintViolationException e) {
            logger.warn("무결성 제약 조건 위반: replyID = {}", replyID, e);
            throw new DataAccessException("무결성 제약 조건 위반: 댓글 삭제 실패", e);

        } catch (SQLSyntaxErrorException e) {
            logger.error("SQL 문법 오류 발생: {}", SQL, e);
            throw new DataAccessException("SQL 문법 오류 발생", e);

        } catch (SQLException e) {
            logger.error("SQL 예외 발생: replyID = {}", replyID, e);
            throw new DataAccessException("SQL 처리 중 오류 발생", e);

        } catch (Exception e) {
            logger.fatal("알 수 없는 예외 발생: replyID = {}", replyID, e);
            throw new DataAccessException("댓글 삭제 중 예기치 못한 오류 발생", e);
        }
    }

}
