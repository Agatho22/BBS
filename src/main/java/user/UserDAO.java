package user;

import java.sql.*;
import java.security.SecureRandom;
import java.util.Properties;
import java.io.InputStream;
import java.util.ArrayList;
import java.security.MessageDigest;

public class UserDAO {
	private Connection conn;

	// 생성자: db.properties에서 DB 연결 정보 로드
	public UserDAO() {
		try {
			Properties props = new Properties();
			InputStream input = getClass().getClassLoader().getResourceAsStream("db.properties");
			props.load(input);

			String dbURL = props.getProperty("db.url");
			String dbID = props.getProperty("db.username");
			String dbPassword = props.getProperty("db.password");
			String dbDriver = props.getProperty("db.driver");

			Class.forName(dbDriver);
			conn = DriverManager.getConnection(dbURL, dbID, dbPassword);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	// SHA-256 해시 함수
	// SHA-256 해시 함수를 사용하여 입력된 비밀번호를 해시 문자열로 변환
	public String hashSHA256(String password) {
		try {
			// 1. SHA-256 알고리즘을 사용하는 MessageDigest 객체 생성
			MessageDigest md = MessageDigest.getInstance("SHA-256"); // 자바에서 SHA-256 해시 알고리즘을 사용하도록 MessageDigest 객체 생성
			// 2. 비밀번호 문자열을 UTF-8 인코딩으로 바이트 배열로 변환한 뒤, 해시 계산
			byte[] hash = md.digest(password.getBytes("UTF-8")); // password.getBytes("UTF-8") - 입력된 비밀번호 문자열을 UTF-8 방식으로 바이트 배열로 변환
																		// md.digest(...) - 바이트 배열에 대해 SHA-256 해시 계산을 수행하여 바이트 배열 형태의 해시값 반환
			// 3. 바이트 배열을 16진수 문자열로 변환하기 위한 StringBuilder 생성
			StringBuilder sb = new StringBuilder(); // StringBuilder - 문자열 결합을 효율적으로 수행하기 위한 객체
			// 4. 바이트 배열을 순회하면서 각 바이트를 2자리 16진수로 포맷하여 문자열로 누적
			for (byte b : hash) {
				sb.append(String.format("%02x", b)); // String.format("%02x", b) - 각 바이트를 두 자리 16진수(hex)로 변환 (예: 0x0a → "0a")
			}
			 // 5. 최종적으로 생성된 해시 문자열 반환
			return sb.toString(); // sb.toString - 누적된 16진수 문자열 반환
		} catch (Exception e) {
			// 예외 발생 시 스택 트레이스를 출력하고 null 반환
			e.printStackTrace(); // e.printStackTrace() - 예외가 발생한 경우 콘솔에 상세 오류 내용 출력
			return null;
		}
	}

	// 로그인 메서드: 입력된 사용자 ID와 비밀번호를 해시하여 데이터베이스에 저장된 값과 비교
	public int login(String userID, String userPassword) {
	    // SQL 쿼리 작성: 사용자 ID에 해당하는 비밀번호와 salt를 가져오는 쿼리
	    String sql = "SELECT userPassword, salt FROM USER WHERE userID = ?";
	    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
	        // PreparedStatement를 사용해 쿼리에서 사용자 ID를 파라미터로 전달
	        pstmt.setString(1, userID);
	        // SQL 쿼리 실행하여 결과셋(ResultSet) 반환
	        ResultSet rs = pstmt.executeQuery();
	        // 결과셋에서 첫 번째 행을 가져옴 (해당 사용자 ID가 존재하는지 확인)
	        if (rs.next()) {
	            // 데이터베이스에 저장된 해시된 비밀번호 가져오기
	            String dbPassword = rs.getString("userPassword"); // DB에 저장된 해시된 비밀번호
	            // 데이터베이스에 저장된 salt 가져오기
	            String dbSalt = rs.getString("salt"); // DB에 저장된 salt

	            // 입력된 비밀번호와 dbSalt를 결합하여 해시값을 생성
	            // - dbSalt가 null이거나 비어있으면 기존 방식대로(솔트 없음) 해시 생성
	            // - dbSalt가 존재하면, 입력 비밀번호와 함께 salt를 결합하여 해시 생성
	            String inputHash = (dbSalt == null || dbSalt.isEmpty()) ? hashSHA256(userPassword) // 솔트 없는 경우
	                    : getSHA256WithSalt(userPassword, dbSalt); // 솔트 있는 경우
	            // 데이터베이스에 저장된 해시값과 입력값으로 생성한 해시값을 비교
	            return dbPassword.equals(inputHash) ? 1 : 0; // 동일하면 로그인 성공 (1), 아니면 실패 (0)
	        }
	        // 사용자가 존재하지 않으면 아이디 없음 리턴 (-1)
	        return -1; // 아이디 없음
	    } catch (Exception e) {
	        // 예외 발생 시 에러 출력 및 오류 코드 리턴 (-2)
	        e.printStackTrace();
	        return -2; // 기타 에러
	    }
	}
	
	// 계정 잠금 여부 확인
	// 로그인 실패 횟수(loginFailCount)가 3회 이상이고, 마지막 실패 시각(lastFailTime)으로부터 1분이 지나지 않은 경우 '잠금 상태'로 간주
	// 잠금 시간이 경과되면 loginFailCount를 자동으로 초기화하여 잠금 해제
	public boolean isAccountLocked(String userID) {
		String sql = "SELECT loginFailCount, lastFailTime FROM USER WHERE userID = ?";
		try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, userID);												// 사용자 ID 바인딩
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					int failCount = rs.getInt("loginFailCount");					// 로그인 실패 횟수
					Timestamp lastFailTime = rs.getTimestamp("lastFailTime");	// 마지막 실패 시각

					//  실패 횟수 3회 이상이고 마지막 실패 시각이 존재할 경우
					if (failCount >= 3 && lastFailTime != null) {
						long now = System.currentTimeMillis();			// 현재 시간 (ms)
						long diff = now - lastFailTime.getTime();		// 마지막 실패 이후 경과 시간

						// 1분(60,000ms) 이내라면 계정 잠금 상태 유지
						if (diff < 60 * 1000) {
							System.out.println(
									"[isAccountLocked] 잠금 상태: userID=" + userID + ", 남은 시간(ms)=" + (60 * 1000 - diff));
							return true;
						} else {
							// 1분 경과 → 실패 횟수 초기화
							resetFailCount(userID);
							System.out.println("[isAccountLocked] 1분 경과 → 잠금 자동 해제됨: userID=" + userID);
						}
					}
				}
			}
		} catch (Exception e) {
			// 예외 발생 시 로그 출력 (운영 시에는 Logger 사용 권장)
			System.out.println("[isAccountLocked] 예외 발생: " + e.getMessage());
			e.printStackTrace();
		}
		return false; // 잠금 조건을 만족하지 않으면 false 반환 (정상 로그인 시도 가능)
	}


	// 로그인 실패 카운트 초기화
	public void resetFailCount(String userID) {
		String sql = "UPDATE USER SET loginFailCount = 0, lastFailTime = NULL WHERE userID = ?";
		try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, userID); 
			pstmt.executeUpdate();		
		} catch (Exception e) {
			e.printStackTrace(); //Java에서 예외(Exception)가 발생했을 때, 그 예외의 전체 호출 스택(에러의 위치, 원인 등)을 콘솔에 출력하는 디버깅용 메서드
		}
	}

	// 로그인 실패 시 호출되는 메서드로, 사용자 계정의 로그인 실패 횟수를 1 증가시키고 마지막 실패 시간을 기록함
	// - loginFailCount: 누적 로그인 실패 횟수를 나타내는 컬럼
	// - lastFailTime: 마지막 로그인 실패 시각 (계정 잠금 시간 계산 등에 사용됨)
	// - 이 정보는 계정 잠금 정책(예: 3회 실패 시 15분 잠금 등)에 활용됨
	// - PreparedStatement를 사용하여 SQL Injection 방지
	// 로그인 실패 카운트 증가
	public void increaseFailCount(String userID) {
		String sql = "UPDATE USER SET loginFailCount = loginFailCount + 1, lastFailTime = NOW() WHERE userID = ?";
		try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, userID); // 입력받은 userID에 대해 실패 정보 업데이트
			pstmt.executeUpdate(); 		// DB 업데이트 실행
		} catch (Exception e) {
			e.printStackTrace();			// 예외 발생 시 콘솔 출력
											//Java에서 예외(Exception)가 발생했을 때, 그 예외의 전체 호출 스택(에러의 위치, 원인 등)을 콘솔에 출력하는 디버깅용 메서드
		}
	}

	// 관리자 여부 확인
	public int adminCheck(String userID) {
		String sql = "SELECT admin FROM USER WHERE userID = ?";
		try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, userID);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					return rs.getInt("admin");
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	// 전체 사용자 목록 반환
	public ArrayList<User> getUserList() {
		ArrayList<User> list = new ArrayList<>();
		String sql = "SELECT userID, userPassword, userName, userEmail FROM USER";
		try (PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {

			while (rs.next()) {
				User user = new User();
				user.setUserID(rs.getString("userID"));
				user.setUserPassword(rs.getString("userPassword"));
				user.setUserName(rs.getString("userName"));
				user.setUserEmail(rs.getString("userEmail"));
				list.add(user);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	// 회원가입 (비밀번호 해시 저장)
	// 외부에서 해시와 salt를 이미 처리한 경우 사용하는 메서드
	public int join(User user, String salt) {
		String sql = "INSERT INTO USER (userID, userPassword, userName, userEmail, admin, salt, loginFailCount, isLocked, lastFailTime) VALUES (?, ?, ?, ?, 0, ?, 0, FALSE, NULL)";
		try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, user.getUserID());
			pstmt.setString(2, user.getUserPassword()); // 이미 해싱된 비밀번호
			pstmt.setString(3, user.getUserName());
			pstmt.setString(4, user.getUserEmail());
			pstmt.setString(5, salt); // 외부에서 생성한 salt 저장
			return pstmt.executeUpdate();
		} catch (SQLIntegrityConstraintViolationException e) {
			return -1;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return -2;
	}

	// 비밀번호 변경 (SHA-256 + salt 적용)
	public int updatePassword(String userID, String newPassword) {
		String sql = "UPDATE USER SET userPassword = ?, salt = ? WHERE userID = ?";

		try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
			// 1. 솔트 생성
			String salt = generateSalt();

			// 2. SHA-256 + salt 해싱
			String hashedPassword = getSHA256WithSalt(newPassword, salt);

			// 3. DB 저장
			pstmt.setString(1, hashedPassword);
			pstmt.setString(2, salt);
			pstmt.setString(3, userID);
			return pstmt.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}
		return -1;
	}

	// 회원 탈퇴 (비밀번호 해시 비교: 솔트 적용된 계정도 지원)
	public int deleteUser(String userID, String userPassword) {
	    String sql = "SELECT userPassword, salt FROM USER WHERE userID = ?";
	    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
	        pstmt.setString(1, userID);
	        ResultSet rs = pstmt.executeQuery();

	        if (rs.next()) {
	            String dbPassword = rs.getString("userPassword");
	            String salt = rs.getString("salt");

	            String inputHash = (salt == null || salt.isEmpty())
	                ? hashSHA256(userPassword)                         // 기존 방식
	                : getSHA256WithSalt(userPassword, salt);          // 새 방식

	            if (dbPassword.equals(inputHash)) {
	                // 비밀번호 일치 시 삭제 진행
	                String deleteSQL = "DELETE FROM USER WHERE userID = ?";
	                try (PreparedStatement deletePstmt = conn.prepareStatement(deleteSQL)) {
	                    deletePstmt.setString(1, userID);
	                    return deletePstmt.executeUpdate();
	                }
	            } else {
	                return 0; // 비밀번호 불일치
	            }
	        } else {
	            return -1; // 사용자 없음
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	        return -2; // 기타 오류
	    }
	}

	// 관리자용: 사용자 삭제 (비밀번호 없이)
	public boolean deleteUser(String userID) {
		String sql = "DELETE FROM USER WHERE userID = ?";
		try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, userID);
			int result = pstmt.executeUpdate();
			return result > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	// SHA-256 + Salt 포함한 사용자 정보 수정 메서드
	public int userUpdate(User user, String oldUserID, String salt) {
		String sql = "UPDATE USER SET userID = ?, userPassword = ?, userName = ?, userEmail = ?, admin = ?, salt = ? WHERE userID = ?";
		try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, user.getUserID());
			pstmt.setString(2, user.getUserPassword());
			pstmt.setString(3, user.getUserName());
			pstmt.setString(4, user.getUserEmail());
			pstmt.setInt(5, "admin".equals(user.getAdmin()) ? 1 : 0);
			pstmt.setString(6, salt); // salt 추가
			pstmt.setString(7, oldUserID);
			return pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return -1;
	}

	// SHA-256 해시를 생성하는 메서드 (비밀번호 + 솔트)
	public String getSHA256WithSalt(String password, String salt) {
		try {
			MessageDigest md = MessageDigest.getInstance("SHA-256");
			byte[] hash = md.digest((password + salt).getBytes("UTF-8"));
			StringBuilder sb = new StringBuilder();
			for (byte b : hash) {
				sb.append(String.format("%02x", b));
			}
			return sb.toString();
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	// 사용자마다 고유한 솔트를 생성하는 메서드
	public String generateSalt() {
		SecureRandom random = new SecureRandom(); // 보안용 랜덤 생성기
		byte[] salt = new byte[16]; // 16바이트 길이의 솔트
		random.nextBytes(salt); // 솔트 랜덤 생성

		// 솔트를 16진수 문자열로 변환
		StringBuilder sb = new StringBuilder();
		for (byte b : salt) {
			sb.append(String.format("%02x", b)); // 바이트 -> 16진수 문자열
		}

		return sb.toString(); // 최종 솔트 문자열 반환
	}

}
