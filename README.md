# 서버 구축 & 게시판 사이트 구축 & 취약점 진단

<p align="center">
  <img src="src/main/webapp/image/cuteduck.png" alt="BBS Logo" width="180" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Java-8-007396?style=flat-square&logo=openjdk&logoColor=white" />
  <img src="https://img.shields.io/badge/JSP%2FServlet-4.0.1-orange?style=flat-square" />
  <img src="https://img.shields.io/badge/MySQL-8.x-4479A1?style=flat-square&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/Tomcat-9.x-F8DC75?style=flat-square&logo=apachetomcat&logoColor=black" />
  <img src="https://img.shields.io/badge/Log4j2-2.25.0-red?style=flat-square" />
</p>

## 1. 프로젝트 소개

**BBS**는 Java Servlet/JSP와 MySQL을 기반으로 구현한 웹 게시판 프로젝트입니다.
회원가입, 로그인, 게시글 작성/수정/삭제, 댓글, 파일 업로드/다운로드, 관리자 페이지, 관리자 OTP 인증 기능을 제공합니다.

이 프로젝트는 단순 게시판 구현뿐 아니라 **웹 보안 취약점 진단과 보완**을 함께 목표로 합니다.
비밀번호 SHA-256 + Salt 해싱, 로그인 실패 제한, PreparedStatement 기반 SQL Injection 방어, HTML Escape 기반 XSS 완화, 파일 업로드/다운로드 경로 검증, 관리자 권한 확인, OTP 기반 2차 인증 등을 적용했습니다.

> 보안 학습용 프로젝트입니다. 운영 환경에서는 비밀번호 해싱에 bcrypt, scrypt, Argon2 같은 적응형 해시 알고리즘 사용을 권장합니다.

## 2. 주요 기능

### 사용자 기능

- 회원가입, 로그인, 로그아웃
- 아이디 중복 확인
- 아이디 찾기, 비밀번호 찾기
- 비밀번호 변경
- 회원 탈퇴
- 로그인 실패 횟수 제한 및 계정 잠금 처리

### 게시판 기능

- 게시글 목록 조회
- 게시글 상세 조회
- 게시글 작성, 수정, 삭제
- 게시글 검색
- 페이지네이션
- 비밀글 설정 및 접근 제어
- 댓글 작성 및 관리자 댓글 삭제

### 파일 기능

- 게시글 작성/수정 시 파일 첨부
- 파일 다운로드
- 업로드 파일 확장자 검증
- 업로드 파일명 UUID 저장
- 업로드 경로를 웹 루트 외부(`/opt/upload`)로 분리
- 다운로드 시 경로 조작 및 디렉터리 탈출 방어

### 관리자 기능

- 관리자 메인 페이지
- 사용자 목록 조회 및 수정
- 사용자 삭제
- 사용자 비밀번호 초기화
- 게시글 관리
- 관리자 게시글 수정/삭제
- 관리자 로그인 시 OTP 인증

### 보안 기능

- 비밀번호 SHA-256 + Salt 해싱 (운영 환경에서는 bcrypt/Argon2 전환 권장)
- SQL Injection 방어: `PreparedStatement` 사용
- XSS 완화: HTML Escape 유틸리티 적용
- 파일 업로드 보안: 확장자, MIME 타입, 파일 내용 검사
- 파일 다운로드 보안: 파일명 정규화, 이중 URL 디코딩, Canonical Path 검증
- 관리자 권한 확인: `adminCheck()` 기반 접근 통제
- 관리자 2차 인증: Google Authenticator OTP
- 로그 기록: Log4j2 적용

## 3. 기술 스택

| 구분 | 기술 |
|---|---|
| Language | Java 8 |
| Backend | Servlet, JSP |
| Frontend | HTML, CSS, Bootstrap |
| Database | MySQL 8.x |
| WAS | Apache Tomcat 9.x 권장 |
| IDE | Eclipse Dynamic Web Project |
| Logging | Log4j2 |
| Authentication | Session, SHA-256 + Salt, OTP |
| File Upload | Servlet `@MultipartConfig`, COS MultipartRequest |
| Security Test | Sparrow SAST, Sparrow SCA |
| SBOM | CycloneDX (SBOM 파일의 `specVersion` 기준) |

## 4. 시작 가이드

### 4.1 요구 사항

아래 환경을 기준으로 실행합니다.

| 항목 | 버전/설명 |
|---|---|
| JDK | Java 8 |
| WAS | Apache Tomcat 9.x |
| DB | MySQL 8.x |
| IDE | Eclipse IDE for Enterprise Java and Web Developers |
| Servlet API | 4.0.1 |

### 4.2 프로젝트 가져오기

```bash
git clone https://github.com/Agatho22/BBS.git
cd BBS
```

Eclipse를 사용하는 경우:

1. `File` -> `Import`
2. `Existing Projects into Workspace` 선택
3. 프로젝트 루트 디렉터리 선택
4. Target Runtime을 Apache Tomcat으로 설정
5. `src/main/webapp/WEB-INF/lib` 라이브러리 확인

### 4.3 라이브러리 확인

프로젝트에는 다음 라이브러리가 포함되어 있습니다.

```text
src/main/webapp/WEB-INF/lib/
├── commons-codec-1.9.jar
├── cos.jar
├── googleauth-1.4.0.jar
├── javax.servlet-api-4.0.1.jar
├── log4j-api-2.25.0.jar
├── log4j-core-2.25.0.jar
└── mysql-connector-j-8.4.0.jar
```

코드에서 Apache Commons IO의 `FilenameUtils`를 사용하므로, 실행 환경에 따라 `commons-io` JAR가 추가로 필요할 수 있습니다.

```text
commons-io-2.x.jar
```

### 4.4 데이터베이스 생성

MySQL에서 데이터베이스를 생성합니다.

```sql
CREATE DATABASE BBS DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE BBS;
```

테이블을 생성합니다.

```sql
CREATE TABLE USER (
    userID VARCHAR(50) PRIMARY KEY,
    userPassword VARCHAR(255) NOT NULL,
    userName VARCHAR(100) NOT NULL,
    userEmail VARCHAR(100) NOT NULL,
    admin BOOLEAN DEFAULT FALSE,
    loginFailCount INT DEFAULT 0,
    isLocked BOOLEAN DEFAULT FALSE,
    lastFailTime DATETIME NULL,
    salt VARCHAR(255),
    otpSecret VARCHAR(255),
    status VARCHAR(20) DEFAULT 'ACTIVE'
);

CREATE TABLE BBS (
    bbsID INT PRIMARY KEY AUTO_INCREMENT,
    bbsTitle VARCHAR(255) NOT NULL,
    userID VARCHAR(50) NOT NULL,
    bbsDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    bbsContent TEXT,
    bbsAvailable INT DEFAULT 1,
    isSecret VARCHAR(10) DEFAULT 'N',
    CONSTRAINT fk_bbs_user FOREIGN KEY (userID) REFERENCES USER(userID)
);

CREATE TABLE FileBbsMapping (
    mappingID INT PRIMARY KEY AUTO_INCREMENT,
    fileName VARCHAR(255) NOT NULL,
    fileRealName VARCHAR(255) NOT NULL,
    bbsID INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_file_bbs FOREIGN KEY (bbsID) REFERENCES BBS(bbsID)
);

CREATE TABLE REPLY (
    replyID INT PRIMARY KEY AUTO_INCREMENT,
    bbsID INT NOT NULL,
    userID VARCHAR(50) NOT NULL,
    replyContent TEXT NOT NULL,
    replyDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    isDeleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_reply_bbs FOREIGN KEY (bbsID) REFERENCES BBS(bbsID),
    CONSTRAINT fk_reply_user FOREIGN KEY (userID) REFERENCES USER(userID)
);
```

> **상태 컬럼 설계 참고**: `USER.status`는 계정 생명주기(ACTIVE/탈퇴 등), `isLocked`는 로그인 실패에 따른 일시 잠금, `BBS.bbsAvailable`은 게시글 노출 여부를 의미합니다. 책임이 분리된 별도 상태값입니다.

관리자 계정은 회원가입 후 DB에서 `admin` 값을 `1`로 변경해 사용할 수 있습니다.

```sql
UPDATE USER SET admin = 1 WHERE userID = '관리자아이디';
```

### 4.5 DB 접속 설정

`db.properties` 파일을 실행 환경에 맞게 수정합니다. 소스상 위치와 배포 후 클래스패스 로딩 위치는 다음과 같습니다.

```text
소스 경로(권장):  src/main/resources/db.properties
                  (Eclipse Dynamic Web Project인 경우 소스 루트 src/db.properties)
배포 후 로딩 경로: WEB-INF/classes/db.properties
```

```properties
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/BBS?serverTimezone=UTC&characterEncoding=UTF-8&useSSL=true
db.username=YOUR_DB_USERNAME
db.password=YOUR_DB_PASSWORD
```

> 실제 비밀번호가 포함된 `db.properties`는 공개 저장소에 커밋하지 않는 것을 권장합니다. `.gitignore`에 등록하고, 운영 환경에서는 환경변수 또는 외부 Secret 관리(Vault 등)를 사용하세요.

### 4.6 업로드 디렉터리 생성

파일 업로드/다운로드 기능은 `/opt/upload` 경로를 사용합니다.

Linux/macOS:

```bash
sudo mkdir -p /opt/upload/temp
# WAS 실행 계정(예: tomcat) 소유로 변경
sudo chown -R tomcat:tomcat /opt/upload
# 디렉터리 750, 실행 권한 제거로 웹쉘 실행 위험 차단
sudo chmod -R 750 /opt/upload
```

> 업로드 디렉터리는 실행 권한이 불필요합니다. 디렉터리 `750`, 파일 `640` 정책으로 최소 권한을 유지해 업로드된 파일의 실행 위험을 줄입니다.

Windows 환경에서는 코드의 업로드 경로를 로컬 경로에 맞게 수정해야 합니다.

### 4.7 실행

Tomcat에 프로젝트를 배포한 뒤 아래 주소로 접속합니다.

```text
http://localhost:8080/BBS/
```

주요 진입 페이지:

```text
/index.jsp
/main.jsp
/bbs
/login.jsp
/join.jsp
```

## 5. 화면 구성

| 화면 | 파일 | 설명 |
|---|---|---|
| 메인 | `index.jsp`, `main.jsp` | 서비스 진입 및 로그인 후 메인 화면 |
| 로그인 | `login.jsp` | 사용자 로그인 |
| 회원가입 | `join.jsp` | 신규 사용자 가입 |
| 게시글 목록 | `/bbs`, `WEB-INF/views/bbs.jsp` | 게시글 목록, 검색, 페이지네이션 |
| 게시글 상세 | `view.jsp` | 게시글 상세 조회, 첨부파일, 댓글 확인 |
| 게시글 작성 | `write.jsp` | 게시글 및 파일 작성 |
| 게시글 수정 | `bbsEdit.jsp` | 게시글 수정 |
| 아이디 찾기 | `findID.jsp` | 이름/이메일 기반 아이디 찾기 |
| 비밀번호 찾기 | `findPwd.jsp` | 사용자 확인 후 비밀번호 재설정 |
| 비밀번호 변경 | `changePassword.jsp` | 로그인 사용자 비밀번호 변경 |
| 회원 탈퇴 | `userDelete.jsp` | 사용자 계정 삭제 |
| OTP 인증 | `verifyOtp.jsp` | 관리자 OTP 입력 |
| 관리자 메인 | `adminMain.jsp` | 관리자 전용 메인 |
| 사용자 관리 | `adminUser.jsp`, `adminUpdate.jsp` | 관리자 사용자 목록/수정 |
| 게시글 관리 | `adminBbs.jsp`, `adminBbsView.jsp` | 관리자 게시글 목록/상세 |
| 관리자 글 작성/수정 | `adminBbsWrite.jsp`, `adminBbsUpdate.jsp` | 관리자 게시글 작성/수정 |

## 6. 주요 Servlet/API

> URL prefix 규칙: 파일 관련 처리는 `/file/...`, 관리자 전용 처리는 `/admin/...` 또는 `admin*`으로 그룹화했습니다. 그 외 사용자 인증/게시 기능은 루트 경로를 사용합니다.

| Method | URL | Servlet | 설명 |
|---|---|---|---|
| GET | `/bbs` | `BbsListServlet` | 게시글 목록 조회 |
| POST | `/file/writeActionServlet` | `WriteActionServlet` | 게시글 작성 및 파일 업로드 |
| POST | `/bbsUpdateAction` | `BbsUpdateServlet` | 게시글 수정 및 파일 수정 |
| POST | `/deleteBbs` | `DeleteBbsServlet` | 게시글 삭제 |
| POST | `/deleteMyBbs` | `DeleteMyBbsServlet` | 내 게시글 삭제 |
| GET | `/bbs/validateAccess` | `ValidateBbsAccessServlet` | 비밀글/수정 접근 검증 |
| GET | `/downloadAction` | `downloadAction` | 첨부파일 다운로드 |
| POST | `/writeReply` | `WriteReplyServlet` | 댓글 작성 |
| POST | `/joinAction` | `JoinActionServlet` | 회원가입 처리 |
| POST | `/loginAction` | `LoginActionServlet` | 로그인 처리 |
| GET/POST | `/logoutAction` | `LogoutActionServlet` | 로그아웃 처리 |
| GET | `/checkID` | `CheckIDServlet` | 아이디 중복 확인 |
| POST | `/findIDAction` | `FindIDActionServlet` | 아이디 찾기 |
| POST | `/findPwdActionServlet` | `FindPwdActionServlet` | 비밀번호 찾기/재설정 |
| POST | `/ChangePasswordAction` | `ChangePasswordServlet` | 비밀번호 변경 |
| POST | `/deleteUser` | `DeleteUserServlet` | 회원 탈퇴 |
| GET | `/registerOtp` | `OtpRegistrationServlet` | 관리자 OTP 등록 |
| POST | `/verifyOtp` | `OtpVerificationServlet` | 관리자 OTP 검증 |
| POST | `/adminUserUpdate` | `AdminUserUpdateServlet` | 관리자 사용자 수정 |
| GET | `/adminUserEditServlet` | `AdminUserEditServlet` | 관리자 사용자 수정 화면 이동 |
| POST | `/admin/deleteUser` | `AdminDeleteUserServlet` | 관리자 사용자 삭제 |
| POST | `/adminResetPassword` | `AdminResetPasswordServlet` | 관리자 비밀번호 초기화 |
| GET | `/adminBbsUpdateCheck` | `AdminBbsUpdateCheckServlet` | 관리자 게시글 수정 접근 확인 |
| POST | `/admin/updateAdminBbs` | `AdminBbsUpdateActionServlet` | 관리자 게시글 수정 처리 |
| POST | `/adminDeleteReply` | `AdminDeleteReplyServlet` | 관리자 댓글 삭제 |

## 7. 프로젝트 구조

```text
BBS/
├── README.md
├── BBS.json
├── BBS_SBOM_CycloneDX.json
├── BBS_SBOM_보고서.xlsx
├── src/
│   └── main/
│       ├── java/
│       │   ├── admin/          # 관리자 기능 Servlet
│       │   ├── bbs/            # 게시판 모델, DAO, 게시글 처리 Servlet
│       │   ├── controller/     # 게시글 목록 Controller
│       │   ├── exception/      # 커스텀 예외
│       │   ├── file/           # 파일 업로드/다운로드 DAO, DTO, Servlet
│       │   ├── reply/          # 댓글 모델, DAO, Servlet
│       │   ├── user/           # 사용자 모델, DAO, 인증/회원 기능 Servlet
│       │   ├── util/           # HTML Escape, 게시글 검증 유틸
│       │   └── utils/          # OTP 유틸
│       └── webapp/
│           ├── WEB-INF/
│           │   ├── classes/    # db.properties, log4j2.xml (배포 후 클래스패스)
│           │   ├── lib/        # 외부 JAR 라이브러리
│           │   └── views/      # 보호된 JSP View
│           ├── css/            # 화면 스타일
│           ├── fonts/          # Bootstrap 폰트
│           ├── image/          # 이미지 리소스
│           ├── includes/       # 공통 네비게이션 JSP
│           ├── js/             # Bootstrap JS
│           └── *.jsp           # 사용자/관리자 화면
└── src/main/ImportedClasses/    # 기존 컴파일 클래스 백업성 파일
```

## 8. 아키텍처

```text
Browser
  │
  ▼
JSP View / Form
  │
  ▼
Servlet Controller
  │
  ├── UserDAO / BbsDAO / FileDAO / ReplyDAO
  │       │
  │       ▼
  │     MySQL
  │
  ├── HtmlUtil / BbsUtil / OtpUtil
  │
  └── /opt/upload
```

### 요청 흐름 예시: 게시글 작성

```text
write.jsp
  -> POST /file/writeActionServlet
  -> 로그인 세션 확인
  -> 제목/내용/비밀글 여부 검증
  -> 첨부파일 확장자, MIME 타입, 유해 패턴 검사
  -> BbsDAO.write()
  -> FileDAO.upload()
  -> /bbs 또는 /adminBbs.jsp로 이동
```

### 요청 흐름 예시: 관리자 로그인

```text
login.jsp
  -> POST /loginAction
  -> UserDAO.login()
  -> 관리자 여부 확인
  -> pendingAdmin 세션 저장
  -> /registerOtp 또는 /verifyOtp
  -> OTP 검증 성공 시 userID 세션 확정
  -> adminMain.jsp
```

## 9. 데이터베이스 설계

| 테이블 | 설명 |
|---|---|
| `USER` | 사용자 계정, 관리자 여부, 로그인 실패 횟수, Salt, OTP Secret 저장 |
| `BBS` | 게시글 제목, 내용, 작성자, 작성일, 공개 여부, 비밀글 여부 저장 |
| `FileBbsMapping` | 게시글과 첨부파일 저장명/원본명 매핑 |
| `REPLY` | 게시글 댓글 저장 |

### ERD 개요

```text
USER 1 ─── N BBS
USER 1 ─── N REPLY
BBS  1 ─── N REPLY
BBS  1 ─── N FileBbsMapping
```

## 10. 보안 진단 및 조치 내역

이 프로젝트는 Sparrow SAST를 활용한 정적 분석과 수동 코드 리뷰를 통해 주요 취약점을 점검했습니다.

| 항목 | 위험 | 적용/조치 내용 | 상태 |
|---|---|---|---|
| SQL Injection | 사용자 입력이 SQL 구문에 삽입될 위험 | DAO 계층에서 `PreparedStatement` 사용 | 완료 |
| XSS | 게시글/댓글/사용자 입력값이 HTML로 출력될 위험 | `HtmlUtil.escapeHtml()` 계열 유틸 사용 | 완료 |
| 비밀번호 저장 | DB 유출 시 비밀번호 노출 | SHA-256 + Salt 해싱 적용 | 완료 (적응형 해시 bcrypt/Argon2 전환 권장) |
| 로그인 무차별 대입 | 반복 로그인 시도 | 실패 횟수 증가, 일정 시간 잠금 처리 | 완료 |
| 관리자 권한 우회 | URL 직접 접근 | 세션과 `adminCheck()` 기반 권한 확인 | 완료 |
| 파일 업로드 | 웹쉘, 악성 파일 업로드 | 확장자 제한, MIME 검사, 유해 패턴 검사, 외부 경로 저장, 실행 권한 제거 | 완료 |
| 파일 다운로드 | Path Traversal | URL 이중 디코딩, 파일명 정규화, Canonical Path 검증 | 완료 |
| 관리자 계정 탈취 | 관리자 로그인 후 추가 검증 부재 | Google Authenticator OTP 적용 | 완료 |
| CSRF | 중요 요청 위조 가능성 | SameSite 쿠키 + 토큰 기반 방어 추가 필요 | 개선 예정 |

## 11. SBOM 및 보안 보고서

프로젝트에는 오픈소스 구성요소를 식별하기 위한 SBOM과 Sparrow SCA 보고서가 포함되어 있습니다.

| 파일 | 설명 |
|---|---|
| `BBS_SBOM_CycloneDX.json` | CycloneDX 기반 SBOM 문서 (`specVersion` 필드로 버전 확인) |
| `BBS_SBOM_보고서.xlsx` | Sparrow SCA 기반 오픈소스 취약점 분석 보고서 |
| `BBS.json` | 프로젝트 구성요소 분석 결과 JSON |

SBOM은 소프트웨어 공급망 투명성을 높이고, 사용 중인 라이브러리의 CVE 취약점 추적을 위해 활용할 수 있습니다.

## 12. 트러블슈팅

### DB 연결 실패

`db.properties` 경로와 MySQL 계정 정보를 확인합니다.

```text
소스: src/main/resources/db.properties (또는 src/db.properties)
배포: WEB-INF/classes/db.properties
```

확인할 항목:

- MySQL 서버 실행 여부
- `BBS` 데이터베이스 생성 여부
- 계정/비밀번호 일치 여부
- `mysql-connector-j` JAR 포함 여부

### 파일 업로드 실패

`/opt/upload`와 `/opt/upload/temp` 디렉터리 권한 및 소유자를 확인합니다.

```bash
sudo mkdir -p /opt/upload/temp
sudo chown -R tomcat:tomcat /opt/upload
sudo chmod -R 750 /opt/upload
```

### `FilenameUtils` 관련 오류

`commons-io` 라이브러리가 누락되었을 수 있습니다.
`commons-io-2.x.jar` 파일을 `WEB-INF/lib`에 추가하거나 Eclipse Build Path에 등록합니다.

## 13. 개선 예정 사항

- CSRF Token 기반 요청 위조 방어 추가 (SameSite 쿠키 병행)
- Maven/Gradle 기반 의존성 관리 전환
- DB 접속 정보 환경변수/외부 Secret 분리
- 단위 테스트 및 통합 테스트 추가
- 관리자 기능 URL 권한 검증 공통 필터화
- 비밀번호 해싱 알고리즘을 bcrypt/Argon2로 개선
- 업로드 가능 파일 정책 정리 및 MIME/확장자 규칙 일원화
- Docker Compose 기반 실행 환경 구성

## 14. 라이선스

본 프로젝트는 보안 학습 목적으로 공개되었습니다.
포함된 오픈소스 라이브러리는 각 라이선스(Apache-2.0, MIT 등)를 따릅니다.
