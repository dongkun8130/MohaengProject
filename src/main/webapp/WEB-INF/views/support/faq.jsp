<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="pageTitle" value="자주 묻는 질문" />
<c:set var="pageCss" value="support" />

<%@ include file="../common/header.jsp" %>

<div class="support-page">
    <div class="container">
        <!-- 헤더 -->
        <div class="support-header">
            <h1><i class="bi bi-question-circle me-3"></i>자주 묻는 질문</h1>
            <p>궁금하신 내용을 찾아보세요</p>
        </div>

        <!-- 고객지원 네비게이션 -->
        <div class="support-nav">
            <a href="${pageContext.request.contextPath}/support/faq" class="support-nav-item active">
                <i class="bi bi-question-circle me-2"></i>FAQ
            </a>
            <a href="${pageContext.request.contextPath}/support/notice" class="support-nav-item">
                <i class="bi bi-megaphone me-2"></i>공지사항
            </a>
            <a href="${pageContext.request.contextPath}/support/inquiry" class="support-nav-item">
                <i class="bi bi-chat-dots me-2"></i>1:1 문의
            </a>
        </div>

        <div class="faq-container">
            <!-- 검색 -->
            <div class="faq-search">
                <div class="faq-search-input">
                    <input type="text" placeholder="궁금한 내용을 검색해보세요" id="faqSearch">
                    <button class="btn btn-primary" onclick="searchFaq()">
                        <i class="bi bi-search me-2"></i>검색
                    </button>
                </div>
            </div>

            <!-- 카테고리 -->
            <div class="faq-categories">
                <button class="faq-category active" data-category="all">전체</button>
                <button class="faq-category" data-category="account">회원/계정</button>
                <button class="faq-category" data-category="schedule">일정/예약</button>
                <button class="faq-category" data-category="payment">결제/환불</button>
                <button class="faq-category" data-category="point">포인트</button>
                <button class="faq-category" data-category="service">서비스 이용</button>
            </div>

            <!-- FAQ 리스트 -->
            <div class="faq-list">
                <c:choose>
                    <c:when test="${empty faqList}">
                        <div class="text-center py-5">
                            <i class="bi bi-inbox" style="font-size: 48px; color: var(--gray-light);"></i>
                            <p class="text-muted mt-3">등록된 FAQ가 없습니다.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${faqList}" var="faq">
                            <div class="faq-item" data-category="${faq.faqCategoryCd}" data-id="${faq.faqNo}">
                                <div class="faq-question">
                                    <div class="faq-question-text">
                                        <span class="badge
                                            <c:choose>
                                                <c:when test="${faq.faqCategoryCd == 'account'}">bg-info</c:when>
                                                <c:when test="${faq.faqCategoryCd == 'schedule'}">bg-success</c:when>
                                                <c:when test="${faq.faqCategoryCd == 'payment'}">bg-warning text-dark</c:when>
                                                <c:when test="${faq.faqCategoryCd == 'point'}">bg-primary</c:when>
                                                <c:otherwise>bg-secondary</c:otherwise>
                                            </c:choose>
                                        ">
                                            <c:choose>
                                                <c:when test="${faq.faqCategoryCd == 'account'}">회원/계정</c:when>
                                                <c:when test="${faq.faqCategoryCd == 'schedule'}">일정/예약</c:when>
                                                <c:when test="${faq.faqCategoryCd == 'payment'}">결제/환불</c:when>
                                                <c:when test="${faq.faqCategoryCd == 'point'}">포인트</c:when>
                                                <c:when test="${faq.faqCategoryCd == 'service'}">서비스 이용</c:when>
                                                <c:otherwise>기타</c:otherwise>
                                            </c:choose>
                                        </span>
                                        ${faq.faqTitle}
                                    </div>
                                    <i class="bi bi-chevron-down"></i>
                                </div>
                                <div class="faq-answer">
                                    <p>${faq.faqContent}</p>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- 추가 문의 안내 -->
            <div class="text-center mt-5">
                <p class="text-muted mb-3">원하는 답변을 찾지 못하셨나요?</p>
                <a href="${pageContext.request.contextPath}/support/inquiry" class="btn btn-outline btn-lg">
                    <i class="bi bi-chat-dots me-2"></i>1:1 문의하기
                </a>
            </div>
        </div>
    </div>
</div>

<script>
const contextPath = '${pageContext.request.contextPath}';

//카테고리 필터링
document.querySelectorAll('.faq-category').forEach(category => {
 category.addEventListener('click', function() {
     document.querySelectorAll('.faq-category').forEach(c => c.classList.remove('active'));
     this.classList.add('active');

     const cat = this.dataset.category;

     if (cat === 'all') {
         // 전체 보기
         document.querySelectorAll('.faq-item').forEach(item => {
             item.style.display = 'block';
         });
     } else {
         // 특정 카테고리만 필터링
         document.querySelectorAll('.faq-item').forEach(item => {
             if (item.dataset.category === cat) {
                 item.style.display = 'block';
             } else {
                 item.style.display = 'none';
             }
         });
     }
 });
});

//FAQ 아코디언 이벤트 바인딩
function bindAccordionEvents() {
 document.querySelectorAll('.faq-question').forEach(question => {
     question.removeEventListener('click', handleAccordionClick);
     question.addEventListener('click', handleAccordionClick);
 });
}

//아코디언 클릭 핸들러
function handleAccordionClick() {
 const item = this.closest('.faq-item');
 const wasActive = item.classList.contains('active');

 // 모든 아이템 닫기
 document.querySelectorAll('.faq-item').forEach(i => i.classList.remove('active'));

 // 클릭한 아이템 토글
 if (!wasActive) {
     item.classList.add('active');

  // 조회수 증가 로직 추가
     const faqNo = item.dataset.id; // 위에서 심은 data-id 값을 가져옴
     console.log("보내려는 FAQ 번호:", faqNo);
     if (faqNo) {
         fetch((contextPath + '/support/faq/' + faqNo + '/views').replace(/\/+/g, '/'), {
             method: 'PATCH'
         })
         .then(res => {
             if (res.ok) {
                 console.log(`FAQ ${faqNo}번 조회수 증가 성공 (서버 응답: void)`);
             }
         })
         .catch(error => console.error('조회수 요청 실패:', error));
     }
 }
}

//초기 아코디언 이벤트 바인딩
bindAccordionEvents();

//검색 함수
function searchFaq() {
 const keyword = document.getElementById('faqSearch').value.trim();

 if (!keyword) {
     alert('검색어를 입력해주세요.');
     return;
 }

 // AJAX 검색 요청
 fetch(contextPath + '/support/faq/search?keyword=' + encodeURIComponent(keyword))
     .then(response => response.json())
     .then(data => {
         if (data.length === 0) {
             document.querySelector('.faq-list').innerHTML = `
                 <div class="text-center py-5">
                     <i class="bi bi-search" style="font-size: 48px; color: var(--gray-light);"></i>
                     <p class="text-muted mt-3">검색 결과가 없습니다.</p>
                 </div>
             `;
         } else {
             renderFaqList(data);
         }

         // 카테고리 선택 초기화
         document.querySelectorAll('.faq-category').forEach(c => c.classList.remove('active'));
         document.querySelector('.faq-category[data-category="all"]').classList.add('active');
     })
     .catch(error => {
         console.error('Error:', error);
         alert('검색 중 오류가 발생했습니다.');
     });
}

//FAQ 리스트 렌더링 함수
function renderFaqList(faqList) {
 const faqListContainer = document.querySelector('.faq-list');
 let html = '';

 faqList.forEach(faq => {
     const categoryName = getCategoryName(faq.faqCategoryCd);
     const badgeClass = getBadgeClass(faq.faqCategoryCd);

     html += `
         <div class="faq-item" data-category="\${faq.faqCategoryCd}" data-id="\${faq.faqNo}">
             <div class="faq-question">
                 <div class="faq-question-text">
                     <span class="badge \${badgeClass}">\${categoryName}</span>
                     \${faq.faqTitle}
                 </div>
                 <i class="bi bi-chevron-down"></i>
             </div>
             <div class="faq-answer">
                 <p>\${faq.faqContent}</p>
             </div>
         </div>
     `;
 });

 faqListContainer.innerHTML = html;

 // 아코디언 이벤트 다시 바인딩
 bindAccordionEvents();
}

//카테고리명 반환
function getCategoryName(code) {
 const categories = {
     'account': '회원/계정',
     'schedule': '일정/예약',
     'payment': '결제/환불',
     'point': '포인트',
     'service': '서비스 이용'
 };
 return categories[code] || '기타';
}

//배지 클래스 반환
function getBadgeClass(code) {
 const badges = {
     'account': 'bg-info',
     'schedule': 'bg-success',
     'payment': 'bg-warning text-dark',
     'point': 'bg-primary',
     'service': 'bg-secondary'
 };
 return badges[code] || 'bg-secondary';
}

//엔터키로 검색
document.getElementById('faqSearch').addEventListener('keypress', function(e) {
 if (e.key === 'Enter') {
     searchFaq();
 }
});

//실시간 검색 (선택사항)
let searchTimeout;
document.getElementById('faqSearch').addEventListener('input', function() {
 clearTimeout(searchTimeout);

 const searchText = this.value.toLowerCase().trim();

 if (!searchText) {
     // 검색어가 없으면 전체 표시
     document.querySelectorAll('.faq-item').forEach(item => {
         item.style.display = 'block';
     });
     return;
 }

 // 클라이언트 사이드 필터링 (빠른 반응)
 searchTimeout = setTimeout(() => {
     const items = document.querySelectorAll('.faq-item');
     let hasResult = false;

     items.forEach(item => {
        const questionDiv = item.querySelector('.faq-question-text');
         const badge = questionDiv.querySelector('.badge');
         const titleText = questionDiv.textContent.replace(badge.textContent, '').trim().toLowerCase();

         if (titleText.includes(searchText)) {
             item.style.display = 'block';
             hasResult = true;
         } else {
             item.style.display = 'none';
         }
     });

     // 카테고리 선택 초기화
     if (hasResult) {
         document.querySelectorAll('.faq-category').forEach(c => c.classList.remove('active'));
         document.querySelector('.faq-category[data-category="all"]').classList.add('active');
     }
 }, 300); // 300ms 디바운싱
});
</script>

<c:set var="pageJs" value="support" />
<%@ include file="../common/footer.jsp" %>