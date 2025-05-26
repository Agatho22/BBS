package bbs;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class BbsDAO {

    private Connection conn;
    private PreparedStatement pstmt;
    private ResultSet rs;

    public BbsDAO() {
        try {
            String dbURL = "jdbc:mysql://localhost:3306/BBS?serverTimezone=UTC";
            String dbID = "root";
            String dbPassword = "1234";
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, dbID, dbPassword);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Bbs getBbs(int bbsID) {
        String SQL = "SELECT * FROM BBS WHERE bbsID = ?";
        try {
            PreparedStatement pstmt = conn.prepareStatement(SQL);
            pstmt.setInt(1, bbsID);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                Bbs bbs = new Bbs();
                bbs.setBbsID(rs.getInt("bbsID"));
                bbs.setBbsTitle(rs.getString("bbsTitle"));
                bbs.setUserID(rs.getString("userID"));
                bbs.setBbsDate(rs.getString("bbsDate"));
                bbs.setBbsContent(rs.getString("bbsContent"));
                bbs.setBbsAvailable(rs.getInt("bbsAvailable"));
                bbs.setIsSecret(rs.getString("isSecret")); // 비밀글 여부
                return bbs;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 수정된 write 메서드 (isSecret 포함)
    public int write(String bbsTitle, String userID, String bbsContent, String isSecret) {
        String SQL = "INSERT INTO BBS (bbsID, bbsTitle, userID, bbsDate, bbsContent, bbsAvailable, isSecret) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try {
            int nextID = getNext();
            PreparedStatement pstmt = conn.prepareStatement(SQL);
            pstmt.setInt(1, nextID);
            pstmt.setString(2, bbsTitle);
            pstmt.setString(3, userID);
            pstmt.setString(4, getDate());
            pstmt.setString(5, bbsContent);
            pstmt.setInt(6, 1); // bbsAvailable
            pstmt.setString(7, isSecret); // Y or N
            pstmt.executeUpdate();
            return nextID;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public int delete(int bbsID) {
        String SQL = "UPDATE BBS SET bbsAvailable = 0 WHERE bbsID = ?";
        try {
            PreparedStatement pstmt = conn.prepareStatement(SQL);
            pstmt.setInt(1, bbsID);
            return pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public int update(int bbsID, String bbsTitle, String bbsContent) {
        String SQL = "UPDATE BBS SET bbsTitle = ?, bbsContent = ? WHERE bbsID = ?";
        try {
            PreparedStatement pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, bbsTitle);
            pstmt.setString(2, bbsContent);
            pstmt.setInt(3, bbsID);
            return pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public String getRealName(int bbsID) {
        String SQL = "SELECT fileRealName FROM FileBbsMapping WHERE bbsID = ?";
        try {
            PreparedStatement pstmt = conn.prepareStatement(SQL);
            pstmt.setInt(1, bbsID);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getString("fileRealName");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    public String getDate() {
        String SQL = "SELECT NOW()";
        try {
            PreparedStatement pstmt = conn.prepareStatement(SQL);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getString(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    public ArrayList<Bbs> getList(int pageNumber) {
        String SQL = "SELECT * FROM BBS WHERE bbsID < ? AND bbsAvailable = 1 ORDER BY bbsID DESC LIMIT 10";
        ArrayList<Bbs> list = new ArrayList<Bbs>();
        try {
            PreparedStatement pstmt = conn.prepareStatement(SQL);
            pstmt.setInt(1, getNext() - (pageNumber - 1) * 10);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Bbs bbs = new Bbs();
                bbs.setBbsID(rs.getInt("bbsID"));
                bbs.setBbsTitle(rs.getString("bbsTitle"));
                bbs.setUserID(rs.getString("userID"));
                bbs.setBbsDate(rs.getString("bbsDate"));
                bbs.setBbsContent(rs.getString("bbsContent"));
                bbs.setBbsAvailable(rs.getInt("bbsAvailable"));
                bbs.setIsSecret(rs.getString("isSecret"));
                list.add(bbs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getNext() {
        String SQL = "SELECT bbsID FROM BBS ORDER BY bbsID DESC";
        try {
            PreparedStatement pstmt = conn.prepareStatement(SQL);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) + 1;
            }
            return 1;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean nextPage(int pageNumber) {
        String SQL = "SELECT * FROM BBS WHERE bbsID < ? AND bbsAvailable = 1";
        try {
            PreparedStatement pstmt = conn.prepareStatement(SQL);
            pstmt.setInt(1, getNext() - (pageNumber - 1) * 10);
            rs = pstmt.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public Bbs findBbs(int bbsID) {
        Bbs bbs = null;
        String SQL = "SELECT * FROM BBS WHERE bbsID = ?";
        try {
            pstmt = conn.prepareStatement(SQL);
            pstmt.setInt(1, bbsID);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                bbs = new Bbs();
                bbs.setBbsID(rs.getInt("bbsID"));
                bbs.setBbsTitle(rs.getString("bbsTitle"));
                bbs.setUserID(rs.getString("userID"));
                bbs.setBbsContent(rs.getString("bbsContent"));
                bbs.setBbsAvailable(rs.getInt("bbsAvailable"));
                bbs.setIsSecret(rs.getString("isSecret"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return bbs;
    }

    public ArrayList<Integer> findBbsID(String userID) {
        ArrayList<Integer> list = new ArrayList<>();
        String SQL = "SELECT bbsID FROM BBS WHERE userID = ?";
        try {
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, userID);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(rs.getInt("bbsID"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getMaxBbsID() {
        int maxBbsID = 0;
        String SQL = "SELECT COALESCE(MAX(bbsID), 0) AS maxBbsID FROM BBS";
        try (
            PreparedStatement pstmt = conn.prepareStatement(SQL);
            ResultSet rs = pstmt.executeQuery()
        ) {
            if (rs.next()) {
                maxBbsID = rs.getInt("maxBbsID");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return maxBbsID;
    }

    public ArrayList<Bbs> searchList(String keyword, int pageNumber) {
        ArrayList<Bbs> list = new ArrayList<>();
        String SQL = "SELECT * FROM BBS WHERE bbsAvailable = 1 AND bbsTitle LIKE ? AND bbsID < ? ORDER BY bbsID DESC LIMIT 10";
        try {
            PreparedStatement pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, "%" + keyword + "%");
            pstmt.setInt(2, getNext() - (pageNumber - 1) * 10);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Bbs bbs = new Bbs();
                bbs.setBbsID(rs.getInt("bbsID"));
                bbs.setBbsTitle(rs.getString("bbsTitle"));
                bbs.setUserID(rs.getString("userID"));
                bbs.setBbsDate(rs.getString("bbsDate"));
                bbs.setBbsContent(rs.getString("bbsContent"));
                bbs.setBbsAvailable(rs.getInt("bbsAvailable"));
                bbs.setIsSecret(rs.getString("isSecret"));
                list.add(bbs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
