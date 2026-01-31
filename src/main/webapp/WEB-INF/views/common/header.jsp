<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="모행 - AI 기반 개인 맞춤형 관광 서비스 플랫폼">
    <title>모행 - ${pageTitle != null ? pageTitle : '나만의 여행을 계획하세요'}</title>

	<!-- axios -->
	<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

	<!-- 토스페이먼츠 cdn -->
	<script src="https://js.tosspayments.com/v2/standard"></script>

    <!-- Context Path Meta Tag -->
    <meta name="context-path" content="${pageContext.request.contextPath}">

    <!-- Favicon -->
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/resources/images/moheng_CI_con.png">

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

    <!-- Flatpickr (날짜 선택) -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">

    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">

    <!-- 페이지별 추가 CSS -->
    <c:if test="${not empty pageCss}">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/${pageCss}.css">
    </c:if>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
</head>
<body data-logged-in="<sec:authorize access='isAuthenticated()'>true</sec:authorize><sec:authorize access='isAnonymous()'>false</sec:authorize>">
    <!-- 헤더 -->
    <header class="header" id="header">
        <div class="header-container">
            <!-- 로고 -->
            <a href="${pageContext.request.contextPath}/" class="logo">
                <img src="${pageContext.request.contextPath}/resources/images/moheng_CI.png" alt="모행 - 모두의 여행" class="logo-img">
            </a>

            <!-- 헤더 우측 영역 -->
            <div class="header-right">
           
                    <sec:authorize access="isAuthenticated()">
					    <sec:authentication property="principal.memProfilePath" var="profileImgUrl"/>
					    <!-- 로그인 상태 - 내 일정 -->
					    <sec:authorize access="hasRole('MEMBER')">
					    <button class="header-notification-btn" onclick="openScheduleModal()" title="내 일정">
						    <i class="bi bi-calendar3"></i>
						</button>
						</sec:authorize>
                        <!-- 로그인 상태 - 알림 버튼 -->
                        <button class="header-notification-btn" onclick="toggleNotificationPanel()" title="알림">
                            <i class="bi bi-bell"></i>
                             <span class="notification-badge" id="notificationBadge"></span>
                        </button>
                        <!-- 로그인 상태 - 마이페이지 링크 -->
							<sec:authorize access="hasRole('BUSINESS')">
							    <a href="${pageContext.request.contextPath}/mypage/business/profile"
							       class="header-user-link">
							        <span class="user-avatar">
							            <c:choose>
							                <c:when test="${not empty profileImgUrl}">
							                    <img src="<c:url value='/upload${profileImgUrl}' />"
							                         class="profile-img-render"
							                         alt="프로필 이미지">
							                </c:when>
							                <c:otherwise>
							                    <i class="bi bi-building"></i>
							                </c:otherwise>
							            </c:choose>
							        </span>
							        <span class="user-name">
							            <sec:authentication property="principal.username"/>님
							        </span>
							    </a>
							</sec:authorize>
							
							<sec:authorize access="hasRole('MEMBER')">
							    <a href="${pageContext.request.contextPath}/mypage/profile"
							       class="header-user-link">
							        <span class="user-avatar">
							            <c:choose>
							                <c:when test="${not empty profileImgUrl}">
							                    <img src="<c:url value='/upload${profileImgUrl}' />"
							                         class="profile-img-render"
							                         alt="프로필 이미지">
							                </c:when>
							                <c:otherwise>
							                    <i class="bi bi-person"></i>
							                </c:otherwise>
							            </c:choose>
							        </span>
							        <span class="user-name">
							            <sec:authentication property="principal.username"/>님
							        </span>
							    </a>
							</sec:authorize>
						</sec:authorize>
                    <sec:authorize access="isAnonymous()">
                        <!-- 비로그인 상태 -->
                        <a href="${pageContext.request.contextPath}/member/login" class="btn btn-text btn-sm">
                            로그인
                        </a>
                    </sec:authorize>

                <!-- 햄버거 메뉴 버튼 -->
                <button class="hamburger-btn" id="hamburgerBtn" onclick="toggleSideMenu()">
                    <span class="hamburger-line"></span>
                    <span class="hamburger-line"></span>
                    <span class="hamburger-line"></span>
                </button>
            </div>
        </div>
    </header>
    
    <!-- 캘린더 -->
    <sec:authorize access="isAuthenticated()">
	    <div class="modal fade" id="headerScheduleModal" tabindex="-1" aria-labelledby="scheduleModalLabel" aria-hidden="true" style="z-index: 9999;">
	        <div class="modal-dialog modal-lg modal-dialog-centered"> <div class="modal-content">
	                <div class="modal-header">
	                    <h5 class="modal-title" id="scheduleModalLabel"><i class="bi bi-calendar3 me-2"></i>내 일정 한 눈에 보기</h5>
	                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
	                </div>
	                <div class="modal-body">
	                    <div class="calendar-legend mb-3" style="font-size: 0.85em; display: flex; gap: 10px; justify-content: flex-end;">
	                        <span class="legend-item"><span class="legend-dot" style="display:inline-block; width:10px; height:10px; border-radius:50%; background:#1f6feb; margin-right:5px;"></span>다가오는 여행</span>
	                        <span class="legend-item"><span class="legend-dot" style="display:inline-block; width:10px; height:10px; border-radius:50%; background:#3fb950; margin-right:5px;"></span>진행중</span>
	                        <span class="legend-item"><span class="legend-dot" style="display:inline-block; width:10px; height:10px; border-radius:50%; background:#6e7681; margin-right:5px;"></span>완료</span>
	                    </div>
	                    <div id="headerScheduleCalendar" style="min-height: 450px;"></div>
	                </div>
	                <div class="modal-footer">
	                    <a href="${pageContext.request.contextPath}/schedule/my" class="btn btn-outline-primary btn-sm">전체 보기</a>
	                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">닫기</button>
	                </div>
	            </div>
	        </div>
	    </div>
	</sec:authorize>

    <!-- 사이드 메뉴 오버레이 -->
    <div class="side-menu-overlay" id="sideMenuOverlay" onclick="toggleSideMenu()"></div>

    <!-- 사이드 메뉴 -->
    <div class="side-menu" id="sideMenu">
        <div class="side-menu-header">
            <a href="${pageContext.request.contextPath}/" class="logo">
                <img src="${pageContext.request.contextPath}/resources/images/moheng_CI.png" alt="모행 - 모두의 여행" class="logo-img">
            </a>
            <button class="side-menu-close" onclick="toggleSideMenu()">
                <i class="bi bi-x-lg"></i>
            </button>
        </div>

        <!-- 사이드 메뉴 사용자 정보 -->
        <sec:authorize access="isAuthenticated()">
                <div class="side-menu-user">
                    <div class="side-menu-user-info">
                        <span class="side-menu-avatar">
							    <c:choose>
							        <c:when test="${not empty profileImgUrl}">
							            <img src="<c:url value='/upload${profileImgUrl}' />"
							                 class="profile-img-render"
							                 alt="프로필 이미지">
							        </c:when>
							        <c:otherwise>
							            <sec:authorize access="hasRole('BUSINESS')">
							                <i class="bi bi-building"></i>
							            </sec:authorize>
							            <sec:authorize access="hasRole('MEMBER')">
							                <i class="bi bi-person"></i>
							            </sec:authorize>
							        </c:otherwise>
							    </c:choose>
                        </span>
                        <div class="side-menu-user-detail">
                            <span class="side-menu-user-name"><sec:authentication property="principal.username"/>님</span>
                            <span class="side-menu-user-type">
                                    <sec:authorize access="hasRole('BUSINESS')">기업회원</sec:authorize>
                                    <sec:authorize access="hasRole('MEMBER')">일반회원</sec:authorize>
                            </span>
                        </div>
                    </div>
                    
                    <a href="${pageContext.request.contextPath}/member/logout" class="side-menu-logout">
                        <i class="bi bi-box-arrow-right"></i>
                    </a>
                </div>
            </sec:authorize>
			<sec:authorize access="isAnonymous()">
                <div class="side-menu-auth">
                    <a href="${pageContext.request.contextPath}/member/login" class="btn btn-outline btn-sm">로그인</a>
                    <a href="${pageContext.request.contextPath}/member/register" class="btn btn-primary btn-sm">회원가입</a>
                </div>
            </sec:authorize>
        <div class="side-menu-body">
        
         <!-- 일정 계획 (기업회원은 표시하지 않음) -->
                <div class="side-menu-section">
                	<sec:authorize access="!isAuthenticated() or hasRole('MEMBER')">
                    <div class="side-menu-section-title" onclick="toggleMenuSection(this)">
                        <span><i class="bi bi-calendar3 me-2"></i>일정 계획</span>
                        <i class="bi bi-chevron-down"></i>
                    </div>
                    <div class="side-menu-section-content">
                        <a href="${pageContext.request.contextPath}/schedule/search" class="side-menu-item">
                            <i class="bi bi-calendar-plus me-2"></i>일정 계획
                        </a>
	            <sec:authorize access="hasRole('MEMBER')">
                            <a href="${pageContext.request.contextPath}/schedule/my" class="side-menu-item">
                                <i class="bi bi-calendar-check me-2"></i>내 일정
                            </a>
                            <a href="${pageContext.request.contextPath}/schedule/bookmark" class="side-menu-item">
                                <i class="bi bi-bookmark me-2"></i>내 북마크
                            </a>
                        </sec:authorize>
                    </div>
                    </sec:authorize>
                </div>
        	
        	<!-- 기업 관리 -->
        	<sec:authorize access="isAuthenticated()">
	        <div class="side-menu-section">
                	<sec:authorize access="!isAuthenticated() or hasRole('BUSINESS')">
	                <div class="side-menu-section-title" onclick="toggleMenuSection(this)">
	                    <span><i class="bi bi-bag me-2"></i>기업 관리</span>
	                    <i class="bi bi-chevron-down"></i>
	                </div>
	                <div class="side-menu-section-content">
	                    <a href="${pageContext.request.contextPath}/mypage/business/dashboard" class="side-menu-item">
                        	<i class="bi bi-speedometer2 me-2"></i>대시보드
                        </a>
	                        <a href="${pageContext.request.contextPath}/product/manage" class="side-menu-item">
	                            <i class="bi bi-gear me-2"></i>상품 관리
	                        </a>
						<a href="${pageContext.request.contextPath}/mypage/business/sales" class="side-menu-item">
                            <i class="bi bi-graph-up me-2"></i>매출 집계
                        </a>
                        <a href="${pageContext.request.contextPath}/mypage/business/statistics" class="side-menu-item">
                              <i class="bi bi-bar-chart me-2"></i>통계
                        </a>
	                </div>
	                    </sec:authorize>
	            </div>
	            </sec:authorize>
           
            <!-- 관광 상품 -->
            <div class="side-menu-section">
                <div class="side-menu-section-title" onclick="toggleMenuSection(this)">
                    <span><i class="bi bi-map me-2"></i>관광 상품</span>
                    <i class="bi bi-chevron-down"></i>
                </div>
                <div class="side-menu-section-content">
                    <sec:authorize access="hasRole('BUSINESS')">
<%--                         <a href="${pageContext.request.contextPath}/product/manage" class="side-menu-item"> --%>
<!--                             <i class="bi bi-gear me-2"></i>상품 관리 -->
<!--                         </a> -->
                    </sec:authorize>
                    <a href="${pageContext.request.contextPath}/product/flight" class="side-menu-item">
                        <i class="bi bi-airplane me-2"></i>항공
                    </a>
                    <a href="${pageContext.request.contextPath}/product/accommodation" class="side-menu-item">
                        <i class="bi bi-building me-2"></i>숙박
                    </a>
                    <a href="${pageContext.request.contextPath}/tour" class="side-menu-item">
                        <i class="bi bi-ticket-perforated me-2"></i>투어/체험/티켓
                    </a>
                </div>
            </div>

            <!-- 커뮤니티 -->
            <div class="side-menu-section">
                <div class="side-menu-section-title" onclick="toggleMenuSection(this)">
                    <span><i class="bi bi-people me-2"></i>커뮤니티</span>
                    <i class="bi bi-chevron-down"></i>
                </div>
                <div class="side-menu-section-content">
                     <sec:authorize access="hasRole('MEMBER')">
                        <a href="${pageContext.request.contextPath}/community/talk" class="side-menu-item">
                            <i class="bi bi-chat-dots me-2"></i>여행톡
                        </a>
                    </sec:authorize>
                    <a href="${pageContext.request.contextPath}/community/travel-log" class="side-menu-item">
                        <i class="bi bi-journal-richtext me-2"></i>여행기록
                    </a>
                </div>
            </div>

			 <!-- 마이페이지 (로그인 회원만) -->
            <sec:authorize access="isAuthenticated()">
                <div class="side-menu-section">
                    <div class="side-menu-section-title" onclick="toggleMenuSection(this)">
                        <span><i class="bi bi-person-circle me-2"></i>마이페이지</span>
                        <i class="bi bi-chevron-down"></i>
                    </div>
                    <div class="side-menu-section-content">
                            <sec:authorize access="hasRole('BUSINESS')">
<%--                                 <a href="${pageContext.request.contextPath}/mypage/business/dashboard" class="side-menu-item"> --%>
<!--                                     <i class="bi bi-speedometer2 me-2"></i>대시보드 -->
<!--                                 </a> -->
                                <a href="${pageContext.request.contextPath}/mypage/business/profile" class="side-menu-item">
                                    <i class="bi bi-person me-2"></i>회원 정보 수정
                                </a>
<%--                                 <a href="${pageContext.request.contextPath}/mypage/business/sales" class="side-menu-item"> --%>
<!--                                     <i class="bi bi-graph-up me-2"></i>매출 집계 -->
<!--                                 </a> -->
<%--                                 <a href="${pageContext.request.contextPath}/mypage/business/products" class="side-menu-item"> --%>
<!--                                     <i class="bi bi-box me-2"></i>내 상품 현황 -->
<!--                                 </a> -->
                                <a href="${pageContext.request.contextPath}/mypage/business/notifications" class="side-menu-item">
                                    <i class="bi bi-bell me-2"></i>알림 내역
                                </a>
<%--                                 <a href="${pageContext.request.contextPath}/mypage/business/statistics" class="side-menu-item"> --%>
<!--                                     <i class="bi bi-bar-chart me-2"></i>통계 -->
<!--                                 </a> -->
                                <a href="${pageContext.request.contextPath}/mypage/business/inquiries" class="side-menu-item">
                                    <i class="bi bi-chat-dots me-2"></i>운영자 문의
                                </a>
                            </sec:authorize>
                            <sec:authorize access="hasRole('MEMBER')">
                                <a href="${pageContext.request.contextPath}/mypage/profile" class="side-menu-item">
                                    <i class="bi bi-person me-2"></i>회원 정보 수정
                                </a>
                                <a href="${pageContext.request.contextPath}/mypage/schedules" class="side-menu-item">
                                    <i class="bi bi-calendar-check me-2"></i>내 일정
                                </a>
                                <a href="${pageContext.request.contextPath}/mypage/payments/list" class="side-menu-item">
                                    <i class="bi bi-credit-card me-2"></i>결제 내역
                                </a>
                                <a href="${pageContext.request.contextPath}/mypage/points" class="side-menu-item">
                                    <i class="bi bi-coin me-2"></i>포인트 내역
                                </a>
                                <a href="${pageContext.request.contextPath}/mypage/bookmarks" class="side-menu-item">
                                    <i class="bi bi-bookmark me-2"></i>내 북마크
                                </a>
                                <a href="${pageContext.request.contextPath}/mypage/notifications" class="side-menu-item">
                                    <i class="bi bi-bell me-2"></i>알림 내역
                                </a>
                                <a href="${pageContext.request.contextPath}/mypage/inquiries" class="side-menu-item">
                                    <i class="bi bi-chat-dots me-2"></i>운영자 문의
                                </a>
							</sec:authorize>
                    </div>
                </div>
            </sec:authorize>

            <!-- 고객지원 -->
            <div class="side-menu-section">
                <div class="side-menu-section-title" onclick="toggleMenuSection(this)">
                    <span><i class="bi bi-headset me-2"></i>고객지원</span>
                    <i class="bi bi-chevron-down"></i>
                </div>
                <div class="side-menu-section-content">
                    <a href="${pageContext.request.contextPath}/support/faq" class="side-menu-item">
                        <i class="bi bi-question-circle me-2"></i>자주 묻는 질문
                    </a>
                    <a href="${pageContext.request.contextPath}/support/notice" class="side-menu-item">
                        <i class="bi bi-megaphone me-2"></i>공지사항
                    </a>
                    <a href="${pageContext.request.contextPath}/support/inquiry" class="side-menu-item">
                        <i class="bi bi-envelope me-2"></i>1:1 문의
                    </a>
                </div>
            </div>

            <!-- AI 챗봇 -->
            <div class="side-menu-section">
                <a href="#" class="side-menu-section-title chatbot-link" onclick="showChatbotFromMenu(); toggleSideMenu(); return false;">
                    <span><i class="bi bi-robot me-2"></i>AI 챗봇</span>
                </a>
            </div>
        </div>
    </div>

    <!-- 알림 패널 (로그인 시에만 표시) -->
    
    <sec:authorize access="isAuthenticated()">
        <div class="notification-overlay" id="notificationOverlay" onclick="closeNotificationPanel()"></div>
        <div class="notification-panel" id="notificationPanel">
            <div class="notification-panel-header">
                <h4><i class="bi bi-bell me-2"></i>알림</h4>
                <button class="notification-close-btn" onclick="closeNotificationPanel()">
                    <i class="bi bi-x-lg"></i>
                </button>
            </div>
            <div class="notification-panel-body" id="notificationList">
                <!-- 알림 목록 -->
                <div class="notification-item unread">
                    <div class="notification-icon success">
                        <i class="bi bi-check-circle"></i>
                    </div>
                    <div class="notification-content">
                        <p class="notification-text">결제가 완료되었습니다.</p>
                        <span class="notification-meta">제주 스쿠버다이빙 체험</span>
                        <span class="notification-time">10분 전</span>
                    </div>
                </div>
                <div class="notification-item unread">
                    <div class="notification-icon info">
                        <i class="bi bi-info-circle"></i>
                    </div>
                    <div class="notification-content">
                        <p class="notification-text">이용일이 3일 남았습니다.</p>
                        <span class="notification-meta">부산 요트 투어</span>
                        <span class="notification-time">1시간 전</span>
                    </div>
                </div>
                <div class="notification-item unread">
                    <div class="notification-icon primary">
                        <i class="bi bi-gift"></i>
                    </div>
                    <div class="notification-content">
                        <p class="notification-text">1,360 포인트가 적립되었습니다.</p>
                        <span class="notification-meta">결제 적립</span>
                        <span class="notification-time">2시간 전</span>
                    </div>
                </div>
                <div class="notification-item">
                    <div class="notification-icon">
                        <i class="bi bi-megaphone"></i>
                    </div>
                    <div class="notification-content">
                        <p class="notification-text">새로운 공지사항이 등록되었습니다.</p>
                        <span class="notification-meta">[이벤트] 겨울 특가 프로모션</span>
                        <span class="notification-time">1일 전</span>
                    </div>
                </div>
                <div class="notification-item">
                    <div class="notification-icon success">
                        <i class="bi bi-chat-dots"></i>
                    </div>
                    <div class="notification-content">
                        <p class="notification-text">문의에 대한 답변이 등록되었습니다.</p>
                        <span class="notification-meta">1:1 문의</span>
                        <span class="notification-time">2일 전</span>
                    </div>
                </div>
            </div>
            <div class="notification-panel-footer">
                <button class="btn btn-sm btn-outline" onclick="readAllAlarm()">모두 읽음 처리</button>
            </div>
        </div>
    </sec:authorize>
	
	<!-- FullCalendar JS (CDN) -->
	<script src='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.5/main.min.js'></script>
	<link href='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.5/main.min.css' rel='stylesheet' />
    <!-- 로그인 상태 전역 변수 및 사이드 메뉴 함수 -->
    <script>
    var isLoggedIn =
    	<sec:authorize access="isAuthenticated()">true</sec:authorize>
    	<sec:authorize access="isAnonymous()">false</sec:authorize>;

        // 사이드 메뉴 토글 (햄버거 메뉴용 - 즉시 사용 가능하도록 header에 정의)
        function toggleSideMenu() {
            var sideMenu = document.getElementById('sideMenu');
            var overlay = document.getElementById('sideMenuOverlay');
            var hamburgerBtn = document.getElementById('hamburgerBtn');
            var body = document.body;

            if (sideMenu) sideMenu.classList.toggle('active');
            if (overlay) overlay.classList.toggle('active');
            if (hamburgerBtn) hamburgerBtn.classList.toggle('active');
            body.classList.toggle('menu-open');
        }

        // 사이드 메뉴 섹션 토글
        function toggleMenuSection(element) {
            var section = element.closest('.side-menu-section');
            var allSections = document.querySelectorAll('.side-menu-section');

            allSections.forEach(function(sec) {
                if (sec !== section && sec.classList.contains('open')) {
                    sec.classList.remove('open');
                }
            });

            if (section) section.classList.toggle('open');
        }

        // 알림 패널 토글
        function toggleNotificationPanel() {
        	let notificationListEle = document.querySelector("#notificationList");
            var panel = document.getElementById('notificationPanel');
            var overlay = document.getElementById('notificationOverlay');

            if (panel && overlay) {
                panel.classList.toggle('active');
                overlay.classList.toggle('active');
            }
            
            let html = ``;
            axios.post(`/api/alarm/list`
            ).then(res => {
            	let list = res.data;	// 알람 목록
            	if (!list || list.length === 0) {
            	      notificationListEle.innerHTML = `
            	        <div class="notification-empty">새 알림이 없습니다.</div>
            	      `;
            	      return;
            	    }
            	
            	list.map(function(v,i){
            		let time = formatRelativeTime(`\${v.regDt}`);
            		let type = checkType(`\${v.alarmType}`);
            			html += `
            				<div class="notification-item \${v.readYn === 'N' ? 'unread' : ''}">


	                        <div class="notification-icon second">
	                            <i class="bi bi-check-circle"></i>
	                        </div>
	                        <div class="notification-content">
	                            <p class="notification-text">\${v.alarmCont}</p>
	                            <span class="notification-meta">\${type}</span>
	                            <span class="notification-time">\${time}</span>
	                        </div>
	                    </div>
            		`;
            	});
           		notificationListEle.innerHTML = html;
            });
        }

        // 알림 패널 닫기
        function closeNotificationPanel() {
            var panel = document.getElementById('notificationPanel');
            var overlay = document.getElementById('notificationOverlay');

            if (panel) panel.classList.remove('active');
            if (overlay) overlay.classList.remove('active');
        }

        // 모두 읽음 처리
			   function readAllAlarm() {
			
			  axios.post(`/api/alarm/mypage/notifications/readAll`)
			    .then(res => {
			      // ✅ 1) 서버 성공 후 UI 처리 (기존 코드 그대로)
			      var items = document.querySelectorAll('.notification-item.unread');
			      items.forEach(function(item) {
			        item.classList.remove('unread');
			      });
			
			      var badge = document.getElementById('notificationBadge');
			      if (badge) {
			        badge.style.display = 'none';
			      }
			
			      // ✅ 2) 목록 다시 불러와서 최신화(선택이지만 추천)
			      toggleNotificationPanel(); // 열려있을 때 한번 더 갱신하려면 아래 방식 추천
			      // 또는 더 안전하게: panel 유지하고 list만 다시 불러오는 함수를 따로 빼도 됨
			
			      if (typeof showToast === 'function') {
			        showToast('모든 알림을 읽음 처리했습니다.', 'success');
			      }
			    })
			    .catch(err => {
			      console.error(err);
			      if (typeof showToast === 'function') {
			        showToast('모두 읽음 처리에 실패했습니다.', 'danger');
			      }
			    });
			}

        
     // ---- 헤더용 캘린더 ----
        let scheduleModalObj = null; // 전역 변수로 관리 (재사용 목적)
        let headerCalendar = null;

        async function openScheduleModal() {
            const modalEl = document.getElementById('headerScheduleModal');
            if (!modalEl) return;

            // 모달 객체가 없으면 새로 만들고, 있으면 기존꺼 쓰기 (그림자 중첩 방지 핵심!)
            if (!scheduleModalObj) {
                scheduleModalObj = new bootstrap.Modal(modalEl);
            }
            
            // 모달 띄우기
            scheduleModalObj.show();

            // 모달이 '완전히 떴을 때' 캘린더를 그려야 크기가 안 깨져 (setTimeout 대신 이벤트 사용)
            modalEl.addEventListener('shown.bs.modal', async function () {
                const calendarEl = document.getElementById('headerScheduleCalendar');
                
                if (!headerCalendar) {
                    // 처음 열 때만 초기화
                    headerCalendar = new FullCalendar.Calendar(calendarEl, {
                        initialView: 'dayGridMonth',
                        locale: 'ko',
                        height: 450,
                        headerToolbar: { left: 'prev,next', center: 'title', right: 'today' },
                        events: async function(info, successCallback, failureCallback) {
                            try {
                                const res = await fetch('${pageContext.request.contextPath}/api/schedule/list');
                                
                                // 404 에러 등 체크
                                if(!res.ok) throw new Error("서버 에러");
                                
                                const data = await res.json();
                                
                                const events = data.map(s => ({
                                    id: s.schdlNo,
                                    title: s.schdlNm,
                                    start: s.schdlStartDt,
                                    end: s.calendarEndDt,
                                    // 상태에 따른 클래스 추가 (upcoming, ongoing, completed)
                                    className: 'fc-event-' + (s.schdlStatus ? s.schdlStatus.toLowerCase() : 'upcoming'),
                                    extendedProps: { ...s }
                                }));
                                successCallback(events);
                            } catch (e) {
                                console.error("일정 로딩 실패", e);
                                failureCallback(e);
                            }
                        },
                        eventClick: function(info) {
                            location.href = `${pageContext.request.contextPath}/schedule/view/\${info.event.id}`;
                        }
                    });
                    headerCalendar.render();
                } else {
                    // 이미 캘린더가 있으면 크기 재조정 + 데이터 갱신
                    headerCalendar.updateSize();
                    headerCalendar.refetchEvents();
                }
            }, { once: true }); // 이 이벤트 리스너는 한 번만 실행
        }
        //setInterval
     

        (() => {
        	  
        	  const contextPath = '${pageContext.request.contextPath}';
        	  const badge = document.getElementById('notificationBadge');
        	  if (!badge) return;

        	  const api = (p) => contextPath + (p.startsWith('/') ? p : '/' + p);
        	  
        	  let lastCount = -1;
        	  
        	  async function fetchUnreadCount(){
        	    try{
        	      const res = await fetch(api('/api/alarm/unread-count'), {
        	        credentials: 'same-origin'
        	      });
        	      const cnt = await res.json();
        	      if(lastCount !== -1 && cnt > lastCount){
        	          const btn = document.querySelector('.header-notification-btn');
        	          if(btn){
        	            btn.classList.remove('notification-pulse');
        	            void btn.offsetWidth; // 애니메이션 리셋
        	            btn.classList.add('notification-pulse');
        	          }
        	      }
        	      
        	      lastCount = cnt;
        	      
        	      if(cnt > 0){
        	        badge.textContent = cnt > 99 ? '99+' : cnt;
        	        badge.style.display = 'inline-block';
        	      }else{
        	        badge.style.display = 'none';
        	      }
        	    }catch(e){
        	      console.error('unread-count error', e);
        	    }
        	  }

        	  // 🔹 최초 로딩 시 1회
        	  fetchUnreadCount();

        	  // 🔹 10초마다 갱신
        	  setInterval(fetchUnreadCount, 10000);
        	})(); 
        
        
        
        function checkType(typeCode){
        	let type = '';
        	if(typeCode != null || typeCode != ''){
        		if(typeCode == 'POINT')
        			type = '포인트';
        		if(typeCode == 'PAYMENT')
        			type = '결제';
        		if(typeCode == 'TRAVEL_LOG')
        			type = '여행기록';
        		if(typeCode == 'TALK')
        			type = '여행톡';
        		if(typeCode == 'INQUIRY' || typeCode == 'PROD_INQUIRY')
        			type = '문의';
        		if(typeCode == 'REVIEW')
        			type = '리뷰';
        		if(typeCode == 'PROD')
        			type = '상품';
        		if(typeCode == 'SETTLEMENT')
        			type = '정산';
        		if(typeCode == 'REPORT')
        			type = '신고';
        	}
        		
        	return type;
        }
        
        // '2026-01-26 14:00:20'과 같은 시간 데이터가 들어올 때, 몇분전/몇시간전/몇일전과 같은 내용 만들어주는 이벤트
        function formatRelativeTime(dateString) {
		    const start = new Date(dateString);
		    const end = new Date(); // 현재 시간
		
		    // 두 날짜의 차이 (밀리초 단위)
		    const diffInMs = end - start;
		    
		    // 밀리초를 각 단위로 변환
		    const diffInSeconds = Math.floor(diffInMs / 1000);
		    const diffInMinutes = Math.floor(diffInSeconds / 60);
		    const diffInHours = Math.floor(diffInMinutes / 60);
		    const diffInDays = Math.floor(diffInHours / 24);
		
		    // 출력 로직
		    if (diffInSeconds < 60) {
		        return "방금 전";
		    } else if (diffInMinutes < 60) {
		        return `\${diffInMinutes}분 전`;
		    } else if (diffInHours < 24) {
		        return `\${diffInHours}시간 전`;
		    } else if (diffInDays < 30) {
		        return `\${diffInDays}일 전`;
		    } else {
		        // 한 달 이상 차이 날 경우 날짜 그대로 출력 (예: 2026-01-13)
		        return start.toISOString().split('T')[0];
		    }
		}
        
    </script>

    <!-- 메인 콘텐츠 시작 -->
    <main class="main-content">
