<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<c:set var="pageTitle" value="기업 대시보드" />
<c:set var="pageCss" value="mypage" />

<%@ include file="../../common/header.jsp" %>
<!-- chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script> 

<div class="mypage business-mypage">
    <div class="container">
        <div class="mypage-container no-sidebar">
            <!-- 메인 콘텐츠 -->
            <div class="mypage-content full-width">
                <div class="mypage-header">
                    <h1>대시보드</h1>
                    <p>비즈니스 현황을 한눈에 확인하세요</p>
                </div>

                <!-- 통계 카드 -->
                <div class="stats-grid">
                    <div class="stat-card primary">
                        <div class="stat-icon">₩</div>
                        <div class="stat-value" id="monthlySales">
						    <fmt:formatNumber value="${dashboard.kpi.monthlySales}" pattern="#,###"/>
						</div>
                        <div class="stat-label">이번 달 매출</div>
                    </div>
                    <div class="stat-card secondary">
                        <div class="stat-icon"><i class="bi bi-cart-check"></i></div>   
                        <div class="stat-value" id="monthlyReservations">${dashboard.kpi.monthlyReservations}</div>
                        <div class="stat-label">이번 달 예약</div>
                    </div>
                    <div class="stat-card accent">
                        <div class="stat-icon"><i class="bi bi-box-seam"></i></div>
                        <div class="stat-value" id="sellingProductCount">${dashboard.kpi.sellingProductCount}</div>
                        <div class="stat-label">등록 상품</div>
                    </div>
                    <div class="stat-card warning">
                        <div class="stat-icon"><i class="bi bi-star-fill"></i></div>
                        <div class="stat-value">4.3</div>
                        <div class="stat-label">평균 평점</div>
                    </div>
                </div>

                <div class="row">
					<!-- 차트 영역 -->
					<div class="dashboard-charts-row" style="display: flex; gap: 10px;">
						<div class="content-section" style="flex: 1; min-width: 0; "> <div class="section-header">
					            <h3><i class="bi bi-pie-chart"></i> 상품 구성</h3>
					        </div>
					       <div class="chart-container" style="
						        position: relative; flex: 1; display: flex;  justify-content: center;
						        align-items: center; min-height: 250px; padding: 10px;
						    ">
					            <canvas id="categoryChart"></canvas>
					        </div>
					    </div>
					    
					    <div class="content-section" style="flex: 3; min-width: 0; display: flex; flex-direction: column;"> <div class="section-header">
					            <h3><i class="bi bi-graph-up"></i> 매출 현황 (최근 6개월)</h3>
					        </div>
					        <div class="chart-container" style="
					        	justify-content: center;
						        position: relative; 
						        height: 280px;   
						        width: 95%;         
						        margin: auto;   
						    ">
					            <canvas id="myChart" style="max-width: 95%; max-height: 95%;"></canvas>
					        </div>
					    </div>
					</div>
					
					<!-- 
					<div class="dashboard-row" style="display: flex; gap: 20px; margin-top: 20px;">
					    <div class="content-section" style="flex: 1; min-width: 0;">
					        <div class="section-header" style="display: flex; justify-content: space-between;">
					            <h3><i class="bi bi-calendar-check"></i> 다가오는 예약</h3>
					            <span class="badge bg-primary">오늘 ${dashboard.todayArrivalCount}건</span>
					        </div>
					        <div class="list-container" id="upcomingReservations" style="height: 300px; overflow-y: auto;">
					            <ul class="list-group list-group-flush">
					                </ul>
					        </div>
					    </div>
					
					    <div class="content-section" style="flex: 1; min-width: 0;">
					        <div class="section-header">
					            <h3><i class="bi bi-chat-left-dots"></i> 최근 리뷰</h3>
					        </div>
					        <div class="list-container" id="recentReviews" style="height: 300px; overflow-y: auto;">
					            </div>
					    </div>
					</div> 
					 -->
                    <!-- 최근 예약 -->
                    <div class="col-lg-8">
                        <div class="content-section">
                            <div class="section-header">
                                <h3><i class="bi bi-receipt"></i> 최근 예약</h3>
                               <a href="${pageContext.request.contextPath}/mypage/business/products" class="view-all">
   									 전체보기 <i class="bi bi-arrow-right"></i>
							   </a>

                            </div>

                            <div class="table-responsive">
                                <table class="sales-table">
                                    <thead>
                                        <tr>
                                            <th>예약번호</th>
                                            <th>상품명</th>
                                            <th>예약자</th>
                                            <th>금액</th>
                                            <th>상태</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    	<c:choose>
                                    		<c:when test="${empty paymentList }">
                                    			<tr>
                                    				<td colspan="5">조회하신 결제 내역이 존재하지 않습니다.</td>
                                    			</tr>	
                                    		</c:when>
                                    		<c:otherwise>
                                    			<c:forEach items="${pagingPaymentList }" var="payment">
                                    				<c:set value="" var="etc"/>
                                    				<c:if test="${fn:length(payment.tripProdList) > 1 }">
                                    					<c:set value="외 ${fn:length(payment.tripProdList)-1 }개" var="etc"/>
                                    				</c:if>
                                    				<tr>
			                                            <td>${payment.payNo }</td>
			                                            <td>${payment.tripProdList[0].tripProdName } ${etc }</td>
			                                            <td>${payment.memName }</td>
			                                            <td class="text-primary fw-bold"><fmt:formatNumber value="${payment.payTotalAmt }" pattern="#,###,###"/> 원</td>
			                                            <td>
			                                            	<c:choose>
			                                            		<c:when test="${payment.payStatus eq 'DONE' }">
			                                            			<span class="payment-status completed">확정</span>
			                                            		</c:when>
			                                            		<c:otherwise>
			                                            			<span class="payment-status">취소</span>
			                                            		</c:otherwise>
			                                            	</c:choose>
			                                            </td>
			                                        </tr>
                                    			</c:forEach>
                                    		</c:otherwise>
                                    	</c:choose>
                                    </tbody>
                                </table>
                            </div>
                              <!-- 페이지네이션 -->
				              <div class="pagination-container">
								  <nav>
								    <ul class="pagination">
								      <c:if test="${pagingVO.startPage > 1}">
								        <li class="page-item">
								          <a class="page-link"
								             href="?type=${type}&page=${pagingVO.startPage - pagingVO.blockSize}">
								            <i class="bi bi-chevron-left"></i>
								          </a>
								        </li>
								      </c:if>
								
								      <c:forEach var="p" begin="${pagingVO.startPage}"
								                 end="${pagingVO.endPage < pagingVO.totalPage ? pagingVO.endPage : pagingVO.totalPage}">
								        <li class="page-item ${p == pagingVO.currentPage ? 'active' : ''}">
								          <a class="page-link" href="?page=${p}&searchWord=${searchWord}&ntcType=${ntcType}">${p}</a>
								        </li>
								      </c:forEach>
								
								      <c:if test="${pagingVO.endPage < pagingVO.totalPage}">
								        <li class="page-item">
								          <a class="page-link" href="?type=${type}&page=${pagingVO.endPage + 1}">
								            <i class="bi bi-chevron-right"></i>
								          </a>
								        </li>
								      </c:if>
								    </ul>
								  </nav>
								</div>
                        </div>
                    </div>

				     <!-- 알림 -->
				     
                     <div class="col-lg-4">
                        <div class="content-section">
							  <div class="section-header">
							    <h3><i class="bi bi-bell"></i> 알림</h3>
							    <a href="${pageContext.request.contextPath}/mypage/business/notifications" class="view-all">
							      전체보기 <i class="bi bi-arrow-right"></i>
							    </a>
							  </div>
							
							
<!-- 							  <ul class="noti-list" id="notiList"> -->
							    <!-- JS로 렌더링 -->
							    <!-- <li class="noti-empty">새로운 알림이 없습니다.</li>-->
							    <!-- /// 알람 반복 시작 /// -->
							    <c:forEach items="${alarmList}" var="alarm" begin="0" end="5" varStatus="vs">
								    <div class="notification-item unread">
<!-- 				                        <div class="notification-icon second"> -->
<!-- 				                            <i class="bi bi-check-circle"></i> -->
<!-- 				                        </div> -->
				                        <div class="notification-content">
				                            <p class="notification-text"><i class="bi bi-check-circle"></i> ${alarm.alarmCont}</p>
				                            <span class="notification-meta">${type}</span>
				                            <span class="notification-time"><small>${alarm.regDtStr}</small></span>
				                        </div>
				                    </div>
			                    </c:forEach>
			                    <!-- /// 알람 반복 끝 /// -->
<!-- 							  </ul> -->
							</div> 
							</div>
					


                <!-- 상품 현황 -->
                <div class="content-section">
                    <div class="section-header">
                        <h3><i class="bi bi-box-seam"></i> 상품 현황</h3>
                        <a href="${pageContext.request.contextPath}/mypage/business/products" class="view-all">
                            전체보기 <i class="bi bi-arrow-right"></i>
                        </a>
                    </div>

                    <div class="product-manage-list">
                        <c:choose>
				            <c:when test="${empty dashboard.productList}"> <div class="noti-empty">등록된 상품이 없습니다.</div>
				            </c:when>
				            <c:otherwise>
				                <c:forEach items="${dashboard.productList}" var="prod">
				                   <div class="product-manage-item">
									    <div class="product-manage-info">
									        <div class="product-image-container" style="width: 80px; height: 80px; overflow: hidden; border-radius: 8px;">
									            <c:choose>
									                <c:when test="${prod.prodCtgryType eq 'accommodation' or prod.prodCtgryType eq 'ACCOMMODATION'}">
									                    <img src="${not empty prod.thumbImage ? prod.thumbImage : (pageContext.request.contextPath += '/resources/images/no-image.png')}" 
									                         alt="${prod.title}" 
									                         style="width: 100%; height: 100%; object-fit: cover;">
									                </c:when>
									                
									                <c:when test="${prod.prodCtgryType ne 'accommodation' and not empty prod.thumbImage}">
									                    <%-- 투어/체험일 때는 기존처럼 /upload 붙여서 사용 --%>
									                    <img src="${pageContext.request.contextPath}/upload${prod.thumbImage}" 
									                         alt="${prod.title}"
									                         style="width: 100%; height: 100%; object-fit: cover;">
									                </c:when>
									                
									                <c:otherwise>
									                    <%-- 기본 이미지 --%>
									                    <img src="https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=200&h=150&fit=crop&q=80" 
									                         alt="기본이미지" style="width: 100%; height: 100%; object-fit: cover;">
									                </c:otherwise>
									            </c:choose>
									        </div>
									
									        <div class="product-manage-details">
									            <a href="${pageContext.request.contextPath}${prod.prodCtgryType eq 'accommodation' ? '/product/accommodation' : '/tour'}/${prod.tripProdNo}" 
									               style="text-decoration: none; color: inherit;">
									                <h4 style="margin-bottom: 4px;">${prod.title}</h4>
									            </a>
									            <%-- 카테고리 대문자/소문자 대응 --%>
									            <span class="category" style="font-size: 0.8rem; color: #666;">
									                ${(prod.prodCtgryType eq 'accommodation' || prod.prodCtgryType eq 'ACCOMMODATION') ? '숙박' : '투어/체험'}
									            </span>
									            <div class="price" style="font-weight: bold; color: #2563eb;">
									                <fmt:formatNumber value="${prod.price}" pattern="#,###"/>원
									            </div>
									        </div>
									    </div>
									
									    <div class="product-stats">
									        <div class="product-stat">
									            <div class="value">${not empty prod.viewCnt ? prod.viewCnt : 0}</div> <div class="label">조회</div>
									        </div>
<!-- 									        <div class="product-stat"> -->
<%-- 									            <div class="value">${not empty prod.resvCnt ? prod.viewCnt : 0}</div> <div class="label">예약</div> --%>
<!-- 									        </div> -->
									        <div class="product-stat">
									            <div class="value">${not empty prod.rating ? prod.rating : '0.0'}</div>
									            <div class="label">평점</div>
									        </div>
									    </div>
									
									    <%-- [2] 승인대기 상태 분기 로직 적용 --%>
									    <c:set var="isPending" value="${not empty prod.aprvYn and prod.aprvYn eq 'N'}" />
									    <span class="product-status ${isPending ? 'pending' : 'active'}" 
									          style="background-color: ${isPending ? '#ff9800' : '#10b981'}; color: white; padding: 2px 8px; border-radius: 4px; font-size: 0.75rem;">
									        ${isPending ? '승인대기' : (not empty prod.approveStatus ? prod.approveStatus : '판매중')}
									    </span>
									</div>
				                </c:forEach>
				            </c:otherwise>
				        </c:choose>
                    </div>
                </div>
                				
            </div>
		</div>


<script>
document.addEventListener('DOMContentLoaded', function() {
    // 1. 서버 데이터를 JS 객체로 변환 (컨트롤러에서 넘긴 변수명 확인!)
	const monthlySales = Number("${dashboard.kpi.monthlySales}");
    const monthlyReservations = Number("${dashboard.kpi.monthlyReservations}");
    
    const kpiData = {
        monthlySales: monthlySales || 0,
        monthlyReservations: monthlyReservations || 0,
        sellingProductCount: Number("${dashboard.kpi.sellingProductCount}") || 0
    };

    // 2. 파이 차트 (상품 구성 비율)
    const categoryCtx = document.getElementById('categoryChart').getContext('2d');
    const categoryLabels = [];
    const categoryValues = [];
    
    var categoryMap = {
            'tour': '투어',
            'activity': '액티비티',
            'ticket': '입장권/티켓',
            'class': '클래스/체험',
            'transfer': '교통/이동'
        };
    
    <c:forEach var="item" items="${dashboard.categoryRatio}">
        categoryLabels.push(categoryMap['${item.type}']);
        categoryValues.push(${item.cnt});
    </c:forEach>
	console.log(categoryLabels);
    new Chart(categoryCtx, {
        type: 'doughnut',
        data: {
            labels: categoryLabels,
            datasets: [{
                data: categoryValues,
                backgroundColor: ['#4e73df', '#1cc88a', '#36b9cc', '#f6c23e']
            }]
        },
        options: { maintainAspectRatio: false }
    });

    // 3. 바 차트 (최근 6개월 매출)
    const salesCtx = document.getElementById('myChart').getContext('2d');
    const salesLabels = [];
    const salesValues = [];
    salesLabels.push('0')
    salesValues.push(0)
    <c:forEach var="item" items="${dashboard.monthlySalesChart}">
        salesLabels.push('${item.month}');
        salesValues.push(${item.total});
    </c:forEach>

    new Chart(salesCtx, {
        type: 'line',
        data: {
            labels: salesLabels,
            datasets: [{
                label: '매출액',
                data: salesValues,
                borderColor: '#4e73df',
                backgroundColor: 'rgba(78, 115, 223, 0.05)',
                fill: true,
                tension: 0.3
            }]
        },
        options: { maintainAspectRatio: false }
    });

    // 4. 다가오는 예약 리스트 렌더링
//     const upcomingList = document.querySelector('#upcomingReservations ul');
//     <c:forEach var="res" items="${dashboard.upcomingReservations}">
//         upcomingList.innerHTML += `
//             <li class="list-group-item d-flex justify-content-between align-items-center">
//                 <div>
//                     <div class="fw-bold">\${res.prodName}</div> 
//                     <small class="text-muted">\${res.memName} | \${res.resvDate} \${res.useTime}</small>
//                 </div>
//                 <span class="badge bg-info rounded-pill">\${res.type}</span>
//             </li>`;
//     </c:forEach>

    // 3. 최근 리뷰 피드 (역슬래시 \ 추가!)
//     const reviewBox = document.querySelector('#recentReviews');
//     <c:forEach var="rv" items="${dashboard.recentReviews}">
//         reviewBox.innerHTML += `
//             <div class="p-3 border-bottom">
//                 <div class="d-flex justify-content-between">
//                     <strong>\${rv.memName}</strong>
//                     <span class="text-warning">` + '★'.repeat(Number("${rv.reviewStar}")) + `</span>
//                 </div>
//                 <div class="text-truncate small">\${rv.reviewContent}</div>
//                 <small class="text-muted" style="font-size: 0.7rem;">\${rv.prodName} | \${rv.regDate}</small>
//             </div>`;
//     </c:forEach>
});
</script>

<style>
.stat-icon {
  font-size: 1.6rem;
  font-weight: 700;
}
</style>



<c:set var="pageJs" value="mypage" />
<%@ include file="../../common/footer.jsp" %>
