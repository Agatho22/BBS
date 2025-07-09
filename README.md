#  BBS - JSP 게시판 시스템

JSP 기반의 웹 게시판 프로젝트입니다.  
회원가입, 로그인, 게시글 등록/수정/삭제, 파일 업로드, 관리자 페이지, OTP 인증 등 다양한 기능을 포함하고 있으며, **보안 취약점 보완**을 중점으로 설계되었습니다.

---

---

## 📌 주요 기능

- 🔐 **회원 관리**
  - 회원가입 / 로그인 / 로그아웃
  - 비밀번호 찾기, 비밀번호 변경
  - 비밀번호 SHA-256 + 솔트 해싱
  - 계정 잠금, 로그인 실패 횟수 제한

- 🧾 **게시판 기능**
  - 게시글 등록 / 수정 / 삭제
  - 페이징 및 검색 기능
  - 파일 첨부 및 다운로드
  - 비밀글 기능

- 🛡️ **보안 기능**
  - CSRF 방지
  - XSS 방지
  - 입력값 유효성 검증
  - 관리자 인증 시 OTP (2차 인증) 적용

- 📂 **파일 업로드**
  - 멀티파트 업로드 지원 (`@MultipartConfig`)
  - 확장자 제한 및 업로드 크기 제한 설정

- ⚙️ **관리자 기능**
  - 사용자 목록 조회 및 수정
  - 게시글 관리 (숨김, 삭제, 비밀글 열람)
  - 로그 기록 (Log4j2 적용)

---

## 🛠️ 기술 스택

| 항목 | 기술 |
|------|------|
| 백엔드 | Java (Servlet & JSP) |
| 프론트엔드 | HTML, CSS, Bootstrap |
| DB | MySQL |
| 빌드도구 | Eclipse + Maven |
| 로깅 | Log4j2 |
| 보안 | SHA-256 + Salt, OTP, 로그인 제한 |
| 배포 | Apache Tomcat (로컬 테스트 환경) |

---

```프로젝트 디렉토리 구조

BBS/
├── .gitignore                       # Git이 무시할 파일 목록
├── README.md                        # 프로젝트 설명 문서
├── db.properties                    # DB 접속 설정 파일
├── log4j2.xml                       # Log4j2 로깅 설정 파일
├── passwd.pub                       # 공개 키 (예시)
├── passwd2                          # 기타 인증 관련 키 파일 (예시)
│
├── src/
│   └── main/
│       ├── java/
│       │   ├── admin/
│       │   │   └── AdminBbsUpdateCheckServlet.java  # 관리자 게시글 수정 권한 확인 서블릿
│       │   ├── bbs/
│       │   │   ├── Bbs.java                          # 게시글 모델 클래스
│       │   │   ├── BbsDAO.java                       # 게시판 DB 접근 로직
│       │   │   ├── BbsUpdateServlet.java             # 게시글 수정 처리 서블릿
│       │   │   └── DeleteBbsServlet.java             # 게시글 삭제 처리 서블릿
│       │   ├── controller/
│       │   │   └── BbsListServlet.java               # 게시글 목록 조회 컨트롤러
│       │   ├── file/
│       │   │   ├── File.java                         # 파일 메타데이터 모델 클래스
│       │   │   ├── FileDAO.java                      # 파일 업로드/다운로드 DB 처리
│       │   │   ├── WriteActionServlet.java           # 게시글 + 파일 업로드 처리 서블릿
│       │   │   └── downloadAction.java               # 파일 다운로드 처리 서블릿
│       │   ├── user/
│       │   │   ├── User.java                         # 사용자 모델 클래스
│       │   │   ├── UserDAO.java                      # 사용자 DB 접근 로직
│       │   │   ├── JoinActionServlet.java            # 회원가입 처리 서블릿
│       │   │   ├── LoginActionServlet.java           # 로그인 처리 서블릿
│       │   │   ├── LogoutActionServlet.java          # 로그아웃 처리 서블릿
│       │   │   ├── ChangePasswordServlet.java        # 비밀번호 변경 처리
│       │   │   ├── DeleteUserServlet.java            # 회원 탈퇴 처리
│       │   │   ├── FindIDActionServlet.java          # 아이디 찾기 처리
│       │   │   ├── AdminDeleteUserServlet.java       # 관리자 사용자 삭제 기능
│       │   │   ├── AdminUserUpdateServlet.java       # 관리자 사용자 수정 기능
│       │   │   ├── OtpRegistrationServlet.java       # OTP 등록 서블릿
│       │   │   └── OtpVerificationServlet.java       # OTP 인증 서블릿
│       │   ├── util/
│       │   │   ├── HtmlUtil.java                     # HTML escape 유틸리티
│       │   │   └── OtpUtil.java                      # OTP 코드 생성 유틸리티
│
│       └── webapp/
│           ├── WEB-INF/
│           │   ├── classes/
│           │   │   ├── db.properties                # DB 설정 (실제 적용 경로)
│           │   │   └── log4j2.xml                   # 로깅 설정
│           │   ├── lib/                             # 외부 라이브러리 .jar 파일 모음(오픈소스)
│           ├── css/
│           │   ├── bootstrap.min.css                # Bootstrap 스타일 시트
│           │   └── custom.css                       # 사용자 정의 스타일 시트
│           ├── js/
│           │   ├── bootstrap.min.js                 # Bootstrap JS
│           │   └── npm.js                           # npm 기능 스크립트
│           ├── image/
│           │   └── cuteduck.png                     # 이미지 리소스 예시
│           ├── fonts/                               # 폰트 파일 (Bootstrap용)
│           ├── index.jsp                            # 메인 진입 페이지
│           ├── login.jsp                            # 로그인 페이지
│           ├── join.jsp                             # 회원가입 페이지
│           ├── main.jsp                             # 로그인 후 메인 페이지
│           ├── view.jsp                             # 게시글 상세 조회 페이지
│           ├── write.jsp                            # 게시글 작성 페이지
│           ├── update.jsp                           # 게시글 수정 페이지
│           ├── deleteAction.jsp                     # 게시글 삭제 처리
│           ├── find.jsp                             # 아이디/비밀번호 찾기 선택 페이지
│           ├── findID.jsp                           # 아이디 찾기 페이지
│           ├── findPwd.jsp                          # 비밀번호 찾기 페이지
│           ├── checkuserID.jsp                      # 아이디 중복 확인 처리
│           ├── changePassword.jsp                   # 비밀번호 변경 페이지
│           ├── verifyOtp.jsp                        # OTP 인증 입력 화면
│           ├── fileDownload.jsp                     # 파일 다운로드 처리 뷰
│           ├── uploadAction.jsp                     # 파일 업로드 처리 뷰
│           ├── userDelete.jsp                       # 사용자 탈퇴 확인 페이지
│           ├── adminBbs.jsp                         # 관리자 게시글 목록
│           ├── adminBbsWrite.jsp                    # 관리자 게시글 작성
│           ├── adminBbsView.jsp                     # 관리자 게시글 보기
│           ├── adminBbsUpdate.jsp                   # 관리자 게시글 수정
│           ├── adminResetPassword.jsp               # 관리자 비밀번호 초기화
│           ├── adminUpdate.jsp                      # 관리자 사용자 수정
│           └── adminUser.jsp                        # 관리자 사용자 관리 페이지

'''

'''데이터베이스 구조

-- 📝 게시판 테이블
CREATE TABLE BBS (
    bbsID           INT PRIMARY KEY AUTO_INCREMENT,   -- 게시글 고유 ID
    bbsTitle        VARCHAR(255) NOT NULL,            -- 게시글 제목
    userID          VARCHAR(50) NOT NULL,             -- 작성자 ID (USER 테이블 참조)
    bbsDate         DATETIME DEFAULT CURRENT_TIMESTAMP, -- 작성일시
    bbsContent      TEXT,                             -- 게시글 내용
    bbsAvailable    INT DEFAULT 1,                    -- 게시글 공개 여부 (1: 공개, 0: 삭제됨)
    isSecret        BOOLEAN DEFAULT FALSE             -- 비밀글 여부 (TRUE: 비밀글)
);

-- 👤 사용자 테이블
CREATE TABLE USER (
    userID          VARCHAR(50) PRIMARY KEY,          -- 사용자 ID
    userPassword    VARCHAR(255) NOT NULL,            -- 암호화된 비밀번호
    userName        VARCHAR(100) NOT NULL,            -- 사용자 이름
    userEmail       VARCHAR(100) NOT NULL,            -- 이메일 주소
    admin           BOOLEAN DEFAULT FALSE,            -- 관리자 여부
    loginFailCount  INT DEFAULT 0,                    -- 로그인 실패 횟수
    isLocked        BOOLEAN DEFAULT FALSE,            -- 계정 잠금 여부
    lastFailTime    DATETIME,                         -- 마지막 로그인 실패 시간
    salt            VARCHAR(255),                     -- 비밀번호 해시용 솔트
    otpSecret       VARCHAR(255),                     -- OTP 비밀키 (2차 인증용)
    STATUS          VARCHAR(20) DEFAULT 'ACTIVE'      -- 계정 상태 (예: ACTIVE, SUSPENDED)
);

-- 📎 파일 테이블
CREATE TABLE FILE (
    fileName        VARCHAR(255) PRIMARY KEY,         -- 저장된 파일 이름 (실제 파일명)
    fileRealName    VARCHAR(255) NOT NULL,            -- 사용자에게 보여지는 원래 이름
    bbsID           INT,                              -- 첨부된 게시글 ID (BBS 테이블 참조)
    FOREIGN KEY (bbsID) REFERENCES BBS(bbsID)
);

-- 🔗 파일-게시글 매핑 테이블
CREATE TABLE FileBbsMapping (
    mappingID       INT PRIMARY KEY AUTO_INCREMENT,   -- 매핑 ID
    fileName        VARCHAR(255) NOT NULL,            -- FILE 테이블의 fileName 참조
    fileRealName    VARCHAR(255) NOT NULL,            -- 실제 파일 이름
    bbsID           INT NOT NULL,                     -- 게시글 ID (BBS 테이블 참조)
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fileName) REFERENCES FILE(fileName),
    FOREIGN KEY (bbsID) REFERENCES BBS(bbsID)
);

## 🗃️ 데이터베이스 설계 (ERD 기반)

- **BBS**: 게시글 정보를 저장하는 메인 테이블
- **USER**: 사용자 정보 (관리자 여부, OTP 등 보안 필드 포함)
- **FILE**: 파일 메타데이터 (파일명, 게시글 ID)
- **FileBbsMapping**: 게시글과 파일 간 다대다 관계 매핑용 중간 테이블


---
📋 진단 개요
진단 도구: Sparrow SAST (스페로우 정적 분석 도구)

대상 시스템: JSP 기반 게시판 시스템 (사용자/관리자/파일 업로드 포함)

진단 방식:

정적 분석(Sparrow SAST: Static Application Security Testing)

진단 시기: 2025년 6월

진단 범위: Java 소스코드 전반(src/main/java), JSP 페이지, 사용자 입력 처리, DB 연동, 인증 로직


