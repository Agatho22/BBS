package file;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Properties;
import java.util.ArrayList;
import java.io.InputStream; // ⚠️ 사용하는 경우만 유지

public class FileDAO {
    private Connection conn;

    public FileDAO() {
        try {
            // db.properties 파일 로딩
            Properties props = new Properties();
            InputStream input = getClass().getClassLoader().getResourceAsStream("db.properties");
            props.load(input);

            // 설정값 읽기
            String driver = props.getProperty("db.driver");
            String url = props.getProperty("db.url");
            String username = props.getProperty("db.username");
            String password = props.getProperty("db.password");

            // JDBC 연결
            Class.forName(driver);
            conn = DriverManager.getConnection(url, username, password);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // bbsID가 BBS 테이블에 존재하는지 확인
    private boolean isBbsIDExists(int bbsID) {
        String SQL = "SELECT COUNT(*) FROM BBS WHERE bbsID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setInt(1, bbsID);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

 // 파일 업로드
 // 파라미터
 //fileName - 업로드된 파일의 원래 이름(보여지는 이름)
 //fileRealName - 서버에 저장된 실제 파일명(보통 UUID 등으로 변환된 이름)
 //bbsID - 파일이 연결될 게시글의 ID
 // 반환값: 성공 시 1 이상 (삽입된 행 수), 실패 시 -1
 public int upload(String fileName, String fileRealName, int bbsID) {
     // 게시글 ID가 실제 존재하는지 확인
     if (!isBbsIDExists(bbsID)) {
         System.out.println("bbsID " + bbsID + " does not exist in BBS table.");
         return -1; // 존재하지 않으면 업로드 불가
     }

     // FileBbsMapping 테이블에 파일 정보 삽입
     String SQL = "INSERT INTO FileBbsMapping (fileName, fileRealName, bbsID) VALUES (?, ?, ?)";
     try (PreparedStatement pstmt = conn.prepareStatement(SQL)) {
         pstmt.setString(1, fileName);       // 사용자에게 보여질 파일명
         pstmt.setString(2, fileRealName);   // 실제 서버에 저장된 파일명
         pstmt.setInt(3, bbsID);             // 연결된 게시글 ID
         return pstmt.executeUpdate();       // 삽입 성공 시 삽입된 행 수 반환
     } catch (Exception e) {
         e.printStackTrace(); // 오류 출력
     }
     return -1; // 예외 발생 또는 실패 시 -1 반환
 }

    // 파일 저장 또는 수정
    public void saveOrUpdate(String fileName, String fileRealName, int bbsID) {
        String checkSQL = "SELECT COUNT(*) FROM FileBbsMapping WHERE bbsID = ?";
        String updateSQL = "UPDATE FileBbsMapping SET fileName = ?, fileRealName = ? WHERE bbsID = ?";
        String insertSQL = "INSERT INTO FileBbsMapping (fileName, fileRealName, bbsID) VALUES (?, ?, ?)";

        try {
            PreparedStatement checkStmt = conn.prepareStatement(checkSQL);
            checkStmt.setInt(1, bbsID);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next() && rs.getInt(1) > 0) {
                PreparedStatement updateStmt = conn.prepareStatement(updateSQL);
                updateStmt.setString(1, fileName);
                updateStmt.setString(2, fileRealName);
                updateStmt.setInt(3, bbsID);
                updateStmt.executeUpdate();
            } else {
                PreparedStatement insertStmt = conn.prepareStatement(insertSQL);
                insertStmt.setString(1, fileName);
                insertStmt.setString(2, fileRealName);
                insertStmt.setInt(3, bbsID);
                insertStmt.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 파일 리스트 반환
    public ArrayList<File> getList(int bbsID) {
        String SQL = "SELECT fileName, fileRealName FROM FileBbsMapping WHERE bbsID = ?";
        ArrayList<File> list = new ArrayList<>();
        try (PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setInt(1, bbsID);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                File file = new File(rs.getString("fileName"), rs.getString("fileRealName"));
                list.add(file);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 특정 bbsID의 파일 이름만 가져오기
    public ArrayList<String> getFileBbsID(int bbsID) {
        ArrayList<String> fileList = new ArrayList<>();
        String query = "SELECT fileRealName FROM FileBbsMapping WHERE bbsID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, bbsID);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                fileList.add(rs.getString("fileRealName"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return fileList;
    }
}
