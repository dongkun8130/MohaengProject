# ✈️ 모행 (Mohaeng) — AI 기반 여행 통합 플랫폼

> AI 개인 맞춤 여행 계획부터 항공권·숙소·투어 예약, 실시간 채팅, 커뮤니티까지 한 번에 제공하는 여행 통합 웹 플랫폼

![Java](https://img.shields.io/badge/Java-21-007396?logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-6DB33F?logo=springboot&logoColor=white)
![Spring Security](https://img.shields.io/badge/Spring%20Security-6DB33F?logo=springsecurity&logoColor=white)
![MyBatis](https://img.shields.io/badge/MyBatis-000000?logo=mybatis&logoColor=white)
![Oracle](https://img.shields.io/badge/Oracle%20DB-F80000?logo=oracle&logoColor=white)
![JSP](https://img.shields.io/badge/JSP-orange)
![Tomcat](https://img.shields.io/badge/Apache%20Tomcat-10.1-F8DC75?logo=apachetomcat&logoColor=black)
![WebSocket](https://img.shields.io/badge/WebSocket-STOMP-blue)

---

## 📖 Overview & Problem Statement

여행 계획 시 항공권·숙소·투어 예약이 각기 다른 플랫폼에 분산되어 있어 사용자가 여러 서비스를 오가며 정보를 취합해야 하는 비효율이 존재합니다. 본 프로젝트는 예약·채팅·커뮤니티 기능을 하나의 플랫폼에 통합하고, 일반 사용자(JSP)와 관리자(React)의 접근 경로를 분리한 하이브리드 웹 애플리케이션으로 이 문제를 해결합니다. 특히 항공권 도메인은 정규화된 스키마 설계와 외부 공공 API 연동을 통해 실시간 좌석 검증까지 지원합니다.

- **기간**: 2025.12.03 ~ 2026.02.03 (9주)
- **인원**: 7명 (PL 1 · AA 2 · DA 2 · BA 1 · TA 1)
- **담당 역할**: AA(Application Architect) & 보조 DA & Backend Developer — [신동근](https://github.com/dongkun8130)

## 🚀 Key Features

| 기능 | 기술적 도전 과제 |
|---|---|
| 하이브리드 인증 (일반회원/관리자) | JSP 세션 인증과 React JWT 인증의 필터 체인 충돌 없이 공존 |
| 항공권 검색 및 실시간 예약 | 국토교통부 TAGO 공공 API 연동, 응답 스키마 동적 대응 |
| 좌석 등급별 예약 검증 | 매진 항공편에 대한 실시간 좌석 검증으로 결제 진입 차단 |
| 기업회원 예약·리뷰 관리 | Bootstrap 기반 반응형 통합 관리 화면 |
| 실시간 채팅 | WebSocket(STOMP) 기반 커뮤니케이션 |
| 공통 로깅/모듈화 | Spring AOP 기반 요청 추적, 외부 API(TourAPI·reCAPTCHA·토스페이먼츠) 공통 모듈화 |

## 🏗 Architecture & Technical Decisions

### 시스템 아키텍처

[React: 관리자 페이지] [JSP: 일반/기업회원]
│ JWT │ Session
▼ ▼
┌─────────────────┐ ┌──────────────────┐
│ /api/** 필터체인 │ │ /jsp/** 필터체인 │
│ (CSRF 비활성화) │ │ (Session+CSRF) │
└─────────────────┘ └──────────────────┘
│ │
└────────────┬──────────────┘
▼
┌───────────────────────────────────────┐
│ Controller → Service → Mapper │
│ (Spring AOP 기반 공통 로깅 관통 적용) │
└───────────────────────────────────────┘
│ │ │
▼ ▼ ▼
┌───────────┐ ┌──────────────┐ ┌───────────┐
│ WebSocket │ │ 외부 API │ │ Oracle DB │
│ (STOMP) │ │ TAGO/Toss/Tour│ │ │
└───────────┘ └──────────────┘ └───────────┘


### 기술 스택 선정 이유

- **Spring Security 필터 체인 분리 (`@Order`)**: React(JWT)와 JSP(Session)를 한 애플리케이션에서 동시 지원하기 위해 `/api/**`와 `/jsp/**` 경로별로 `SecurityFilterChain`을 격리. `/api/**`는 CSRF를 비활성화하고 JWT 인증 필터를 적용, `/jsp/**`는 기존 세션·CSRF 검증을 유지하여 두 인증 방식이 충돌하지 않도록 설계.
- **MyBatis 동적 SQL (`<where>` 태그)**: 카테고리·레벨·페이징 등 다중 필터 조합 시 `<if>` 태그를 개별 `WHERE/AND`로 분리 작성하면 조건 누락 시 `ORA-00933` 오류가 발생. `<where>` 태그로 전체 조건을 감싸 조건 유무와 무관하게 유효한 SQL이 생성되도록 구조화.
- **ObjectMapper 기반 응답 타입 판별**: 외부 API(TAGO)가 응답 건수에 따라 JSON Object/Array를 가변적으로 반환하는 문제를, `JsonNode` 트리 파싱 후 `isArray()/isObject()` 분기 처리로 대응.
- **항공권 도메인 3정규화**: `AIRLINE`, `AIRPORT`, `FLIGHT_PRODUCT`, `FLIGHT_RESERVATION`, `FLIGHT_PASSENGERS` 테이블 분리 및 PK/FK 관계 설계, 시퀀스 기반 PK 생성으로 데이터 정합성 확보.

## ⚙️ Getting Started

### 요구 사항
- JDK 21
- Apache Tomcat 10.1
- Oracle DB
- Git

### 환경변수 (`application.properties` / `application.yml`)

```properties
# Database
spring.datasource.url=jdbc:oracle:thin:@localhost:1521:xe
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}

# JWT
jwt.secret=${JWT_SECRET}

# 외부 API
tago.service-key=${TAGO_SERVICE_KEY}
toss.payment-key=${TOSS_PAYMENT_KEY}
recaptcha.secret-key=${RECAPTCHA_SECRET_KEY}
```

### 실행

```bash
# 1. 저장소 클론
git clone https://github.com/dongkun8130/MohaengProject.git
cd MohaengProject

# 2. 빌드
./mvnw clean package   # 또는 gradle을 사용하는 경우 ./gradlew build

# 3. 실행
java -jar target/*.jar
```

> 관리자 페이지(React)는 별도 저장소에서 관리됩니다: [MohaengReact](https://github.com/dongkun8130/MohaengReact)

## 🔌 API Reference / Usage

GET /jsp/flights/search # 항공권 검색 (TAGO API 연동, 세션 인증)
POST /jsp/flights/reserve # 좌석 등급별 실시간 재고 검증 후 예약
GET /api/admin/reservations # 기업회원 예약 내역 조회 (JWT 인증)
GET /api/admin/logs # 관리자 로그 조회 (카테고리/레벨/기간 다중 필터)
WS /ws/chat # 실시간 채팅 (STOMP)


## 🧩 Technical Challenges

**1. Spring Security 하이브리드 인증 아키텍처 수립**
- **문제**: React·JSP 혼용 구조에서 Spring Security 기본 CSRF 정책으로 인해 React API 요청 시 403 Forbidden 발생, 프론트-백엔드 분리로 CORS 이슈 발생.
- **해결**: `@Order`로 필터 체인 분리(`/api/**` JWT+CSRF 비활성화, `/jsp/**` 세션+CSRF 유지), `@CrossOrigin`으로 Origin 명시 허용, Axios 인터셉터로 토큰 첨부 및 401/403 시 자동 로그아웃 처리 구현.
- **결과**: 세션·토큰 인증이 한 애플리케이션 내에서 충돌 없이 공존.

**2. 외부 API 인코딩 오류 및 응답 스키마 변동 대응**
- **문제**: `RestTemplate`의 기본 `UrlBuilder`가 TAGO API의 `serviceKey`를 중복 인코딩하여 인증 실패, 응답 건수에 따라 JSON Object/Array가 가변적으로 반환되어 매핑 오류 발생.
- **해결**: `DefaultUriBuilderFactory`를 `EncodingMode.NONE`으로 설정해 인코딩 개입 제거, `ObjectMapper`로 `JsonNode` 파싱 후 타입 판별 로직(`isArray()`/`isObject()`) 구현.
- **결과**: 인증 실패 해결 및 응답 규격 변동에 대한 방어 체계 구축.

**3. 다중 필터·페이징 조합 시 동적 SQL 조건 누락 (ORA-00933)**
- **문제**: 카테고리·레벨 필터를 각각 `WHERE`/`AND`로 분리 작성해, 특정 조합에서 `WHERE` 없이 `AND`만 남는 SQL이 생성되어 Oracle `ORA-00933` 오류 발생. 목록 조회와 COUNT 서브쿼리 조건 불일치로 페이지 수 계산도 부정확.
- **해결**: `p6spy`로 조건 조합별 실행 SQL을 추적해 재현 조합 특정, MyBatis `<where>` 태그로 전체 조건을 통일해 조건 유무에 따라 `WHERE`가 자동 처리되도록 개선, 목록/카운트 쿼리의 필터 조건 일치.
- **결과**: 필터 단독/복합 적용 시에도 SQL 오류 없이 조회, 페이지 수 계산 정합성 확보.

### 확장 가능성
- 필터 체인 분리 구조는 향후 모바일 앱(JWT 기반) 연동 시에도 별도 인증 계층 추가 없이 확장 가능.
- 외부 API 응답 타입 판별 로직은 TAGO 외 타 공공 API 연동 시에도 재사용 가능한 공통 모듈로 활용 가능.

## 📄 License & Contact

본 프로젝트는 대덕인재개발원 교육 과정 산출물로, 별도의 오픈소스 라이선스는 지정되어 있지 않습니다.

- **Author**: 신동근 (Backend Developer)
- **GitHub**: [github.com/dongkun8130](https://github.com/dongkun8130)
- **Email**: dongkun8130@naver.com
