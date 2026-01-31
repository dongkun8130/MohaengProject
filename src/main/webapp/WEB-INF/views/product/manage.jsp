<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="pageTitle" value="상품 관리" />
<c:set var="pageCss" value="product" />

<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/product-manage.css">

<div class="product-manage-page">
    <div class="container">
        <!-- 페이지 헤더 -->
        <div class="page-header">
            <div class="page-header-content">
                <h1 class="page-title">상품 관리</h1>
                <p class="page-subtitle">등록한 상품을 관리하고 새 상품을 등록하세요</p>
            </div>
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#productModal" onclick="setModalForNew()">
                <i class="bi bi-plus-lg me-2"></i>새 상품 등록
            </button>
        </div>

        <!-- 통계 카드 -->
        <div class="stats-row">
            <div class="stat-card">
                <div class="stat-icon primary">
                    <i class="bi bi-box-seam"></i>
                </div>
                <div class="stat-info">
	                <span class="stat-value">${prodAggregate.totalCount}</span>
                    <span class="stat-label">전체 상품</span>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon success">
                    <i class="bi bi-check-circle"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-value">${prodAggregate.approveCount}</span>
                    <span class="stat-label">판매중</span>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon warning">
                    <i class="bi bi-pause-circle"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-value">${prodAggregate.unapproveCount}</span>
                    <span class="stat-label">판매중지</span>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon info">
                    <i class="bi bi-cart-check"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-value">${prodAggregate.totalSales}</span>
                    <span class="stat-label">총 판매건수</span>
                </div>
            </div>
        </div>

        <!-- 필터 및 검색 -->
        <div class="filter-bar">
            <div class="filter-group">
            	<!-- 바뀔때마다 해당 상품만 조회 -->
                <select class="form-select" id="categoryFilter">
                    <option value="all">전체 카테고리</option>
                    <option value="tour">투어</option>
                    <option value="activity">액티비티</option>
                    <option value="ticket">입장권/티켓</option>
                    <option value="class">클래스/체험</option>
                    <option value="transfer">교통/이동</option>
                    <option value="accommodation">숙박</option>
                </select>
                <select class="form-select" id="statusFilter">
                    <option value="all">전체 상태</option>
                    <option value="active">판매중</option>
                    <option value="inactive">판매중지</option>
                </select>
            </div>
            <div class="search-group">
                <div class="search-input-wrapper">
                    <i class="bi bi-search"></i>
                    <input type="text" class="form-control" placeholder="상품명 검색" id="productSearch" />
                </div>
            </div>
        </div>

        <!-- 선택 기능 영역 -->
        <div class="product-selection-bar" id="productSelectionBar">
            <div class="selection-left">
                <label class="select-all-checkbox">
                    <input type="checkbox" id="selectAllProducts" onchange="toggleSelectAll(this)">
                    <span>전체 선택</span>
                </label>
                <span class="selected-count" id="selectedCount">개 선택됨</span>
            </div>
            <div class="selection-actions" id="selectionActions">
            	<!-- 인자 넣고 data-set하기? -->
                <button class="btn btn-outline btn-sm" onclick="pauseSelectedProducts()" title="선택한 상품 판매 중지">
                    <i class="bi bi-pause-circle me-1"></i>선택중지
                </button>
                <button class="btn btn-outline btn-sm" onclick="resumeSelectedProducts()" title="선택한 상품 판매 재개">
                    <i class="bi bi-play-circle me-1"></i>선택재개
                </button>
                <button class="btn btn-outline btn-sm text-danger" onclick="deleteSelectedProducts()" title="선택한 상품 삭제">
                    <i class="bi bi-trash me-1"></i>선택삭제
                </button>
            </div>
        </div>

        <!-- 상품 목록 -->
        <!-- 활성화 = active 비활성화 = inactive -->
        <div class="product-list">
        	<c:choose>
        		<c:when test="${empty prodList }">
        				<div class="no-results-msg">상품이 존재하지 않습니다.</div>
        		</c:when>
        		<c:otherwise>
		        	<c:forEach items="${prodList}" var="prod">
			        	<c:set var="status" value="${prod.approveStatus }"/>
			        	<c:set var="dataStatus" value="active"/>
			        	<c:if test="${status == '판매중지'}">
				        	<c:set var="dataStatus" value="inactive"/>
			        	</c:if>
			        	<c:if test="${prod.aprvYn eq 'N'}">
				        	<c:set var="dataStatus" value="pending"/>
			        	</c:if>
			        	<c:set var="accNo" value="${not empty prod.accommodation and prod.prodCtgryType eq 'accommodation' ? prod.accommodation.accNo : 0}"/>
			        	<!-- pending = 대기 -->
			            <div class="product-manage-card" data-id="${prod.tripProdNo}" data-status="${dataStatus}" data-no="${accNo}">
			                <label class="product-checkbox">
			                    <input type="checkbox" class="product-select-checkbox" value="${prod.tripProdNo}" onchange="toggleProductSelect(this)">
			                </label>
			                <div class="product-image">
								<c:choose>
									<c:when test="${not empty prod.accommodation and prod.prodCtgryType eq 'accommodation'}">
						                    <img src="${prod.accommodation.accFilePath}" alt="${prod.accommodation.accName }">
									</c:when>
									<c:when test="${prod.prodCtgryType ne 'accommodation'}">
					                    <img src="${pageContext.request.contextPath}/upload${prod.thumbImage}" 
					                    alt="${prod.tripProdTitle}">
				                   </c:when>
				                   <c:otherwise>
		                   			    <img src="https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=200&h=150&fit=crop&q=80" 
		                   			    alt="스쿠버다이빙">
				                   </c:otherwise>
								</c:choose>
			                    <span class="product-status ${dataStatus}">
			                    ${(not empty prod.aprvYn and prod.aprvYn == 'N') ? '승인대기' : status}
			                    </span>
			                </div>
			                <div class="product-info">
			                    <div class="product-category">
                   	               	<c:choose>
								        <c:when test="${prod.prodCtgryType eq 'tour'}">투어</c:when>
								        <c:when test="${prod.prodCtgryType eq 'activity'}">액티비티</c:when>
								        <c:when test="${prod.prodCtgryType eq 'ticket'}">입장권/티켓</c:when>
								        <c:when test="${prod.prodCtgryType eq 'class'}">클래스/체험</c:when>
								        <c:when test="${prod.prodCtgryType eq 'transfer'}">교통/이동</c:when>
								        <c:otherwise>숙박</c:otherwise>
								    </c:choose>
			                    </div>
			                    <c:choose>
			                    	<c:when test="${not empty prod.accommodation and prod.prodCtgryType eq 'accommodation'}">
				                    	<c:set var="title" value="${prod.accommodation.accName}" />
					                    <h3 class="product-name">
					                    	<a href="${pageContext.request.contextPath}/product/accommodation/${prod.accommodation.tripProdNo}">
					                    	${title }
					                    	</a>
					                    </h3>
			                    	</c:when>
			                    	<c:otherwise>
				                    	<c:set var="title" value="${prod.tripProdTitle}" />
					                    <h3 class="product-name">
					                    	<a href="${pageContext.request.contextPath}/tour/${prod.tripProdNo}">${title}</a>
					                    </h3>
			                    	</c:otherwise>
			                    </c:choose>
			                    <div class="product-meta">
			                        <span>
			                        	<i class="bi bi-geo-alt"></i>
	                   	               	<c:choose>
									        <c:when test="${prod.ctyNm eq '1'}">서울</c:when>
									        <c:when test="${prod.ctyNm eq '2'}">인천</c:when>
									        <c:when test="${prod.ctyNm eq '3'}">대전</c:when>
									        <c:when test="${prod.ctyNm eq '8'}">세종</c:when>
									        <c:when test="${prod.ctyNm eq '31'}">경기</c:when>
									        <c:when test="${prod.ctyNm eq '32'}">강원</c:when>
									        <c:when test="${prod.ctyNm eq '33'}">충북</c:when>
									        <c:when test="${prod.ctyNm eq '34'}">충남</c:when>
									        <c:when test="${prod.ctyNm eq '5'}">광주</c:when>
									        <c:when test="${prod.ctyNm eq '37'}">전북</c:when>
									        <c:when test="${prod.ctyNm eq '38'}">전남</c:when>
									        <c:when test="${prod.ctyNm eq '6'}">부산</c:when>
									        <c:when test="${prod.ctyNm eq '4'}">대구</c:when>
									        <c:when test="${prod.ctyNm eq '7'}">울산</c:when>
									        <c:when test="${prod.ctyNm eq '35'}">경북</c:when>
									        <c:when test="${prod.ctyNm eq '36'}">경남</c:when>
									        <c:otherwise>제주</c:otherwise>
									    </c:choose>
			                        	
			                        </span><!-- 지역 코드 -->
			                        <span>
			                        	<c:set var="avgRating" value="${empty prod.avgRating or prod.avgRating == 0 ? 0.0 : prod.avgRating}"/>
			                        	<c:set var="reviewCount" value="${empty prod.reviewCount or prod.reviewCount == 0 ? 0 : prod.reviewCount}"/>
										<i class="bi bi-star-fill text-warning"></i> ${avgRating} (${reviewCount })
			                        </span>
			                    </div>
			                    <div class="product-period">
			                        <i class="bi bi-calendar-range"></i>
			                        <span>
				                        <fmt:formatDate value="${prod.saleStartDt}" pattern="yyyy.MM.dd" /> ~ 
				                        <fmt:formatDate value="${prod.saleEndDt}" pattern="yyyy.MM.dd" />
			                        </span>
			                    </div>
			                    <div class="product-price">
			                    <c:choose>
			                    	<c:when test="${not empty prod.prodSale and prod.prodSale.discount > 0}">
				                        <span class="original-price">
				                        	<fmt:formatNumber value="${prod.prodSale.netprc}" pattern="#,###"/>원
				                        </span>
				                        <span class="sale-price">
				                        	<fmt:formatNumber value="${prod.displayPrice}" pattern="#,###"/>원
				                        </span>
				                        <span class="discount-rate">${prod.prodSale.discount}% 할인</span>
			                    	</c:when>
			                    	<c:when test="${not empty prod.prodSale and prod.prodSale.netprc > 0 and (empty prod.prodSale.discount or prod.prodSale.discount == 0)}">
			                    		<span class="sale-price">
				                        	<fmt:formatNumber value="${prod.displayPrice}" pattern="#,###"/>원
				                        </span>
			                    	</c:when>
			                    	<c:otherwise>
				                    	<!-- 숙박 상품인 경우, 할인된 가격도 가져와야됨  -->
				                        <span class="sale-price">
				                        	<fmt:formatNumber value="${prod.displayPrice}" pattern="#,###"/>원 ~
				                        </span>
			                    	</c:otherwise>
			                    </c:choose>
			                    </div>
			                </div>
			                <div class="product-stats">
			                	<!-- 여기도 값이 없을때 처리 해줘야됨
			                		price가 2개 있음
			                		숙소 = price
			                		다른 거는 여러 price
			                	 -->
			                    <div class="stat-item">
			                        <span class="stat-label">총 재고</span>
			                        <!-- accomodation일때는 구매내역으로 확인해야됨 -->
                					<c:set var="totalStock" value="${not empty prod.accommodation and prod.prodCtgryType eq 'accommodation' ? prod.accommodation.totalRoomCnt : prod.prodSale.totalStock}"/>
			                        <span class="stat-value stock-value">${totalStock}개</span>
			                    </div>
			                    <div class="stat-item">
			                        <span class="stat-label">현재 재고</span>
			                        <!-- 현 객실수 = 총 객실수에서 룸타입별 사용량 파악후 빼야됨 -->
                					<c:set var="curStock" value="${not empty prod.accommodation and prod.prodCtgryType eq 'accommodation' ? prod.accommodation.totalRoomCnt : prod.prodSale.curStock}"/>
			                        <span class="stat-value stock-value">${curStock }개</span>
			                    </div>
			                    <div class="stat-item">
			                        <span class="stat-label">조회수</span>
			                        <span class="stat-value">${empty prod.viewCnt or prod.viewCnt == 0 ? 0 : prod.viewCnt}</span>
			                    </div>
			                    <div class="stat-item">
			                        <span class="stat-label">예약수</span>
			                        <!-- 얘도 손봐야됨 -->
			                        <span class="stat-value">${prod.prodSale.totalStock - prod.prodSale.curStock}</span>
			                    </div>
			                    <div class="stat-item">
			                    	<!-- 구입항목이랑 대조해서 가져오기 -->
			                        <span class="stat-label">매출</span>
			                        <span class="stat-value">
			                        	<c:choose>
			                        		<c:when test="${not empty prod.prodSale.price and prod.prodSale.price > 0}">
					                        	<c:set var="price" value="${prod.prodSale.price * (prod.prodSale.totalStock - prod.prodSale.curStock)}"/>
					                        	<fmt:formatNumber value="${price}" pattern="#,###"/>원
			                        		</c:when>
			                        		<c:otherwise>
			                        			<!-- 숙소일때 설정해줘야됨 -->
												<div>0원</div>
			                        		</c:otherwise>
			                        	</c:choose>
			                        </span>
			                    </div>
			                </div>
			                <div class="product-actions">
			                	<c:choose>
			                		<c:when test="${accNo eq 0 }">
					                    <button class="btn btn-outline btn-sm" onclick="showDetail(this)"
					                    	data-id="${prod.tripProdNo}">
					                        <i class="bi bi-eye"></i> 상세보기
					                    </button>
			                		</c:when>
			                		<c:otherwise>
					                    <button class="btn btn-outline btn-sm" onclick="showDetail(this)"
					                    	data-id="${prod.tripProdNo}" data-no="${accNo}">
					                        <i class="bi bi-eye"></i> 상세보기
					                    </button>
			                		</c:otherwise>
			                	</c:choose>
			                    <button class="btn btn-outline btn-sm" onclick="editProduct(this)"
			                    	data-id="${prod.tripProdNo}" data-no="${accNo}">
			                        <i class="bi bi-pencil"></i> 수정
			                    </button>
			                    <button class="btn btn-outline btn-sm" onclick="toggleProductStatus(this)"
			                    	data-id="${prod.tripProdNo}" data-status="${prod.approveStatus}" data-aprv="${prod.aprvYn}">
			                        <i class="bi bi-pause"></i> 
			                        ${prod.approveStatus == '판매중' ? '중지' : '재개'}
<%-- 			                        ${(not empty prod.aprvYn && prod.aprvYn == 'N') ? '승인대기' : (status == '판매중' ? '중지' : '재개')} --%>
			                        <!-- 승인여부도 따져야됨 -->
			                        <!-- prod.aprvYn == 'Y' ? '승인' : 'wait = 대기' / 'N = 불허' -->
			                    </button>
			                    <button class="btn btn-outline btn-sm text-danger" onclick="deleteProduct(this)"
			                    	data-id="${prod.tripProdNo}">
			                        <i class="bi bi-trash"></i> 삭제
			                    </button>
			                </div>
			            </div>
		            </c:forEach>
        		</c:otherwise>
        	</c:choose>
        </div>

        <!-- 인피니티?? 할지 말지 -->
        <!-- 페이지네이션 -->
        <div class="pagination-container">
            <nav>
                <ul class="pagination">
                    <li class="page-item">
                        <a class="page-link" href="#"><i class="bi bi-chevron-left"></i></a>
                    </li>
                    <li class="page-item active"><a class="page-link" href="#">1</a></li>
                    <li class="page-item"><a class="page-link" href="#">2</a></li>
                    <li class="page-item"><a class="page-link" href="#">3</a></li>
                    <li class="page-item">
                        <a class="page-link" href="#"><i class="bi bi-chevron-right"></i></a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>
</div>

<!-- 상품 등록/수정 모달 -->
<div class="modal fade" id="productModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="productModalTitle">새 상품 등록</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="productForm">
	                <input type="hidden" name="tripProdNo"/>
                    <div class="row mb-3">
                    	<div>
	                        <!-- <button type="button" class="icon-fill-btn" onclick="fillFlightInfo()" title="정보 자동 채우기">
							    <i class="bi bi-info-circle-fill"></i> 
							</button> -->
							<button type="button" class="icon-fill-btn" onclick="fillProductInfo()" title="정보 자동 채우기">
							    <i class="bi bi-magic"></i>
							</button>
						</div>
                        <div class="col-md-4">
                            <label class="form-label">카테고리 <span class="text-danger">*</span></label>
                            <select class="form-select" name="prodCtgryType" id="productCategory" required onchange="toggleCategoryFields()">
                                <option value="">선택하세요</option>
                                <option value="tour">투어</option>
                                <option value="activity">액티비티</option>
                                <option value="ticket">입장권/티켓</option>
                                <option value="class">클래스/체험</option>
                                <option value="transfer">교통/이동</option>
                                <option value="accommodation">숙박</option>
                            </select>
                        </div>
                        <div class="col-md-4" id="regionField">
                        	<input type="hidden" name="accommodation.areaCode"/>
                            <label class="form-label">지역 <span class="text-danger">*</span></label>
                            <select class="form-select" name="ctyNm">
                                <option value="">선택하세요</option>
                                <optgroup label="수도권">
                                    <option value="1">서울</option>
                                    <option value="31">경기</option>
                                    <option value="2">인천</option>
                                </optgroup>
                                <optgroup label="강원권">
                                    <option value="32">강원</option>
                                </optgroup>
                                <optgroup label="충청권">
                                    <option value="3">대전</option>
                                    <option value="8">세종</option>
                                    <option value="33">충북</option>
                                    <option value="34">충남</option>
                                </optgroup>
                                <optgroup label="전라권">
                                    <option value="5">광주</option>
                                    <option value="37">전북</option>
                                    <option value="38">전남</option>
                                </optgroup>
                                <optgroup label="경상권">
                                    <option value="6">부산</option>
                                    <option value="4">대구</option>
                                    <option value="7">울산</option>
                                    <option value="35">경북</option>
                                    <option value="36">경남</option>
                                </optgroup>
                                <optgroup label="제주권">
                                    <option value="39">제주</option>
                                </optgroup>
                            </select>
                        </div>
                        <div class="col-md-4" id="durationField">
                            <label class="form-label">소요시간 <span class="text-danger">*</span></label>
                            <select class="form-select" name="prodSale.leadTime">
                                <option value="">선택하세요</option>
                                <option value="1">1시간 이내</option>
                                <option value="3">1~3시간</option>
                                <option value="6">3~6시간</option>
                                <option value="24">하루 이상</option>
                            </select>
                        </div>
                    </div>

                    <div class="mb-3" id="productNameField">
                        <label class="form-label">상품명 <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="tripProdTitle" placeholder="상품명을 입력하세요" required>
                    </div>
                    <!-- 숙소 정보 있으면 이 필드 input readOnly -->
                    <div class="mb-3" id="accommodationNameField" style="display:none;">
                        <label class="form-label">숙소명 <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="accommodation.accName" placeholder="숙소명 입력하세요" readonly required>
                        <label class="form-label">숙소 전화번호<span class="text-danger">*</span></label>
                        <!-- 수정가능 -->
                        <input type="text" class="form-control" name="accommodation.tel" placeholder="010-1234-1234" required>
                    </div>
                    <div class="mb-3" id="locationField">
                        <label class="form-label">위치 정보 <span class="text-danger">*</span></label>
                        <div id="prodAddress">
	                        <div class="row g-2">
	                            <div class="col-md-10">
	                                <input type="text" class="form-control" name="prodPlace.addr1" id="productAddress" placeholder="상품 주소를 검색하세요" required readonly>
	                            </div>
	                            <div class="col-md-2">
	                                <button type="button" class="btn btn-outline w-100" id="searchProdBtn" onclick="searchAddress()">
	                                    <i class="bi bi-search"></i> 검색
	                                </button>
	                            </div>
	                        </div>
	                        <input type="text" class="form-control mt-2" name="prodPlace.addr2" placeholder="상세주소 (건물명, 층, 호수 등)"/>
                        </div>
                        <div id="accommodationAddressTag" style="display:none;">
	                        <div class="row g-2">
	                            <div class="col-md-10">
	                                <input type="text" class="form-control" name="accommodation.addr1" id="accommodationAddress" placeholder="숙소 주소를 검색하세요" required readonly>
	                            </div>
	                            <div class="col-md-2">
	                                <button type="button" class="btn btn-outline w-100" id="searchAccBtn" onclick="searchAddress()">
	                                    <i class="bi bi-search"></i> 검색
	                                </button>
	                            </div>
	                        </div>
	                        <input type="text" class="form-control mt-2" name="accommodation.addr2" placeholder="상세주소 (건물명, 층, 호수 등)"/>
                        </div>
						<!-- 지도 -->
                        <div class="mb-3" id="mapSection" style="display: none;">
						    <label class="form-label"></label>
						    <div id="registerMap" style="width: 100%; height: 250px; border-radius:12px; border: 1px solid #ddd;"></div>
						</div>

					    <!-- 숙박용 -->
                        <input type="hidden" name="accommodation.mapy" id="productLatitude"/>
                        <input type="hidden" name="accommodation.mapx" id="productLongitude"/>
                        <input type="hidden" name="accommodation.apiContentId"/>
                        <input type="hidden" name="accommodation.zip"/>
                        
                        <input type="hidden" name="accommodation.areaCode"/>
                        <input type="hidden" name="accommodation.sigunguCode"/>
                        <input type="hidden" name="accommodation.ldongRegnCd"/>
                        <input type="hidden" name="accommodation.ldongSignguCd"/>
                    </div>
                    
                    <!-- 상품인지 숙박인지에 따라 readOnly가 바뀜 -->
                    <div class="mb-3" id="descriptionField">
                        <label class="form-label" id="prodContent">상품 설명 <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="tripProdContent" rows="4" placeholder="상품에 대한 상세 설명을 입력하세요"></textarea>
                        <textarea class="form-control" name="accommodation.overview" rows="4" placeholder="숙소에 대한 상세 설명을 입력하세요" style="display: none"></textarea>
                    </div>
					
                    <!-- 이용 안내 섹션 (기본 상품용) -->
                    <div id="defaultInfoSection">
	                    <div class="form-section-title">
	                        <i class="bi bi-info-circle me-2"></i>이용 안내
	                    </div>
	                    <div class="row mb-3">
	                        <div class="col-md-4">
	                            <label class="form-label">운영 시간 <span class="text-danger">*</span></label>
	                            <input type="text" class="form-control" name="prodInfo.prodRuntime" placeholder="예: 09:00 ~ 18:00" required>
	                        </div>
	                        <div class="col-md-4">
	                            <label class="form-label">소요 시간 <span class="text-danger">*</span></label>
	                            <input type="text" class="form-control" name="prodInfo.prodDuration" placeholder="예: 약 2시간 (실제 체험 40분)" required>
	                            <div class="form-text">고객에게 보여질 상세 소요시간을 입력하세요</div>
	                        </div>
	                        <div class="col-md-4">
	                            <label class="form-label">연령 제한</label>
	                            <input type="text" class="form-control" name="prodInfo.prodLimAge" placeholder="예: 만 10세 이상">
	                        </div>
	                    </div>
	                    <div class="row mb-3">
	                        <div class="col-md-4">
	                            <label class="form-label">최소 인원</label>
	                            <input type="number" class="form-control" name="prodInfo.prodMinPeople" placeholder="1" min="1" value="1" required/>
	                        </div>
	                        <div class="col-md-4">
	                            <label class="form-label">최대 인원</label>
	                            <input type="number" class="form-control" name="prodInfo.prodMaxPeople" placeholder="10" min="1" max="15" required/>
	                        </div>
	                    </div>
	
	                    <!-- 예약 가능 시간 설정 -->
	                    <div class="mb-3">
	                        <label class="form-label">예약 가능 시간 <span class="text-danger">*</span></label>
	                        <div class="form-text mb-2">고객이 선택할 수 있는 예약 시간대를 설정하세요</div>
	                        <div class="booking-times-container" id="bookingTimesContainer">
	                            <div class="booking-time-list" id="bookingTimeList">
	                                <!-- 동적으로 시간 슬롯 추가 -->
	                            </div>
	                            <div class="booking-time-add">
	                                <div class="input-group">
	                                    <input type="time" class="form-control" id="newBookingTime"/>
	                                    <button type="button" class="btn btn-outline" onclick="addBookingTime()">
	                                        <i class="bi bi-plus-lg"></i> 시간 추가
	                                    </button>
	                                </div>
	                            </div>
	                            <div class="booking-time-presets mt-2">
	                                <span class="text-muted small me-2">빠른 추가:</span>
	                                <button type="button" class="btn btn-sm btn-outline-secondary" onclick="addPresetTimes('morning')">오전 타임</button>
	                                <button type="button" class="btn btn-sm btn-outline-secondary" onclick="addPresetTimes('afternoon')">오후 타임</button>
	                                <button type="button" class="btn btn-sm btn-outline-secondary" onclick="addPresetTimes('hourly')">1시간 단위</button>
	                            </div>
	                        </div>
	                        <input type="hidden" name="bookingTimes" id="bookingTimesInput"/>	<!-- 시간 정보 저장 -->
	                    </div>
	                    <div class="row mb-3">
	                        <div class="col-md-6">
	                            <label class="form-label">포함 사항</label>
	                            <textarea class="form-control" name="prodInfo.prodInclude" rows="3" placeholder="포함되는 항목을 줄바꿈으로 구분하여 입력하세요&#10;예:&#10;전문 강사 1:1 지도&#10;장비 대여&#10;수중 사진 촬영"></textarea>
	                        </div>
	                        <div class="col-md-6">
	                            <label class="form-label">불포함 사항</label>
	                            <textarea class="form-control" name="prodInfo.prodExclude" rows="3" placeholder="포함되지 않는 항목을 줄바꿈으로 구분하여 입력하세요&#10;예:&#10;픽업/샌딩 서비스&#10;개인 물품"></textarea>
	                        </div>
	                    </div>
	                    <div class="mb-3">
	                        <label class="form-label">유의 사항</label>
	                        <textarea class="form-control" name="prodInfo.prodNotice" rows="3" placeholder="예약 및 이용 시 유의해야 할 사항을 입력하세요"></textarea>
	                    </div>
                    </div><!-- /defaultInfoSection -->


                    <!-- 숙박 전용 필드 여기에 그냥 추가를 하자 너무 김-->
                    <div id="accommodationFields" style="display: none;">
						<input type="hidden" name="accommodation.accNo"/>
                        <div class="form-section-title">
                            <i class="bi bi-building me-2"></i>숙소 정보
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-4">
                                <label class="form-label">숙소 유형 <span class="text-danger">*</span></label>
                                <select class="form-select" name="accommodation.accCatCd">
                                    <option value="">선택하세요</option>
								    <option value="B02010100">호텔</option>
								    <option value="B02010500">리조트</option>
								    <option value="B02010700">펜션</option>
								    <option value="B02010900">홈스테이/도시민박</option>
								    <option value="B02011100">게스트하우스</option>
								    <option value="B02011200">유스호스텔</option>
								    <option value="B02011400">일반민박</option>
								    <option value="B02011600">워케이션</option>
                                </select>
                            </div>
                            <div class="col-md-4 star" style="display : none;">
                                <label class="form-label">등급</label>
                                <select class="form-select" name="accommodation.starGrade">
                                    <option value="">선택하세요</option>
                                    <option value="5">5성급</option>
                                    <option value="4">4성급</option>
                                    <option value="3">3성급</option>
                                    <option value="2">2성급</option>
                                    <option value="1">1성급</option>
                                    <option value="0">무등급</option>
                                </select>
                            </div>
                            <div class="col-md-4">
                            	<!-- 등록시에는 여기 그대로 두고 객실 늘어나는 만큼, 그 안에서 설정하는 만큼 계산해서 넣어주기 -->
                                <label class="form-label">총 객실 수</label>
                                <input type="number" class="form-control" name="accommodation.totalRoomCnt" placeholder="1" min="1" required/>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">체크인 시간 <span class="text-danger">*</span></label>
                                <input type="time" class="form-control" name="accommodation.checkInTime" required/>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">체크아웃 시간 <span class="text-danger">*</span></label>
                                <input type="time" class="form-control" name="accommodation.checkOutTime" required/>
                            </div>
                        </div>

                        <div class="form-section-title">
                            <i class="bi bi-door-open me-2"></i>객실 정보
                        </div>
                        <div class="room-type-container" id="roomTypeContainer">
                        	<!-- 객실 정보 출력 -->
                        </div>
                        <button type="button" class="btn btn-outline w-100 mb-3" onclick="addRoomType()">
                            <i class="bi bi-plus-lg me-2"></i>객실 타입 추가
                        </button>

                        <div class="form-section-title">
                            <i class="bi bi-stars me-2"></i>편의시설 및 서비스
                        </div>
                        <div class="mb-3">
                            <label class="form-label">숙소 편의시설</label>
                            <div class="amenities-grid">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="accommodation.accFacility.wifiYn" value="Y" id="amenityWifi">
                                    <label class="form-check-label" for="amenityWifi"><i class="bi bi-wifi me-1"></i>무료 WiFi</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="accommodation.accFacility.parkingYn" value="Y" id="amenityParking">
                                    <label class="form-check-label" for="amenityParking"><i class="bi bi-p-circle me-1"></i>주차장</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="accommodation.accFacility.breakfastYn" value="Y" id="amenityBreakfast">
                                    <label class="form-check-label" for="amenityBreakfast"><i class="bi bi-cup-hot me-1"></i>조식</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="accommodation.accFacility.poolYn" value="Y" id="amenityPool">
                                    <label class="form-check-label" for="amenityPool"><i class="bi bi-water me-1"></i>수영장</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="accommodation.accFacility.gymYn" value="Y" id="amenityFitness">
                                    <label class="form-check-label" for="amenityFitness"><i class="bi bi-heart-pulse me-1"></i>피트니스</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="accommodation.accFacility.spaYn" value="Y" id="amenitySpa">
                                    <label class="form-check-label" for="amenitySpa"><i class="bi bi-droplet me-1"></i>스파/사우나</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="accommodation.accFacility.restaurantYn" value="Y" id="amenityRestaurant">
                                    <label class="form-check-label" for="amenityRestaurant"><i class="bi bi-shop me-1"></i>레스토랑</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="accommodation.accFacility.barYn" value="Y" id="amenityBar">
                                    <label class="form-check-label" for="amenityBar"><i class="bi bi-cup-straw me-1"></i>바/라운지</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="accommodation.accFacility.roomServiceYn" value="Y" id="amenityRoomService">
                                    <label class="form-check-label" for="amenityRoomService"><i class="bi bi-bell me-1"></i>룸서비스</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="accommodation.accFacility.laundryYn" value="Y" id="amenityLaundry">
                                    <label class="form-check-label" for="amenityLaundry"><i class="bi bi-basket me-1"></i>세탁 서비스</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="accommodation.accFacility.smokingAreaYn" value="Y" id="amenitySmoking">
                                    <label class="form-check-label" for="amenitySmoking"><i class="bi bi-cloud me-1"></i>흡연구역</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="accommodation.accFacility.petFriendlyYn" value="Y" id="amenityPet">
                                    <label class="form-check-label" for="amenityPet"><i class="bi bi-emoji-heart-eyes me-1"></i>반려동물 동반</label>
                                </div>
                            </div>
                        </div>

                        <div class="form-section-title">
                            <i class="bi bi-plus-circle me-2"></i>추가 옵션 (선택사항)
                        </div>
                        <div class="addon-options-container" id="addOptionsContainer">
                            <!-- 추가옵션 -->
                        </div>
                        <button type="button" class="btn btn-outline w-100 mb-3" onclick="addOption()">
                            <i class="bi bi-plus-lg me-2"></i>추가 옵션 추가
                        </button>
                    </div>

                    <!-- 가격 정보 섹션 (기본 상품용) -->
                    <div id="defaultPriceSection">
	                    <div class="form-section-title">
	                        <i class="bi bi-currency-dollar me-2"></i>가격 및 재고 정보
	                    </div>
	                    <div class="row mb-3">
	                        <div class="col-md-3">
	                            <label class="form-label">정가 <span class="text-danger">*</span></label>
	                            <input type="number" class="form-control" name="prodSale.netprc" placeholder="0">
	                        </div>
	                        <div class="col-md-3">
	                            <label class="form-label">판매가</label>
	                            <input type="number" class="form-control" name="prodSale.price" placeholder="0" readonly required>
	                        </div>
	                        <div class="col-md-3">
	                            <label class="form-label">할인율</label>
	                            <div class="input-group">
	                                <input type="number" class="form-control" name="prodSale.discount" placeholder="0" max="100">
	                                <span class="input-group-text">%</span>
	                            </div>
	                        </div>
	                        <div class="col-md-3">
<!-- 	                        prodSale.price -->
	                        <!-- 전체? 현재? -->
	                            <label class="form-label">재고 수량 <span class="text-danger">*</span></label>
	                            <div class="input-group">
	                                <input type="number" class="form-control" name="prodSale.totalStock" placeholder="0" min="1" required>
	                                <span class="input-group-text">개</span>
	                            </div>
	                        </div>
	                        <div class="col-md-3 curStock" style="display:none;">
	                            <label class="form-label">현재 수량 <span class="text-danger">*</span></label>
	                            <div class="input-group">
	                                <input type="number" class="form-control" name="prodSale.curStock" placeholder="0" min="0" readonly required>
	                                <span class="input-group-text">개</span>
	                            </div>
	                        </div>
	                    </div>
                    </div><!-- /defaultPriceSection -->
                    
                    <!-- 공통파트 -->
                    <div id="commonSaleSection">
					    <div class="form-section-title">
					        <i class="bi bi-calendar-check me-2"></i>판매 기간 및 이미지
					    </div>
					    <div class="row mb-3">
					        <div class="col-md-6">
					            <label class="form-label">판매 시작일 <span class="text-danger">*</span></label>
					            <input type="text" class="form-control date-picker" name="saleStartDt" placeholder="시작일 선택" required>
					        </div>
					        <div class="col-md-6">
					            <label class="form-label">판매 종료일 <span class="text-danger">*</span></label>
					            <input type="text" class="form-control date-picker" name="saleEndDt" placeholder="종료일 선택" required>
					        </div>
					    </div>
                        
					    <div class="mb-3">
					    	<!-- 명칭 변경 ㄱㄱ -->
					        <label class="form-label">상품 이미지 <span class="text-danger">*</span></label>
					        <input type="file" class="form-control" name="mainImage" accept="image/*" onchange="renderImageList(this)" multiple />
					        <div class="form-text">권장 크기: 800x600px, 최대 5MB</div>
					        <div id="mainImagePreview" class="mt-2"></div>
					    </div>
                        <input type="hidden" name="attachNo" />
                        <div class="productImageList"></div>
				        <input type="hidden" class="form-control" name="accommodation.accFilePath"/>
				        <input type="hidden" name="accommodation.accFileNo"/>
<!-- 					mainImagePreview -->
					    <div id="accommodationAdditionalImages" style="display: none;">
					        <label class="form-label">숙소 대표이미지</label>
					        <div class="productImageList mt-2"></div>
					        
<!-- 					        <label class="form-label">숙소 이미지</label> -->
					        <div id="subImagesPreview" class="productImageList mt-2"></div>
					    </div>
					</div>
                    <!-- accFlieNo가 파일 번호 -> 이걸로 fileList만들어서 가져오기 -->
                    <!-- accFilePath가 파일 경로 -->
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary" id="register" onclick="saveProduct(this)">등록</button>
                <button type="button" class="btn btn-primary" id="update" onclick="saveProduct(this)" style="display: none;">수정</button>
            </div>
        </div>
    </div>
</div>

<!--  상품 상세보기 모달 -->
<div class="modal fade" id="productDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header bg-light">
<!--                 <h5>상품 상세 조회</h5> -->
                <h5 class="modal-title" id="productModalTitle">상품 상세 조회</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            
            <div class="modal-body p-0"> <ul class="nav nav-tabs nav-fill" id="productDetailTab" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="info-tab" data-bs-toggle="tab" data-bs-target="#tab-info" type="button" role="tab">기본 정보</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="reservation-tab" data-bs-toggle="tab" data-bs-target="#tab-reservation" type="button" role="tab">예약 현황</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="review-tab" data-bs-toggle="tab" data-bs-target="#tab-review" type="button" role="tab">리뷰 관리</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="qna-tab" data-bs-toggle="tab" data-bs-target="#tab-qna" type="button" role="tab">문의 내역</button>
                    </li>
                </ul>

                <div class="tab-content p-4" id="productDetailTabContent">
                    <div class="tab-pane fade show active" id="tab-info" role="tabpanel">
                        <div class="row">
                            <div class="col-md-5">
                                <div id="detailImageCarousel" class="carousel slide" data-bs-ride="carousel">
                                    <div class="carousel-inner">
                                        <div class="carousel-item active" id="detailImages">
                                        	<!-- 사진 출력란 -->
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-7">
                                <h3 id="view-title" class="fw-bold mb-3">상품명</h3>
                               	<div class="mb-2">
								    <span class="badge px-3 py-2" id="view-category" style="background-color: #10b981;">카테고리</span>
								    <span class="ms-2 text-muted"><i class="bi bi-geo-alt-fill"></i> <span id="view-area">위치 정보</span></span>
								</div>
                                <hr/>
                                <div class="row g-3">
                                    <div class="col-6"><strong>정가:</strong> <span id="view-netprc">0</span>원</div>
                                    <div class="col-6"><strong>판매가:</strong> <span id="view-price" class="text-danger fw-bold">0</span>원</div>
                                    <div class="col-6"><strong>현재 재고:</strong> <span id="view-curStock">0</span>개</div>
                                    <div class="col-6"><strong>판매 기간:</strong> <span id="view-date">yyyy.mm.dd ~ yyyy.mm.dd</span></div>
                                    <!-- view-address -->
                                    <div class="col-6"><strong></strong> <span id="view-address"></span></div>
                                </div>
                                <div class="mt-4 p-3 bg-light rounded">
                                    <h6><strong>상품 설명</strong></h6>
                                    <p id="view-content" class="mb-0 text-secondary" style="white-space: pre-line;">설명 내용이 들어갑니다.</p>
                                </div>
                            </div>
                            <!-- 숙소 옵션 나타내기 -->
                            <div class="acc-section mt-4" id="facility" style="display: none">
                            	<h3>편의시설</h3>
                    			<div class="amenities-list">
		                            <div class="amenity-item">
			                            <i class="bi bi-wifi"></i>
			                            <span>무료 WiFi</span>
			                        </div>
		                            <div class="amenity-item">
			                            <i class="bi bi-p-circle"></i>
			                            <span>무료 주차</span>
			                        </div>
			                        <div class="amenity-item">
			                            <i class="bi bi-water"></i>
			                            <span>수영장</span>
			                        </div>
			                        <div class="amenity-item">
			                            <i class="bi bi-heart-pulse"></i>
			                            <span>피트니스</span>
			                        </div>
		                            <div class="amenity-item">
			                            <i class="bi bi-droplet"></i>
			                            <span>스파/사우나</span>
			                        </div>
			                        <div class="amenity-item">
			                            <i class="bi bi-cup-hot"></i>
			                            <span>조식 제공</span>
			                        </div>
			                        <div class="amenity-item">
			                            <i class="bi bi-shop"></i>
			                            <span>레스토랑</span>
			                        </div>
			                        <div class="amenity-item">
			                            <i class="bi bi-cup-straw"></i>
			                            <span>바/라운지</span>
			                        </div>
			                        <div class="amenity-item">
			                            <i class="bi bi-bell"></i>
			                            <span>룸서비스</span>
			                        </div>
			                        <div class="amenity-item">
			                            <i class="bi bi-basket"></i>
			                            <span>세탁 서비스</span>
			                        </div>
			                        <div class="amenity-item">
			                            <i class="bi bi-basket"></i>
			                            <span>지정 흡연구역</span>
			                        </div>
			                        <div class="amenity-item">
			                            <i class="bi bi-basket"></i>
			                            <span>반려동물 입실 가능</span>
			                        </div>
			                	</div>
	                        </div>
                        </div>
                    </div>
					<!-- 예약정보 -->
                    <div class="tab-pane fade" id="tab-reservation" role="tabpanel">
                        <div class="table-responsive" id="accReserve" style="display: none;">
                            <table class="table table-hover align-middle">
                                <thead class="table-light sticky-top" style="top: -1px; z-index: 10;">
                                    <tr>
                                        <th>예약번호</th>
                                        <th>예약자</th>
                                        <th>예약일자</th>
                                        <th>인원/객실</th>
                                        <th>상태</th>
                                        <th>결제금액</th>
                                    </tr>
                                </thead>
                                <tbody id="view-reservation-list">
                                	<!-- 예약 내역 출력 란 -->
                                </tbody>
                            </table>
                        </div>
                        <!-- 상품 예약 정보 -->
                        <div class="table-responsive" id="prodReserve" style="display: none;">
                            <table class="table table-hover align-middle">
                                <thead class="table-light sticky-top" style="top: -1px; z-index: 10;">
                                    <tr>
                                        <th>예약번호</th>
                                        <th>예약자</th>
                                        <th>예약일자</th>
                                        <th>인원</th>
                                        <th>상태</th>
                                        <th>결제금액</th>
                                    </tr>
                                </thead>
                                <tbody id="view-prodReservation-list">
                                	<!-- 예약 내역 출력 란 -->
                                </tbody>
                            </table>
                        </div>
                    </div>
					
					<!-- 리뷰내역 -->
                    <div class="tab-pane fade" id="tab-review" role="tabpanel">
                        <div id="view-review-list">
                        	<!-- 출력란 -->
                        </div>
                    </div>

					<!-- 문의 내역 -->
                    <div class="tab-pane fade" id="tab-qna" role="tabpanel">
                        <div class="list-group list-group-flush" id="view-qna-list">
	                          <!--  출력란 -->
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="modal-footer bg-light">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<!-- 검색중 보여줄 것 -->
<div id="loading-overlay" style="display: none;">
    <div class="spinner"></div>
    <p>숙소 정보를 불러오고 있습니다...</p>
</div>

<c:set var="hasInlineScript" value="true" />
<!-- 카카오맵 -->
<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=0a4b8e6c128016aa0df7300b3ab799f1&libraries=services&autoload=false"></script>
<!-- 다음 주소 검색 -->
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<!-- <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=9976009a2fb2e0385884b79eca12dd63&libraries=services,clusterer"></script> -->

<%@ include file="../common/footer.jsp" %>

<script>
let modal = null;			// 모달 객체
let detailModal = null; 
let bookingTimes = [];		// 예약 가능 시간 목록
let imageList = [];			// 이미지 정보 목록

let timeListContainer;		// 예약가능시간 출력란
let imageContainer;			// 사진출력란
let roomTypeContainer;		// 숙소 타입 출력란
let addOptionsContainer; 	// 추가 옵션 출력란
let category;				// 카테고리
let citySelector;			// 도시 선택
let accommodationAddress;	// 숙소의 addr1

let startDatePicker;
let endDatePicker;

// 지도
let regMap = null;    // 등록/수정 모달용 지도 객체
let regMarker = null; // 모달 지도 마커
let geocoder; // 주소 변환기 (전역 1개만 생성)
let mapSection = null;	// 지도
let searchAccBtn = null;
let accImage;
document.addEventListener('DOMContentLoaded', function() {
	const modalElem = document.getElementById('productModal');
	const detailModalElem = document.getElementById('productDetailModal');
	
    if (modalElem) modal = new bootstrap.Modal(modalElem);
    if (detailModalElem) detailModal = new bootstrap.Modal(detailModalElem);
	
    
    // 컨테이너 지정
	timeListContainer = document.getElementById('bookingTimeList');
	imageContainer = document.querySelector(".productImageList");
	roomTypeContainer = document.getElementById('roomTypeContainer');
	addOptionsContainer = document.getElementById('addOptionsContainer');
	// 지도 api용 객체
	kakao.maps.load(function() {
        geocoder = new kakao.maps.services.Geocoder();
        mapSection = document.getElementById('mapSection');	// 지도
	});
	
	accommodationAddress = document.getElementById('accommodationAddress');	// 숙소 api의 주소 담기 위한 것
	searchAccBtn = document.getElementById('searchAccBtn');					// 검색 버튼
	
	category = document.getElementById('productCategory');		// 카테고리
	citySelector = document.querySelector("[name='ctyNm']");	// 도시 설정
	
	const startDateInput = document.querySelector('input[name="startDate"]');
	const endDateInput = document.querySelector('input[name="endDate"]');
	
	// endDate는 그걸로
	if (startDateInput && typeof flatpickr !== 'undefined') {
	    startDatePicker = flatpickr(startDateInput, {
	        locale: 'ko',
	        dateFormat: 'Y-m-d',
	        minDate: 'today',
	        disableMobile: true,
	        onChange: function(selectedDates) {
	            if (selectedDates.length > 0 && endDatePicker) endDatePicker.set('minDate', selectedDates[0]);
	        }
	    });
	}
	
	if (endDateInput && typeof flatpickr !== 'undefined') {
	    endDatePicker = flatpickr(endDateInput, {
	        locale: 'ko',
	        dateFormat: 'Y-m-d',
	        minDate: 'today',
	        disableMobile: true
	    });
	}
	
	// 초기화
    updateSelectedCount();
});

// 새 상품 등록 모달 설정
function setModalForNew() {
    document.getElementById('productModalTitle').textContent = '새 상품 등록';
	document.querySelector("#register").style.display = "block";
	document.querySelector("#update").style.display = "none";
	
    document.getElementById('productForm').reset();
    
	// 카테고리, 도시선택 selector 초기화
	category.disabled = false;
	citySelector.disabled = false;
	searchAccBtn.disabled = false;	// 검색 버튼 초기화
	
	mapSection.style.display = "none";
	
    if (startDatePicker) startDatePicker.clear();
    if (endDatePicker) {
        endDatePicker.clear();
        endDatePicker.set('minDate', 'today');
    }
    
    // 컨테이너 초기화
	timeListContainer.innerHTML = ``;
	imageContainer.innerHTML = ``;
	roomTypeContainer.innerHTML = ``;
	addOptionsContainer.innerHTML = ``;
	
	// 보여주기
    addRoomType();
    addOption();
    
    // 예약 시간 초기화
    bookingTimes = [];
    renderBookingTimes();
    // 카테고리 필드 초기화
    toggleCategoryFields();
    // 객실 타입, 추가 옵션 인덱스 초기화
    roomTypeIndex = 1;
    addonOptionIndex = 1;
}

// 상품정보 자동 완성
function fillProductInfo(){
	const productData = {
	        'prodCtgryType': 'activity',              // 카테고리: 액티비티
	        'ctyNm': '39',                           // 도시코드
	        'prodSale.leadTime': '3',                // 소요시간(Lead Time)
	        'tripProdTitle': '제주 푸른 바다 투명 카약 체험', 
	        'prodPlace.addr1': '제주특별자치도 제주시 애월읍 애월로 1길', 
	        'prodPlace.addr2': '월정리카약체험장', 
	        'tripProdContent': '에메랄드빛 애월 바다에서 즐기는 힐링 카약 체험입니다. 가족, 연인과 함께하세요!',
	        'prodInfo.prodRuntime': '09:00 ~ 18:00',
	        'prodInfo.prodDuration': '1시간 30분',
	        'prodInfo.prodLimAge': '만 7세 이상',
	        'prodInfo.prodMinPeople': '1',
	        'prodInfo.prodMaxPeople': '4',
	        'prodInfo.prodInclude': '카약 장비 대여\n구명조끼\n안전 요원 가이드',
	        'prodInfo.prodExclude': '개인 수건\n주차비\n기타 음료',
	        'prodInfo.prodNotice': '기상 악화 시 안전을 위해 이용이 제한될 수 있습니다.',
	        'prodSale.netprc': '30000',               // 정가
	        'prodSale.discount': '10',                // 할인율 (10%)
	        'prodSale.totalStock': '50',
	        'saleStartDt': '2026-02-01',
	        'saleEndDt': '2026-05-01'
	    };

	    // 2. 루프를 돌며 데이터 입력
	    for (const [name, value] of Object.entries(productData)) {
	        const element = document.querySelector(`[name="\${name}"]`);
	        if (element) {
	            element.value = value;
	            // 만약 입력을 감지해야 하는 라이브러리를 쓴다면 이벤트 강제 발생
	            element.dispatchEvent(new Event('input', { bubbles: true }));
	        }
	    }
	    // 시간 추가
	    addPresetTimes('hourly');

	    // 3. 할인율에 따른 판매가(price) 자동 계산 로직
	    const netprc = parseInt(productData['prodSale.netprc']);
	    const discount = parseInt(productData['prodSale.discount']);
	    const salePrice = netprc * (1 - discount / 100);
	    
	    const priceElement = document.querySelector(`[name="prodSale.price"]`);
	    if (priceElement) {
	        priceElement.value = Math.floor(salePrice); // 소수점 버림
	    }
}

// 상품 수정 모달 설정
async function editProduct(data) {
	const { id, no } = data.dataset;	// tripProdNo랑 accNo
	console.log("editProduct : id, no" +  id  + " " + no);
	
	console.log("curStock : ", document.querySelector(".curStock"));
	category.disabled = false;
	citySelector.disabled = false;

	// 초기화 용
    const form = document.getElementById('productForm');
	form.reset();
	
	timeListContainer.innerHTML = ``;
	imageContainer.innerHTML = ``;
	roomTypeContainer.innerHTML = ``;
	addOptionsContainer.innerHTML = ``;
	document.querySelector("#mainImagePreview").innerHTML = ``;    
	
	bookingTimes = [];
	imageList = [];
	
	try {
		const requestData = {tripProdNo: id}; 
		if (no != 0)  requestData.accNo = no;
		
        const response = await axios.post(`/product/manage/productDetail`, requestData);
        const data = response.data;
        // 미리 세팅
        category.value = data.prodCtgryType;
		toggleCategoryFields();
        
		
		// 숙박 타입일때 그만큼 방 만들기
		if (data.prodCtgryType === 'accommodation' && data.accommodation) {
	        const acc = data.accommodation;
	        
	        if(acc.accFilePath){
	        	accImage = `<img src="\${acc.accFilePath}" alt="숙소 대표 이미지" 
		        	style="width:300px; height:200px; object-fit:cover;"/>`;
		    	document.querySelector("#mainImagePreview").innerHTML = accImage;    
	        }
	        
	        // 룸 타입 화면 랜더잉
// 	        if (acc.roomTypeList) {
// 	            acc.roomTypeList = acc.roomTypeList.filter(room => room && room.roomTypeNo);
// 	            if(acc.roomTypeList.length > 0){
// 		            acc.roomTypeList.forEach(() => addRoomType());
// 		            renderProductData({ roomTypeList: acc.roomTypeList });
// 	            } else addRoomType();
// 	        } 
// 	        acc.roomTypeList = null;
			
// 	        // 추가옵션 화면 랜더링
// 	        if(acc.accOptionList){
// 	            acc.accOptionList = acc.accOptionList.filter(opt => opt && opt.accOptionNo);
// 	            if(acc.accOptionList.length > 0){
// 		            acc.accOptionList.forEach(() => addOption());
// 		            renderProductData({ accOptionList: acc.accOptionList });
// 	            } else addOption();
// 	        }
// 	        acc.accOptionList = null;
	        
// 	        renderProductData(acc, "accommodation");
// 	        data.accommodation = null; 
	        
	        // 객실 옵션, 특징
	        if (acc.roomTypeList && acc.roomTypeList.length > 0) {
	        	acc.roomTypeList = acc.roomTypeList.filter(room => room && room.roomTypeNo);
	            acc.roomTypeList.forEach(room => {
	                // [중요] 이름 맞춰주기: VO의 roomFacility를 HTML의 facility로 복사
	                room.facility = room.roomFacility; 
	                room.feature = room.roomFeature;
	                addRoomType(); 
	            });
	        }

	        // 추가 옵션
	        if (acc.accOptionList && acc.accOptionList.length > 0) {
	        	acc.accOptionList = acc.accOptionList.filter(opt => opt && opt.accOptionNo);
	            acc.accOptionList.forEach(() => addOption());
	        }

	        // 2. 이제 한 번에 뿌리기 (prefix만 붙여서!)
	        // 이 한 줄이 실행될 때, 위에서 가공한 facility/feature 이름 덕분에 값이 쏙쏙 들어갑니다.
	        renderProductData(acc, "accommodation");
	        
	    }
		
// 		// 시간 담기
        if(data.prodTimeList && data.prodTimeList.length > 0){
        	bookingTimes = data.prodTimeList.map(time => time.rsvtAvailableTime);
        	renderBookingTimes();
        	data.prodTimeList = null;
        }
		
		// 사진 담기 - 같다. 
        if(data.imageList && data.imageList.length > 0 ){
        	imageList = [...data.imageList];	// 여기서 꺼내서 쓰자
        	console.log("imageList : ", imageList);
        	renderImageList();
        	data.imageList = null;
        }
        
		renderProductData(data);	// 상품 불러오기
		
        document.getElementById('productModalTitle').textContent = '상품 수정';
		document.querySelector("#update").style.display = "block";
		document.querySelector("#register").style.display = "none";
        
		// 주소나 좌표 존재시 지도 미리 띄워주기
		const lat = document.getElementById('productLatitude').value;
		const lng = document.getElementById('productLongitude').value;

		if (lat && lng) {
		    if (mapSection) mapSection.style.display = 'block';
		    
		    const coords = new kakao.maps.LatLng(lat, lng);
		    updateModalMap(coords);
		    // 좌표가 없으면 지도 섹션을 숨김
		} else document.getElementById('mapSection').style.display = 'none';
		
		// 숙소 상품의 경우 검색 불가
		if (data.prodCtgryType === 'accommodation') {
		    // 숙박 상품 수정 시 주소 검색 버튼 비활성화
		    if (searchAccBtn) {
		        searchAccBtn.disabled = true; // 버튼 비활성화
		        searchAccBtn.title = "숙소 위치는 변경할 수 없습니다. 상세 주소만 수정하세요.";
		    }
		    accommodationAddress.readOnly = true;
		    citySelector.disabled = true;
		    category.disabled = true;
		}
		
		// 방 수만큼 넣어야됨
		modal.show()
    } catch (error) {
        console.error("데이터 로드 중 error 발생: ", error);
    }
}

// 상세보기용 모달
async function showDetail (data){
	const { id, no } = data.dataset;	// tripProdNo랑 accNo
	console.log("showDetail : id, no" +  id  + " " + no);
	const sendData = {tripProdNo : id};
	
	const facility = document.getElementById('facility');		// 숙소 보유시설
	const accReserve = document.getElementById('accReserve');	// 숙소 예약내역
	const prodReserve = document.getElementById('prodReserve');	// 상품 예약 내역
	
	facility.style.display = "none";
	accReserve.style.display = "none";
	prodReserve.style.display = "none";
	
	
	let netprc = document.getElementById('view-netprc');					// 정가
	let price = document.getElementById('view-price');						// 할인 가격	
	let curStock = document.getElementById('view-curStock');				// 현재 재고
	let saleDate = document.getElementById('view-date');					// 판매기간 2개 더하기
	let content = document.getElementById('view-content');					// overview나 tripProdContent
	
	let prodTitle = document.getElementById('view-title');					// 상품명
	let prodCategory = document.getElementById('view-category');			// 카테고리
	let areaCode = document.getElementById('view-area');					// 지역 코드
	let prodAddr = document.getElementById('view-address');					// 주소

	// 출력란
	let reservationList = document.getElementById('view-reservation-list');	// 예약 목록 출력 란
	let prodReservationList = document.getElementById('view-prodReservation-list');	// 예약 목록 출력 란
	let detailImagesContainner = document.getElementById('detailImages');			// 사진 출력란
	let reviewContainerList = document.getElementById('view-review-list');			// 리뷰 목록
	let inquiryContainerList  = document.getElementById('view-qna-list');			// 문의사항 목록
	
	// 출력란 초기화
	reservationList.innerHTML = ``;
	prodReservationList.innerHTML = ``;
	detailImagesContainner.innerHTML = ``;
	reviewContainerList.innerHTML = ``;
	inquiryContainerList.innerHTML = ``;
	
	// 숙박
	if(no != null) sendData.accNo = no;
	
	// axios 설정
	try{
		const res = await axios.post(`/product/manage/productDetail`, sendData);
// 		console.log("res.data : ", res.data);
		
		// 공통 정보
		let selectCategory = res.data.prodCtgryType;
		switch(selectCategory){
			case 'accommodation' : 
				selectCategory = "숙박";
				break;
			case 'activity' : 
				selectCategory = "액티비티";
				break;
			case 'tour' : 
				selectCategory = "투어";
				break;
			case 'ticket' : 
				selectCategory = "입장권/티켓";
				break;
			case 'class' : 
				selectCategory = "클래스/체험";
				break;
			default :
				selectCategory = "교통/이동";
				break;
		}
		prodCategory.innerHTML = selectCategory;	// 상품 카테고리
		
		areaCode.innerHTML = res.data.ctyNm != null ? setArea(res.data.ctyNm) : "서울";	// 지역
		
		let reserveHtml = ``;	// 출력용 변수
		
		let tripProdNo = res.data.tripProdNo;
		console.log("tripProdNo : ", tripProdNo);
		
		// 숙박
		if(res.data.accommodation && selectCategory === "숙박"){
// 			console.log("res.data.accommodation : ", res.data.accommodation);
			const accommodation = res.data.accommodation;
			
			facility.style.display = "block";
			accReserve.style.display = "block";
			prodReserve.style.display = "none";

			prodTitle.innerHTML = accommodation.accName;	// 상품명
			content.innerHTML = 
				accommodation.overview == null ? 
						res.data.tripProdContent : accommodation.overview;		// 상품 내용

			let photo = `<img src="\${accommodation.accFilePath}" class="d-block w-100 rounded" alt="상품이미지">`;
			detailImagesContainner.innerHTML = photo;

			saleDate.innerHTML = setTime(res.data.saleStartDt) + " ~ " + setTime(res.data.saleEndDt);	// 판매 기간
// 			console.log("accommodation.roomTypeList : ", accommodation.roomTypeList);

			// 예약 목록 출력 위한 것
			let reservationRoomList = accommodation.roomTypeList;

			const cheapestRoom = reservationRoomList.reduce((prev, curr) => {
			    // 가격이 0보다 큰 것 중에서 더 작은 값을 가진 객체를 반환
			    return (prev.price > 0 && prev.price < curr.price) ? prev : curr;
			});

			// 2. 해당 객체에서 필요한 값 추출
			const minPrice = cheapestRoom.price;  			// 최저 판매가
			const matchingDiscount = cheapestRoom.discount; // 그 최저가 방의 원래 정가
			
			netprc.innerHTML = minPrice.toLocaleString();
			price.innerHTML = (matchingDiscount == 0 )? minPrice.toLocaleString() 
					: (minPrice - parseInt(minPrice * (matchingDiscount / 100))).toLocaleString();
					
			curStock.innerHTML = accommodation.totalRoomCnt == null ? 50 : parseInt(accommodation.totalRoomCnt);
				// 원래 여기서 그거 해야됨
			
			reservationRoomList.forEach((room, roomIndex) => {
// 				console.log("room.예약 : ", room);
				let roomName = room.roomName;	// 객실 명
				
				// 객실 가격 필터링 해야됨
				room.accResvList.forEach((acc, index) => {
					
					let uniqueId = `resv_\${acc.accResvNo}_\${roomIndex}_\${index}`;
					let startDt = acc.startDt != null ? setTime(acc.startDt) : "2026-01-27";
					let endDt = acc.endDt != null ? setTime(acc.endDt) : "2026-05-10"; 
					let personCount = acc.adultCnt + acc.childCnt + acc.infantCnt;

					let telForm = acc.tel != null ? formatTel(acc.tel) : "010-1234-1234";
					// 예약 내역 없을떄
					if(acc.accResvNo === 0) reserveHtml = ``;
					
					else{
						let statusBadge = "";
						switch(acc.resvStatus) {
						    case '결제완료': case '완료':
						        // 등록 모달 상단의 그린 포인트와 일치
						        statusBadge = "badge-moheng-success"; 
						        break;
						    case '예약대기': case '대기':
						        statusBadge = "bg-warning-subtle text-warning-emphasis border border-warning-subtle";
						        break;
						    default:
						        statusBadge = "bg-light text-secondary border";
						        break;
						}

						// 2. HTML 구조 생성 (파란색 제거 및 등록 모달 스타일 이식)
						reserveHtml += `
							<tr onclick="toggleDetail('\${uniqueId}')" style="cursor:pointer;" class="main-row align-middle border-bottom">
							    <td class="fw-bold resv-no">#\${acc.accResvNo}</td>
							    <td class="fw-medium">\${acc.memName}</td>
							    <td class="small text-muted">\${startDt} ~ \${endDt}</td>
							    <td><span class="fw-bold">\${personCount}명</span> <span class="text-muted mx-1">/</span> <small>\${roomName}</small></td>
							    <td><span class="badge \${statusBadge}">\${acc.resvStatus}</span></td>
							    <td class="fw-bold text-end text-dark">\${(acc.price || 0).toLocaleString()}원</td>
							</tr>
							<tr id="\${uniqueId}" class="detail-row" style="display:none; background-color: #f8fafb;">
							    <td colspan="6" class="p-3">
							        <div class="detail-card">
							            <div class="row g-0">
							                <div class="col-md-6 p-4 border-end" style="border-color: #e2e8f0 !important;">
							                    <div class="view-section-title mb-3">
							                        <i class="bi bi-person-vcard"></i> 예약 상세 정보
							                    </div>
							                    <ul class="list-unstyled mb-0" style="line-height: 2;">
							                        <li class="d-flex justify-content-between border-bottom pb-1 mb-2">
							                            <span class="text-muted small">연락처</span>
							                            <span class="fw-bold">\${telForm}</span>
							                        </li>
							                        <li class="d-flex justify-content-between border-bottom pb-1 mb-2">
							                            <span class="text-muted small">이메일</span>
							                            <span>\${acc.memEmail || '정보 없음'}</span>
							                        </li>
							                        <li class="d-flex justify-content-between border-bottom pb-1 mb-2">
							                            <span class="text-muted small">체크인 예정</span>
							                            <span class="badge bg-white text-dark border fw-normal">\${startDt} 15:00</span>
							                        </li>
							                        <li class="d-flex justify-content-between">
							                            <span class="text-muted small">추가 옵션</span>
							                            <span class="badge bg-white text-dark border fw-normal">없음</span>
							                        </li>
							                    </ul>
							                </div>
							                <div class="col-md-6 p-4 bg-white">
							                    <div class="view-section-title mb-3">
							                        <i class="bi bi-chat-square-dots"></i> 고객 요청사항
							                    </div>
							                    <div class="p-3 rounded border bg-light small text-secondary" style="min-height: 100px; border-style: dashed !important;">
							                        \${acc.resvRequest || '특별한 요청사항이 없습니다.'}
							                    </div>
							                </div>
							            </div>
							        </div>
							    </td>
							</tr>`;
					}
				});
				
			});
			if(reserveHtml === "") {
				reserveHtml += `<tr><td colspan="6" class="no-data">예약 내역이 없습니다.</td></tr>`;
			}
			reservationList.innerHTML = reserveHtml;
			
		}else{
			// 상품
			const prod = res.data;
			
			facility.style.display = "none";
			accReserve.style.display = "none";
			prodReserve.style.display = "block";
			
			prodTitle.innerHTML = prod.tripProdTitle;	// 상품 제목
			content.innerHTML = prod.tripProdContent;	// 상품 내용
			// 상세 주소는 addr
			
			// 출력 사진
			const path = `${pageContext.request.contextPath}/upload\${prod.thumbImage}`;
			let photo = `<img src="\${path}" class="d-block w-100 rounded" alt="상품이미지">`;
			detailImagesContainner.innerHTML = photo;
			
			saleDate.innerHTML = setTime(prod.saleStartDt) + " ~ " + setTime(prod.saleEndDt);	// 판매 기간
			
			let prodResvList = prod.prodList;
			
			prodResvList.forEach((resv, index) => {
					console.log("resv : ", resv);
					
					let resvId = `prod_\${resv.prodListNo}_\${index}`;
					let startDt = resv.resvDt != null ? setTime(resv.resvDt) : "2026-01-27";

					let telForm = resv.tel != null ? formatTel(resv.tel) : "010-1234-1234";
					// 예약 내역 없을떄
					if(resv.prodListNo === 0) reserveHtml = ``;
					
					else {
						let statusBadge = "badge-moheng-success";
						
// 							    <td class="fw-bold resv-no">#\${index + 1}</td>
						// 2. HTML 구조 생성 (파란색 제거 및 등록 모달 스타일 이식) - 예약 최신순으로 정렬
						reserveHtml += `
							<tr onclick="toggleDetail('\${resvId}')" style="cursor:pointer;" class="main-row align-middle border-bottom">
							    <td class="fw-bold resv-no">#\${resv.prodListNo}</td>
							    <td class="fw-medium">\${resv.memName}</td>
							    <td class="small text-muted">\${startDt}</td>
							    <td><span class="fw-bold">\${resv.quantity}명</span></td>
							    <td><span class="badge \${statusBadge}">결제완료</span></td>
							    <td class="fw-bold text-end text-dark">\${(resv.payPrice || 0).toLocaleString()}원</td>
							</tr>
							<tr id="\${resvId}" class="detail-row" style="display:none; background-color: #f8fafb;">
							    <td colspan="6" class="p-3">
							        <div class="detail-card">
							            <div class="row g-0">
							                <div class="col-md-6 p-4 border-end" style="border-color: #e2e8f0 !important;">
							                    <div class="view-section-title mb-3">
							                        <i class="bi bi-person-vcard"></i> 예약 상세 정보
							                    </div>
							                    <ul class="list-unstyled mb-0" style="line-height: 2;">
							                        <li class="d-flex justify-content-between border-bottom pb-1 mb-2">
							                            <span class="text-muted small">연락처</span>
							                            <span class="fw-bold">\${telForm}</span>
							                        </li>
							                        <li class="d-flex justify-content-between border-bottom pb-1 mb-2">
							                            <span class="text-muted small">이메일</span>
							                            <span>\${resv.memEmail || '정보 없음'}</span>
							                        </li>
							                        <li class="d-flex justify-content-between">
							                            <span class="text-muted small">이용시작 시간</span>
							                            <span class="badge bg-white text-dark border fw-normal">\${startDt} \${resv.useTime}</span>
							                        </li>
							                    </ul>
							                </div>
							                <div class="col-md-6 p-4 bg-white">
							                    <div class="view-section-title mb-3">
							                        <i class="bi bi-chat-square-dots"></i> 고객 요청사항
							                    </div>
							                    <div class="p-3 rounded border bg-light small text-secondary" style="min-height: 100px; border-style: dashed !important;">
							                        \${resv.rsvMemo || '특별한 요청사항이 없습니다.'}
							                    </div>
							                </div>
							            </div>
							        </div>
							    </td>
							</tr>`;
					}
				});
			if(reserveHtml === "") {
				reserveHtml += `<tr><td colspan="6" class="no-data">예약 내역이 없습니다.</td></tr>`;
			}
			prodReservationList.innerHTML = reserveHtml;
			
			// 출력
			// prodReservationList
			netprc.innerHTML = prod.prodSale.netprc.toLocaleString();	// 정가
			price.innerHTML =  prod.prodSale.price.toLocaleString();	// 할인가
			curStock.innerHTML = prod.prodSale.curStock;				// 현 재고
			
		}
		
		// 리뷰 내역 - 맨위에 리뷰 통계 내역 보여줄지
		const reviewList = res.data.prodReviewList;
		console.log("reviewList : ", reviewList);
		let reviewHtml = ``;
		reviewHtml += `
			<div class="review-list">`;
			
		reviewList.forEach((review) => {
			console.log("review : ", review);
			let reviewDt = review.prodRegdate != null ? setTime(review.prodRegdate) : "2026-01-12"; // 등록 일자	
			// prodUdtdate 수정시 사용할 것
			let prodReview = review.prodReview != null ? review.prodReview : "최고입니다!"; 			// 리뷰 내용
			
			reviewHtml += `
					<div class="review-item">
						<div class="review-item-header">
							<div class="reviewer-info">
			               		<div class="reviewer-avatar">`;
			// 프로필 추가
       		let profile = review.profileImage !== null ? `${pageContext.request.contextPath}/upload\${review.profileImage }` : "";
			
			if(profile !== null && profile !== "") reviewHtml += `<img src="\${profile}" alt="프로필"/>`;
			else reviewHtml += `<i class="bi bi-person"></i>`;
			
			reviewHtml += `
								</div>
								<div>
									<span class="reviewer-name">\${review.nickname}</span> 
					                <span class="review-date">\${reviewDt}</span>
				                </div>
							</div>
							<div class="d-flex align-items-center gap-2">`;
				            	
			// 별 추가
			let star = review.rating !== null ? review.rating : 1;
			reviewHtml += `\${star}
								<div class="review-rating">`;
								
			for(let i = 1; i <= star; i++){
				reviewHtml += `<i class="bi bi-star-fill"></i>`;
			}
			reviewHtml += `
								</div>
							</div>
						</div>
						<div class="review-content"><p>\${prodReview}</p></div>`;

			// 리뷰 사진
			let reviewImages = review.reviewImages !== null ? `${pageContext.request.contextPath}/upload\${review.reviewImages[0]}` : "";
			if(reviewImages !== null && reviewImages !== ""){
				console.log("reviewImages : ", reviewImages);
				reviewHtml += `
						<div class="review-images"><img src="\${reviewImages}" alt="리뷰이미지"/></div>`;
			}
			reviewHtml += `
				</div>`;
		});
		reviewHtml += `</div>`;
		if(reviewList == null || reviewList.length <= 0){
			reviewHtml = `
				<div class="no-review">
	                <i class="bi bi-chat-square-text"></i>
	                <p>아직 리뷰가 없습니다.</p>
	            </div>`;
		}
		
		reviewContainerList.innerHTML = reviewHtml;
		
		
		// 문의 사항 출력
		const inquiryList = res.data.prodInquiryList;
		console.log("inquiryList : ", inquiryList);
		let inquiryHtml = ``;
		inquiryHtml = `
			<div class="inquiry-modal-list" id="inquiryModalList">`;
			
		inquiryList.forEach((inquiry) => {
			
			let author = inquiry.inquiryNickname !== null ? inquiry.inquiryNickname : "길동";
			let inquiryStatus = inquiry.inqryStatus !== null ? (inquiry.inqryStatus === "WAIT" ? "답변대기" : "답변완료") : "답변대기";
			console.log("inquiry.inqryStatus : ", inquiry.inqryStatus);
// 			console.log("inquiryStatus : ", inquiryStatus);
			
			let inquiryCode = inquiryStatus === "답변대기" ?  'waiting' : 'answered';
// 			console.log("inquiryCode : ", inquiryCode);
			
			let showDate = inquiry.regDt !== null ? (inquiry.modDt !== null ? setTime(inquiry.modDt) : setTime(inquiry.regDt)) : "2026-01-23";
			let inquiryContent = inquiry.prodInqryCn !== null ? inquiry.prodInqryCn : "이건 어떻게 해야되나요?";	// 문의 내용
			let inquiryType = setInquiryCategory(inquiry.inquiryCtgry); 										// 문의 카테고리
			let inquiryTypeCode = inquiry.inquiryCtgry !== null ? inquiry.inquiryCtgry : "product";
			
			let statusClass = inquiry.inqryStatus === 'DONE' ? 'is-answered' : 'is-waiting';					// 조회용 ui
// 			console.log("statusClass : ", statusClass );
			
			let replyDt = setTime(inquiry.replyDt);	// 답변 날짜
			
			// 문의사항
			inquiryHtml += `
				<div class="inquiry-modal-item \${statusClass}" data-status="\${inquiryCode}" data-id="\${inquiry.prodInqryNo}">
					<div class="inquiry-modal-header">
                		<div class="inquiry-modal-info">
                			<span class="inquiry-type-badge \${inquiryTypeCode}">\${inquiryType}</span>
                			<span class="inquiry-author">\${author}</span>
                            <span class="inquiry-date">\${showDate}</span>
                        </div>
                        <span class="inquiry-status \${inquiryCode}">\${inquiryStatus}</span>
					</div>
					<div class="inquiry-modal-question">
	                    <p><strong>Q.</strong>\${inquiryContent}</p>
	                </div>
	                <div class="inquiry-modal-reply">
		                <textarea class="form-control reply" placeholder="답변을 입력하세요..." rows="3"></textarea>
	                    <div class="reply-actions">
	                        <button class="btn btn-primary btn-sm" onclick="submitReply(\${inquiry.prodInqryNo}, \${tripProdNo})">
	                            <i class="bi bi-send me-1"></i>답변 등록
	                        </button>
	                    </div>
                    </div>
					<div class="inquiry-modal-answer">
	                    <div class="answer-header">
	                        <span><i class="bi bi-building"></i> 내 답변</span>
	                        <div class="answer-actions">
	                            <span class="answer-date">\${replyDt}</span>
	                            <button type="button" class="btn-edit-answer" onclick="editAnswer(\${inquiry.prodInqryNo}, \${tripProdNo})" title="답변 수정">
	                                <i class="bi bi-pencil"></i>
	                            </button>
	                            <button type="button" class="btn-delete-answer" onclick="deleteAnswer(\${inquiry.prodInqryNo}, \${tripProdNo})" title="답변 삭제">
	                                <i class="bi bi-trash"></i>
	                            </button>
	                        </div>
	                    </div>
	                    <div class="answer-content">
	                        <p><strong>A.</strong> <span class="answer-text">\${inquiry.replyCn}</span></p>
	                    </div>
	                </div>
				</div>`;
		});
		
		if(!inquiryList || inquiryList.length <=  0 ) {
			inquiryHtml += `
				<div class="no-review">
	                <i class="bi bi-chat-square-text"></i>
	                <p>등록된 문의 내역이 없습니다.</p>
	            </div>`;
		}
		inquiryHtml += `</div>`;
		
		inquiryContainerList.innerHTML = inquiryHtml;
		
	}catch(err){
		console.log("에러 원인 : ", err);
		showToast("error 발생 !!", "error");
	}
	detailModal.show();
} 

// 문의내역 용
let answerPart;
let originText;

// 문의사항 답변 등록
function submitReply(inquiryId, tripProdNo, editContent = "") {
	console.log("submitReply - inquiryId : ", inquiryId);
	console.log("submitReply - tripProdNo : ", tripProdNo);
	console.log("submitReply - editContent : ", editContent);
	
	const item = document.querySelector('.inquiry-modal-item[data-id="' + inquiryId + '"]');
	
	const textarea = document.getElementById('editAnswerText-' + inquiryId) ? document.getElementById('editAnswerText-' + inquiryId) : item.querySelector('.reply');
	const printArea = item.querySelector('.answer-content');	// 출력 div태그
	const content = textarea.value.trim();
	
	// 리뷰 완료후 출력할 곳
	const answerDate = item.querySelector('.answer-date');
	if(item.querySelector('.answer-text')) answerPart = item.querySelector('.answer-text');
	else {
		printArea.innerHTML =`<p><strong>A.</strong><span class="answer-text"></span></p>`;
		answerPart = item.querySelector('.answer-text'); 
	}
	console.log("answerPart : ", answerPart);
	
	
	if (!content) {
        showToast('답변 내용을 입력해주세요.', 'warning');
	    return;
	}
	
	if (content.length < 10) {
        showToast('답변은 10자 이상 입력해주세요.', 'warning');
	    return;
	}

	const sendData = {
		prodInqryNo : inquiryId,
		replyCn: content
	}
	
	let isEdit = document.getElementById('editAnswerText-' + inquiryId) ? true : false;
	// 수정 여부에 따라서 주소 바꾸기
	let url = isEdit ? `/tour/\${tripProdNo}/inquiry/reply/update` : `/tour/\${tripProdNo}/inquiry/reply`;
	axios.post(url, sendData)
	.then((response) => {
		const data = response.data;
		console.log("data : ", data);
		if (data.success) {
			if(isEdit) showToast('답변이 수정되었습니다.', 'success');
			else showToast('답변이 등록되었습니다.', 'success')
			
		 	item.classList.remove('is-waiting');
			item.classList.add('is-answered');
			item.dataset.status = 'answered';
			
			const statusBadge = item.querySelector('.inquiry-status');
			statusBadge.className = 'inquiry-status answered';
			statusBadge.textContent = '답변완료';
			
			const today = new Date();
			answerDate.textContent = setTime(today);	// 작성일자
			// 이거는 수정시에는 없는것
			answerPart.textContent = content;			// 작성 내용
			
			// 출력할 모달 영역 - answerArea
			const answerArea = item.querySelector('.inquiry-modal-answer');
			answerArea.classList.remove('editing');
		    const editBtn = answerArea.querySelector('.btn-edit-answer');
		    editBtn.style.display = 'block';
			
		} else {
			showToast(data.message || '등록에 실패했습니다.', 'warning');
		}
	})
	.catch((error) => {
	    console.error("Reply Error:", error);
	    var errorMsg = error.response ? error.response.data.message : "서버 통신 오류";
	    showToast(errorMsg, 'error');
	});
}

// 문의 수정
function editAnswer(inquiryId, tripProdNo){
	console.log("editAnswer inquiryId : ", inquiryId);
	console.log("editAnswer tripProdNo : ", tripProdNo);
	
    const item = document.querySelector('.inquiry-modal-item[data-id="' + inquiryId + '"]');
    const answerArea = item.querySelector('.inquiry-modal-answer');
    const answerContent = answerArea.querySelector('.answer-content');
    const answerText = answerArea.querySelector('.answer-text');
    // 이미 수정 모드인 경우 무시 -> how?
    if (answerArea.classList.contains('editing')) return;

    originText = answerText.textContent;
    // 현재 답변 내용 가져오기
    const currentText = answerText.textContent;
    
    // 수정 모드로 변경
    answerArea.classList.add('editing');

    // 수정 버튼 숨기기
    const editBtn = answerArea.querySelector('.btn-edit-answer');
    editBtn.style.display = 'none';

    // 답변 내용을 textarea로 변경
    answerContent.innerHTML =
        `<div class="answer-edit-area">
            <textarea id="editAnswerText-\${inquiryId}" rows="4">\${currentText}</textarea>
            <div class="answer-edit-actions">
                <button type="button" class="btn btn-outline btn-sm" onclick="cancelEditAnswer(\${inquiryId}, '\${originText}')">
                    <i class="bi bi-x me-1"></i>취소
                </button>
                <button type="button" class="btn btn-primary btn-sm" onclick="submitReply(\${inquiryId}, \${tripProdNo})">
                    <i class="bi bi-check me-1"></i>수정 완료
                </button>
            </div>
        </div>`;

    // textarea에 포커스
    document.getElementById('editAnswerText-' + inquiryId).focus();
}

// 문의사항 수정 취소하기
function cancelEditAnswer(inquiryId, originText){
	console.log("cancelEditAnswer - originText : ", originText);
    const item = document.querySelector('.inquiry-modal-item[data-id="' + inquiryId + '"]');
    const answerArea = item.querySelector('.inquiry-modal-answer');
    const answerContent = answerArea.querySelector('.answer-content');
    answerArea.classList.remove('editing');
    
    const editBtn = answerArea.querySelector('.btn-edit-answer');
    editBtn.style.display = 'block';
    
    answerContent.innerHTML = `<p><strong>A.</strong> <span class="answer-text">\${originText}</span></p>`;
}

// 문의사항 답변 삭제
function deleteAnswer(inquiryId, tripProdNo){
	console.log("deleteAnswer inquiryId : ", inquiryId);
	console.log("deleteAnswer tripProdNo : ", tripProdNo);
    if (!confirm('답변을 삭제하시겠습니까?\n삭제된 답변은 복구할 수 없습니다.')) return;

    const item = document.querySelector('.inquiry-modal-item[data-id="' + inquiryId + '"]');
    const answerArea = item.querySelector('.inquiry-modal-answer');

    const sendData = {prodInqryNo : inquiryId};
    axios.post(`/tour/\${tripProdNo}/inquiry/reply/delete`, sendData)
    .then((response) =>{
    	const data = response.data;
		console.log("data : ", data);
		if (data.success) {
			showToast('답변이 삭제되었습니다.', 'success');
		    // 대기상태로 변경
			item.classList.remove('is-answered');
			item.classList.add('is-waiting');
			item.dataset.status = 'waiting';
			
		    const statusBadge = item.querySelector('.inquiry-status');
		    statusBadge.className = 'inquiry-status waiting';
		    statusBadge.textContent = '답변대기';
    	}else showToast(data.message || '삭제에 실패했습니다.', 'warning');
	})
	.catch((error) => {
	    console.error("Reply Error:", error);
	    var errorMsg = error.response ? error.response.data.message : "서버 통신 오류";
	    showToast(errorMsg, 'error');
	});
}

// 시간 설정
function setTime (date){
	if (date === null || date === undefined || date === "") return "";

    // 1. 만약 date가 객체(new Date())라면 문자열로 변환
    if (date instanceof Date) {
        return date.getFullYear() + '-' + 
               String(date.getMonth() + 1).padStart(2, '0') + '-' + 
               String(date.getDate()).padStart(2, '0');
    }
	
	console.log("date: ", date);
	let format = date.indexOf("T") > -1 ? date.split("T") : date.split(" ");
	return format[0];
}

// 지역 가져오기
function setArea (ctyNm){
	let area = "";
	switch(ctyNm){
		case '1' :
			area = "서울";
			break;
		case '2' :
			area = "인천";
			break;
		case '3' :
			area = "대전";
			break;
		case '31' :
			area = "경기";
			break;
		case '32' :
			area = "강원";
			break;
		case '8' :
			area = "세종";
			break;
		case '33' :
			area = "충북";
			break;
		case '34' :
			area = "충남";
			break;
		case '5' :
			area = "광주";
			break;
		case '37' :
			area = "전북";
			break;
		case '38' :
			area = "전남";
			break;
		case '6' :
			area = "부산";
			break;
		case '4' :
			area = "대구";
			break;
		case '7' :
			area = "울산";
			break;
		case '35' :
			area = "경북";
			break;
		case '36' :
			area = "경남";
			break;
		default :
			area = "제주";
			break;
	}
	return area;
}

// 문의 내역 타입 설정
function setInquiryCategory(inquiry){
	if(inquiry === null || inquiry === "") return "";
	let inquiryType = "";
	switch(inquiry){
		case "product":
			inquiryType = "상품 문의";
			break;
		case "booking":
			inquiryType = "예약/일정 문의";
			break;
		case "price":
			inquiryType = "가격/결제 문의";
			break;
		case "cancel":
			inquiryType = "취소/환불 문의";
			break;
		default :
			inquiryType = "기타 문의";
			break;
	}
	return inquiryType;
}

// 전화번호 포맷 설정
function formatTel(tel) {
	console.log("tel :", tel);
    if (!tel) return '정보 없음';
    // 숫자만 남기기
    const n = tel.replace(/\D/g, ''); 
    // 10~11자리 숫자를 3묶음으로 나누어 하이픈 삽입
    return n.length === 11 
        ? n.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3')
        : n.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3');
}

//예약 내역 클릭시 보여줄 아코디언 활성화
window.toggleDetail = function(id) {
	const detailRow = document.getElementById(id);
    
    if (detailRow) {
        if (detailRow.style.display === "none") {
            detailRow.style.display = "table-row";
            // 만약 아이콘이 있다면 여기서 변경 로직 추가
        } else detailRow.style.display = "none";
    } else {
        console.error("해당 ID의 상세 행을 찾을 수 없습니다: " + id);
    }
};

// 수정할 상품 사진 modal에 세팅 - imageData는 선택시 썸네일 보여주려고
function renderImageList(imageData = ""){
	// imageList = 5개까지만 가능
	if(imageData !== "" && imageData.files && imageData.files[0]){
		const file = imageData.files[0];
		
		if(imageList.length >= 5){
			showToast("사진은 5개까지만 가능합니다!!", "error");
			imageData.value = "";
			return;
		}
		
		const reader = new FileReader();
        reader.onload = function(e) {
            // 새 이미지 객체 생성 (기존 DB 데이터와 형식을 맞춤)
            const newImgObj = {
                isNew: true, // 새로 추가된 파일임을 표시
                filePath: e.target.result, // 미리보기용 base64 경로
                fileObj: file // 실제 전송할 파일 객체
            };
            console.log("newImgObj : ", newImgObj);
            imageList.push(newImgObj);
            displayImages(); // 화면 다시 그리기
        };
        reader.readAsDataURL(file);
	} else displayImages();
}

//2. 실제로 화면에 이미지를 출력하는 함수
function displayImages() {
    imageContainer.innerHTML = '';

    if (imageList.length === 0) {
        imageContainer.innerHTML = '<div class="text-muted p-3">등록된 사진이 없습니다.</div>';
        return;
    }

    const html = imageList.map((image, index) => {
    	console.log("image, ", image);
        const imgSrc = image.isNew ? image.filePath : `${pageContext.request.contextPath}/upload\${image.filePath}`;
        
        return `
            <div class="image-item">
                <img src="\${imgSrc}" alt="\${image.fileOriginalName}">
                <button type="button" class="remove-btn" onclick="removeImage(\${index})">
                    <i class="bi bi-x"></i>
                </button>
            </div>`;
    }).join('');

    imageContainer.innerHTML = html;
}

// 3. 이미지 삭제 함수
function removeImage(index) {
	if (confirm("이 이미지를 삭제하시겠습니까?")) {
        const target = imageList[index];

        imageList.splice(index, 1); // 배열에서 제거
        displayImages(); // 화면 갱신
        showToast("이미지가 목록에서 제거되었습니다.", "info");
    }
}

// 수정할 상품 정보 modal에 세팅
function renderProductData(data, prefix = ""){
	if (!data) return;
	
// 	Object.keys(data).forEach(key => {
//         const value = data[key];
        
//         // 1. VO 필드명 보정 (Alias)
//         let currentKey = key;
//         if (key === "roomFacility") currentKey = "facility";
//         if (key === "roomFeature") currentKey = "feature";

//         // 2. 최종 name 속성 문자열 생성
//         // prefix가 있으면 "accommodation.accTel", 없으면 "tripProdNo"
//         const nameAttr = prefix ? `${prefix}.${currentKey}` : currentKey;
        
//         if (Array.isArray(value)) {
//             // 리스트(객실, 옵션 등) 처리
//             value.forEach((item, index) => {
//                 const nextPrefix = `${nameAttr}[${index}]`;
//                 renderProductData(item, nextPrefix);
//             });
//         } else if (value !== null && typeof value === 'object' && key !== "prodTimeList") {
//             // 중첩된 객체면 더 깊이 들어감
//             renderProductData(value, nameAttr);
//         } else {
//             // 3. 실제 DOM 요소에 값 채우기
//             const tags = document.querySelectorAll(`[name="${nameAttr}"]`);
//             tags.forEach(tag => {
//                 if (tag.type === 'checkbox') {
//                     tag.checked = (value === 'Y');
//                 } else if (tag.tagName === 'TEXTAREA') {
//                     tag.value = value ?? ''; // 숙소 설명(overview) 등 처리
//                 } else {
//                     tag.value = value ?? ''; // 전화번호(accTel) 등 처리
//                 }
//             });
//         }
//     });
	
    Object.keys(data).forEach(key => {
        const value = data[key];
        
//         if (key === "roomFacility") currentKey = "facility";
//         if (key === "roomFeature") currentKey = "feature";
        const nameAttr = prefix ? `\${prefix}.\${key}` : key;
        
//         if (key === "roomTypeList" && Array.isArray(value)) {
//             value.forEach((room, index) => renderProductData(room, `roomTypeList[\${index}]`));
//             return;
//         }
        
        
        if (key === "roomTypeList" && Array.isArray(value)) {
            value.forEach((room, index) => {
                // 기존 prefix가 있다면 합쳐줘야 함!
                const nextPrefix = prefix ? `\${prefix}.roomTypeList[\${index}]` : `roomTypeList[\${index}]`;
                renderProductData(room, nextPrefix);
            });
            return;
        }
        
//         if (key === "accOptionList" && Array.isArray(value)) {
//             value.forEach((option, index) => renderProductData(option, `accOptionList[\${index}]`));
//             return;
//         }
        
        if (key === "accOptionList" && Array.isArray(value)) {
		    value.forEach((option, index) => {
		        const nextPrefix = prefix ? `\${prefix}.accOptionList[\${index}]` : `accOptionList[\${index}]`;
		        renderProductData(option, nextPrefix);
		    });
		    return;
		}
        
        if (value !== null && typeof value === 'object' && key !== "prodTimeList") {	// key가 prodTimeList일때 value는 object
            renderProductData(value, nameAttr);
        } else {
            // 실제 DOM 요소 찾기
            const tag = document.querySelector(`[name="\${nameAttr}"]`);
            
            if (tag) {
                if (tag.type === 'checkbox') tag.checked = value === 'Y';
                else if(key === "saleStartDt" || key === "saleEndDt"){
                	let dateSet = data[key].split("T");
                	tag.value = dateSet[0];
                } else tag.value = value ?? '';	  // 일반 text, number, hidden 등 value가 null이나 undefined일 경우는 ''가 된다
            }
        }
    });
}

// 계층형 name(a.b[0].c)을 해석하여 객체 구조를 생성하는 헬퍼 함수
function buildHierarchy(obj, path, value) {
    // '.' 또는 '[' 또는 ']'를 기준으로 split 하여 경로 배열 생성
    const keys = path.split(/[\.\[\]]/g).filter(p => p !== "");
    let current = obj;

    for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        const isLast = i === keys.length - 1;

        if (isLast) {
            // 마지막 경로면 값을 대입
            current[key] = value;
        } else {
            const nextKey = keys[i + 1];
            const isNextNumber = !isNaN(parseInt(nextKey)); // 다음 키가 숫자면 배열로 준비

            if (!current[key]) current[key] = isNextNumber ? [] : {};
            current = current[key];
        }
    }
}

// 상품 저장 - insert / update(문구에 따라서)
// [수정된 순서]
async function saveProduct(data) {
    const isUpdate = (data.innerText === "수정");
    
//     document.querySelector("[name='accommodation.overview']");
//     document.querySelector("[name='tripProdContent']");
    
    const form = document.getElementById('productForm');
    
    // 1. 데이터 수집을 위한 활성화
    citySelector.disabled = false;
    category.disabled = false;

    // 2. [중요] JSON 보따리 만들기 (평문 데이터 수집)
    const rawFormData = new FormData(form);
    const productDataObject = {};

    rawFormData.forEach((value, key) => {
        if (!(value instanceof File)) {
            buildHierarchy(productDataObject, key, value);
        }
    });

    // 3. [추가] 숙소가 아닐 때 예약 시간도 JSON 보따리에 합치기
    // 이렇게 해야 톰캣 파라미터 개수가 안 늘어납니다.
    if (category.value !== 'accommodation') {
        productDataObject.bookingTimesString = bookingTimes.join(",");
    }

    // 4. [핵심] 최종 전송용 FormData 생성
    const finalFormData = new FormData();

    // 파트 1: JSON 보따리 (Blob으로 변환해서 딱 1개만 넣음)
    const jsonBlob = new Blob([JSON.stringify(productDataObject)], { type: 'application/json;charset=utf-8' });
    finalFormData.append("productData", jsonBlob, "data.json");		// 이게 없으면 파일 없어도 받아짐? 

    // 파트 2: 파일 번호들 (수정 시)
    const currentFileNos = imageList.filter(img => !img.isNew && img.fileNo != null).map(img => img.fileNo);
    currentFileNos.forEach(no => finalFormData.append("currentFileNos", no));

    // 파트 3: 실제 파일들
    imageList.forEach(img => {
        if (img.isNew && img.fileObj) finalFormData.append("uploadFiles", img.fileObj);
    });

    console.log("등록 요청!")
    
    // 5. 서버로 전송 (전송 시 finalFormData를 보내야 함!)
    try {
        const url = isUpdate ? '/product/manage/editProduct' : '/product/manage/registerProduct';
        const res = await axios.post(url, finalFormData); // 주의: formData가 아니라 finalFormData입니다!

        console.log("res.data : ", res.data);
        if (res.data === "OK") {
            // showToast('성공!', 'success');
           	if(!isUpdate) showToast('상품 등록 성공! 판매는 관리자의 허가 후 가능합니다.', 'success');
          	if(isUpdate) showToast('상품 수정 성공! 판매는 관리자의 허가 후 가능합니다.', 'success');
          	
           	setTimeout(() => {
	            location.reload();
            }, 1000);
        }
    } catch (error) {
        console.error(error);
    }
}

// 상품 상태 변경 - update
function toggleProductStatus(data) {
	const { id, status, aprv } = data.dataset;
	if(aprv !== 'Y') {
		showToast('판매 승인되지 않은 상품의 상태 변경은 허가되지 않습니다.', 'error');
		return;
	}
    
    if (confirm('상품 상태를 변경하시겠습니까?')) {
        axios.post(`/product/manage/changeProductStatus`, {
        	tripProdNo : id,
        	approveStatus : status
        })
        .then(res => {
        	if (res.data === "OK") {
        		showToast("상품 판매 상태가 변경되었습니다.");
		        setTimeout(() => {
		        	location.reload() 
	        	}, 1000);
        	}
        	else showToast('상품 상태 변경에 실패하였습니다.', 'success');
        }).catch(err => {
        	console.log("error 발생 : ", err);
        });
    }
}

// 상품 삭제
function deleteProduct(data) {
	const { id } = data.dataset;
    if (confirm('정말 삭제하시겠습니까?\n삭제된 상품은 복구할 수 없습니다.')) {
        axios.post(`/product/manage/removeProduct`, {
        	tripProdNo : id
        })
        .then(res => {
        	console.log("res.data : ", res.data);
        	console.log("res.data.ok : ", res.data);
        	if (res.data === "OK") {
        		showToast('상품이 삭제되었습니다.', 'success');
        		
		        setTimeout(() => {
		        	location.reload() 
	        	}, 1000);
        	}
        	else showToast('상품이 삭제되지않았습니다.', 'error');
        }).catch(err => {
        	console.log("error 발생 : ", err);
        });
    }
}

// 필터링 - 검색(스크립트로)
function filterProducts() {
    // 스크립트
}

// 시간 추가 - 수정시 받은 데이터 만큼 넣기
function addBookingTime(getTime = "") {
    const timeInput = document.getElementById('newBookingTime');
    var time = timeInput.value;

    if (!time) {
        showToast('시간을 선택해주세요.', 'warning');
        return;
    }

    // 중복 체크
    if (bookingTimes.includes(time)) {
        showToast('이미 추가된 시간입니다.', 'warning');
        return;
    }

    bookingTimes.push(time);
    bookingTimes.sort(); // 시간순 정렬
    renderBookingTimes();
    timeInput.value = '';
}

// 시간 제거
function removeBookingTime(time) {
    bookingTimes = bookingTimes.filter(t => t !== time);
    renderBookingTimes();
}

// 시간 목록 렌더링 - 여기서 데이터 받자
function renderBookingTimes() {

    if (bookingTimes.length === 0) timeListContainer.innerHTML = '';
    else {
        var html = bookingTimes.map(time => {
            let displayTime = ""; // 24시간 형식을 보기 좋게 변환
            if (time.length > 5) displayTime = formatTime(time);
            return `<span class="booking-time-slot">
                       <i class="bi bi-clock"></i>\${displayTime === "" ? time : displayTime}
                       <button type="button" class="remove-time" onclick="removeBookingTime('\${time}')">
                           <i class="bi bi-x"></i>
                       </button>
                   </span>`;
        }).join('');
        timeListContainer.innerHTML = html;
    }
    
    document.getElementById('bookingTimesInput').value = bookingTimes.join(',');
}

// 시간 포맷 변환 (HH:MM -> 오전/오후 표시)
function formatTime(time) {
    const parts = time.split(':');
    const hour = parseInt(parts[0]);
    const minute = parts[1];
    const period = hour < 12 ? '오전' : '오후';
    const displayHour = hour === 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return period + ' ' + displayHour + ':' + minute;
}

// 프리셋 시간 추가 - 필터링 걸어야됨
function addPresetTimes(type) {
    var presets = {
        'morning': ['09:00', '10:00', '11:00'],
        'afternoon': ['13:00', '14:00', '15:00', '16:00'],
        'hourly': ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00']
    };
	
    let runTime = document.querySelector("input[name='prodInfo.prodRuntime']");
    console.log("runTime : ", runTime.value);
    
    var times = presets[type] || [];
    var addedCount = 0;
	
    // 운영 시간 내의 유효 시간만 담기
//     times.filter(time => { });
    times.forEach(time => {
        if (!bookingTimes.includes(time)) {
            bookingTimes.push(time);
            addedCount++;
        }
    });

    if (addedCount > 0) {
        bookingTimes.sort();
        renderBookingTimes();
        showToast(addedCount + '개의 시간이 추가되었습니다.', 'success');
    } else showToast('추가할 새 시간이 없습니다.', 'info');
}

// 주소 검색 (카카오 주소 API)
function searchAddress() {
	// 주소 가져오고
    new daum.Postcode({
        oncomplete: function(data) {
            // 주소 정보 설정
            console.log("data.roadAddress : ",data.roadAddress );
            console.log("data.address : ",data.address );
            console.log("data : ", data);
            console.log("data.query : ", data.query);
//             const address = data.roadAddress || data.address; 	// 도로명 주소 우선
//             const sidoCode = data.bcode.substring(0, 2);    	// 법정동 코드 앞 2자리 (시도 매핑용)
            const isAcc = category.value === 'accommodation';	// true false

            
            // 필요 데이터 = data.bcode, data
//             data.bcode		//  sidoCode와 signuguCode로 보낼것
            const ldongRegnCd = data.bcode.substring(0, 2);	// 법정동 시도
            const ldongSignguCd = data.bcode.substring(2, 5);	// 법정동 시군구
            const zone = data.zonecode	// 숙소 api의 zipcode와 매칭 할 
            // addr1과 매칭할 것들
            const sido = data.sido;
            const roadAddress = data.roadAddress;
            const address = data.address;
            const jibunAddress = data.jibunAddress;
            const finalAccName = data.buildingName || data.query;	// 건물명 있으면 건물명, 없으면 검색어 사용
            const keyword = data.query;		// 검색어
            
            const matchData = {
            	sido : sido,
           		ldongRegnCd : ldongRegnCd,
           		ldongSignguCd : ldongSignguCd,
           		zone : zone,
           		roadAddress : roadAddress,
           		address : address,
           		jibunAddress : jibunAddress,
           		accName : finalAccName,
           		keyword : keyword
            };
            
            // 1. 주소 텍스트 입력
            if (isAcc) accommodationAddress.value = address;	// roadAddress 받아야됨
            else document.getElementById('productAddress').value = address;
            document.querySelector("[name='accommodation.zip']").value = zone;
         	document.querySelector("[name='accommodation.ldongRegnCd']").value = ldongRegnCd;
            // 2. 좌표 검색 (카카오 API)
            geocoder.addressSearch(address, function(result, status) {
                if (status === kakao.maps.services.Status.OK) {
		            
                    const y = result[0].y; // 위도
                    const x = result[0].x; // 경도

                    // 지도 섹션 보이기
                    const mapSection = document.getElementById('mapSection');
                    if (mapSection) mapSection.style.display = 'block';
                    
                	// 지도 위치 갱신
                    const coords = new kakao.maps.LatLng(y, x);
                    updateModalMap(coords);
                    
		            if (isAcc) searchTourApi(matchData);
                    
		         	// 3. [핵심] 숙박 카테고리이고 건물명이 있다면 관광 API 호출
                }else{
                	showToast("좌표를 불러오지 못했습니다.", "warning");
                }
            });
        }
    }).open();
}

// 지도 업데이트
function updateModalMap(coords) {
    const container = document.getElementById('registerMap'); // HTML의 지도 div ID
    
    if (!regMap) {
        // 지도가 없으면 새로 생성
        const options = { center: coords, level: 3 };
        regMap = new kakao.maps.Map(container, options);
        regMarker = new kakao.maps.Marker({ position: coords, map: regMap });
    } else {
        // 지도가 있으면 위치만 이동
        regMap.setCenter(coords);
        regMarker.setPosition(coords);
    }
    
    // 부트스트랩 모달 등 레이아웃 변화에 대응
    setTimeout(() => {
        regMap.relayout();
        regMap.setCenter(coords);
    }, 200);
}

// 숙소 정보를 가져오기 위한 관광 api 호출
async function searchTourApi(matchData) {
	const overlay = document.getElementById('loading-overlay');
    
    // 로딩창 띄우기 (화면이 어두워짐)
    overlay.style.display = 'flex';
    
    try {
    	console.log("matchData : ", matchData);
        const response = await axios.get(`/batch/accommodation/search`, {
        	params: matchData
        });
        
        const data = response.data; // 서버에서 준 숙소 정보 객체
		console.log("api 결과 data : ", data);
        
        // 텍스트 자동 입력
        if (data && data.apiContentId) {
            
        	// 룸타입 컨테이너 초기화하고 새로 출력
        	if (data.roomTypeList && data.roomTypeList.length > 0) {
                roomTypeContainer.innerHTML = '';
                data.roomTypeList.forEach(() => addRoomType());
            }
        	
        	if (data.accOptionList && data.accOptionList.length > 0) {
                addOptionsContainer.innerHTML = '';
                data.accOptionList.forEach(() => addOption());
            }
        	
        	// prefix붙은 부분 매치
        	renderProductData(data, "accommodation");
        	
        	let accCode = document.querySelector("[name='accommodation.accCatCd']");		// 숙소 타입
        	let starGrade = document.querySelector("[name='accommodation.starGrade']");		// 성급
			if(accCode.value === "B02010100" || accCode.value === "B02010500") starGrade.style.display = "block";
			else starGrade.style.display = "none";

            
            if(data.accName) {
            	document.querySelector("[name='tripProdTitle']").value = 
            		data.accName.length >= 600 ? data.accName.slice(0, 580) : data.accName;
            }
            if(data.overview) document.querySelector("[name='tripProdContent']").value = data.overview;
			if(data.areaCode) citySelector.value = data.areaCode;            
            
            // 2. 좌표 및 이미지 세팅 -> 파일 no는 어차피 둘다 있음. 이거는 알아서 넣으면 되는것. 세팅도 내맘
            
            // 3. 사진 미리보기 업데이트		    	document.querySelector("#mainImagePreview").innerHTML = accImage;    

            if (data.accFilePath) {
            	let imgHtml = `<img src="\${data.accFilePath}" alt=""
            		style="width:300px; height:200px; object-fit:cover;"/>`;
            	document.querySelector("#mainImagePreview").innerHTML = imgHtml;
            }
            
            alert(`[\${data.accName}] 정보를 성공적으로 가져왔습니다.`);
        } else alert(`정보를 못가져왔습니다.`);
    } catch (err) {
		console.error("API 호출 중 에러 발생:", err);
        if (err.response && err.response.status === 400) {
            // 서버에서 null을 리턴하거나 중복된 경우
            showToast("일치하는 숙소 정보가 없거나 이미 등록된 숙소입니다.", "warning");
        } else showToast("일치하는 숙소 정보가 없거나 이미 등록된 숙소입니다.", "warning");
        
        // showToast("서버 통신 중 오류가 발생했습니다.", "error");
        accommodationAddress.value = "";
        
    } finally {
        overlay.style.display = 'none';
    }
}

// ===== 상품 선택 기능 =====
// 전체 선택/해제
function toggleSelectAll(checkbox) {
    var productCheckboxes = document.querySelectorAll('.product-select-checkbox');
    productCheckboxes.forEach((cb) => {
        cb.checked = checkbox.checked;
        var productCard = cb.closest('.product-manage-card');
        if (checkbox.checked) productCard.classList.add('selected');
        else productCard.classList.remove('selected');
    });
    updateSelectedCount();
}

// 개별 체크박스 클릭 시
function toggleProductSelect(checkbox) {
    var productCard = checkbox.closest('.product-manage-card');
    if (checkbox.checked) productCard.classList.add('selected');
    else productCard.classList.remove('selected');

    // 전체 선택 체크박스 상태 업데이트
    var allCheckboxes = document.querySelectorAll('.product-select-checkbox');
    var checkedCheckboxes = document.querySelectorAll('.product-select-checkbox:checked');
    var selectAllCheckbox = document.getElementById('selectAllProducts');

    if (checkedCheckboxes.length === allCheckboxes.length) {
        selectAllCheckbox.checked = true;
        selectAllCheckbox.indeterminate = false;
    } else if (checkedCheckboxes.length === 0) {
        selectAllCheckbox.checked = false;
        selectAllCheckbox.indeterminate = false;
    } else {
        selectAllCheckbox.checked = false;
        selectAllCheckbox.indeterminate = true;
    }

    updateSelectedCount();
}

// 선택된 상품 수 업데이트
function updateSelectedCount() {
    var checkedCheckboxes = document.querySelectorAll('.product-select-checkbox:checked');
    var count = checkedCheckboxes.length;

    document.getElementById('selectedCount').textContent = count + '개 선택됨';

    // 액션 버튼 활성화/비활성화
    var actionButtons = document.querySelectorAll('#selectionActions .btn');	// 선택 상품 상태 변경, 삭제, 재게
    actionButtons.forEach(btn => btn.disabled = count === 0);
}

// 선택된 상품 ID 목록 가져오기
function getSelectedProductIds() {
	var checkedCheckboxes = document.querySelectorAll('.product-select-checkbox:checked');
    const ids = [];	// 
// 	    console.log("getSelectedProductIds id", cb.value);
    // approved 상태도 바꿔야될듯
    checkedCheckboxes.forEach(cb => ids.push(cb.value));
    return ids;
}

// 선택 상품 중지 -> axios사용
function pauseSelectedProducts() {
	// status 바구기
    var selectedIds = getSelectedProductIds();
    if (selectedIds.length === 0) {
        if (typeof showToast === 'function') showToast('선택된 상품이 없습니다.', 'warning');
        return;
    }

    if (!confirm(selectedIds.length + '개의 상품을 중지하시겠습니까?')) return;

    // 선택된 상품들의 상태를 중지로 변경 (UI 업데이트)
    selectedIds.forEach(id => {
        var checkbox = document.querySelector('.product-select-checkbox[value="' + id + '"]');
        if (checkbox) {
            var productCard = checkbox.closest('.product-manage-card');
            var statusBadge = productCard.querySelector('.product-status');
            if (statusBadge && statusBadge.classList.contains('active')) {
                statusBadge.className = 'product-status inactive';
                statusBadge.textContent = '판매중지';
                productCard.classList.add('inactive');
                productCard.setAttribute('data-status', 'inactive');
            }
        }
    });

    // 선택 해제
    clearProductSelection();
    showToast(selectedIds.length + '개의 상품이 중지되었습니다.', 'success');

    // 통계 업데이트
    updateProductStats();
}

// 선택 상품 재개
function resumeSelectedProducts() {
    var selectedIds = getSelectedProductIds();
    if (selectedIds.length === 0) {
        if (typeof showToast === 'function') showToast('선택된 상품이 없습니다.', 'warning');
        return;
    }

    if (!confirm(selectedIds.length + '개의 상품을 재개하시겠습니까?')) return;
	// 변경함수 
    
    // 선택된 상품들의 상태를 판매중으로 변경 (UI 업데이트)
    selectedIds.forEach(id => {
        var checkbox = document.querySelector('.product-select-checkbox[value="' + id + '"]');
        if (checkbox) {
            var productCard = checkbox.closest('.product-manage-card');
            var statusBadge = productCard.querySelector('.product-status');
            if (statusBadge && statusBadge.classList.contains('inactive')) {
                statusBadge.className = 'product-status active';
                statusBadge.textContent = '판매중';
                productCard.classList.remove('inactive');
                productCard.setAttribute('data-status', 'active');
            }
        }
    });

    // 선택 해제
    clearProductSelection();
    showToast(selectedIds.length + '개의 상품이 재개되었습니다.', 'success');

    // 통계 업데이트
    updateProductStats();
}

// 선택 상품 삭제
function deleteSelectedProducts() {
    var selectedIds = getSelectedProductIds();
    if (selectedIds.length === 0) {
        if (typeof showToast === 'function') showToast('선택된 상품이 없습니다.', 'warning');
        return;
    }

    if (!confirm(selectedIds.length + '개의 상품을 삭제하시겠습니까?\n삭제된 상품은 복구할 수 없습니다.')) {
        return;
    }

    // 선택된 상품들 제거 (UI 업데이트)
    var deleteCount = selectedIds.length;
    selectedIds.forEach(function(id) {
        var checkbox = document.querySelector('.product-select-checkbox[value="' + id + '"]');
        if (checkbox) {
            var productCard = checkbox.closest('.product-manage-card');
            productCard.style.transition = 'opacity 0.3s, transform 0.3s';
            productCard.style.opacity = '0';
            productCard.style.transform = 'translateX(-20px)';
            setTimeout(function() {
                productCard.remove();
                updateProductStats();
            }, 300);
        }
    });

    // 선택 해제
    clearProductSelection();

	showToast(deleteCount + '개의 상품이 삭제되었습니다.', 'success');
}

// 선택 해제
function clearProductSelection() {
    var allCheckboxes = document.querySelectorAll('.product-select-checkbox');
    allCheckboxes.forEach(function(cb) {
        cb.checked = false;
        var productCard = cb.closest('.product-manage-card');
        if (productCard) productCard.classList.remove('selected');
    });

    var selectAllCheckbox = document.getElementById('selectAllProducts');
    if (selectAllCheckbox) {
        selectAllCheckbox.checked = false;
        selectAllCheckbox.indeterminate = false;
    }

    updateSelectedCount();
}

// 상품 통계 업데이트
function updateProductStats() {
    var allProducts = document.querySelectorAll('.product-manage-card');
    var activeProducts = document.querySelectorAll('.product-status.active');
    var inactiveProducts = document.querySelectorAll('.product-status.inactive');

    // 통계 카드 업데이트
    var statCards = document.querySelectorAll('.stat-card .stat-value');
    if (statCards.length >= 3) {
        statCards[0].textContent = allProducts.length;
        statCards[1].textContent = activeProducts.length;
        statCards[2].textContent = inactiveProducts.length;
    }
}

// ==================== 카테고리별 필드 전환 ====================
function toggleCategoryFields() {
    // 기본 섹션들
    const regionField = document.getElementById('regionField');
    const durationField = document.getElementById('durationField');
    const descriptionField = document.getElementById('descriptionField');
    const defaultInfoSection = document.getElementById('defaultInfoSection');
    const defaultPriceSection = document.getElementById('defaultPriceSection');
    const productNameField = document.getElementById('productNameField');
    const locationField = document.getElementById('locationField');
    const prodAddress = document.getElementById('prodAddress');
    
    const prodContent = document.getElementById('prodContent');		// 상품 내용 - category따라서 내용 바꾸기
	const tripProdContent = document.querySelector("[name='tripProdContent']"); // place hoder 바꾸기
	const overview = document.querySelector("[name='accommodation.overview']"); // 숙발일떄 보여줄 것
   
    // 숙박 섹션들
    const accommodationFields = document.getElementById('accommodationFields');						// 숙소 필드
    const accommodationNameField = document.getElementById('accommodationNameField');				// 숙소명
    const accommodationDescriptionField = document.getElementById('accommodationDescriptionField');	// 숙소설명
	const accommodationAdditionalImages = document.getElementById('accommodationAdditionalImages');	// 숙박에서만 보여줄것
	const accommodationAddressTag = document.getElementById('accommodationAddressTag');					// 숙소 주소
//     const accomImageField = document.getElementById('accomImageField');
    
	// 해당 필드의 값들 초기화 해주기

	
	
    // 모든 섹션 초기화 (숨기기)
    accommodationFields.style.display = 'none';
//     accommodationAdditionalImages.style.display = 'none';
    
    if (category.value === 'accommodation') {
        // 숙박 선택 시
        locationField.style.display = 'block';
        regionField.style.display = 'block';
        durationField.style.display = 'none';
        descriptionField.style.display = 'block';  // 숙소 소개 표시
        defaultInfoSection.style.display = 'none';
        defaultPriceSection.style.display = 'none';
        prodAddress.style.display = 'none';
        productNameField.style.display = 'none';
        prodContent.innerText= "숙소 설명";
        tripProdContent.style.display = 'none';
        tripProdContent.value = "";	// 토글 바뀌면 초기화
        
        overview.style.display = 'block';
        accommodationAddressTag.style.display = 'block';
        accommodationFields.style.display = 'block';
        accommodationNameField.style.display = 'block';
//         accomImageField.style.display = 'block';
// 	    accommodationAdditionalImages.style.display = 'block';
    } else {
        // 기본 상품 (이외의 상품)
        productNameField.style.display = 'block';
        locationField.style.display = 'block';
        regionField.style.display = 'block';
        durationField.style.display = 'block';
        descriptionField.style.display = 'block';
        defaultInfoSection.style.display = 'block';
        defaultPriceSection.style.display = 'block';
        prodAddress.style.display = 'block';
        prodContent.innerText= "상품 설명";
        tripProdContent.style.display = 'block';
        
        overview.style.display = 'none';
        accommodationFields.style.display = 'none';
        accommodationAddressTag.style.display = 'none';
        accommodationNameField.style.display = 'none';
// 	    accommodationAdditionalImages.style.display = 'none';
    }
}

// 객실을 담을 것 생성
function addRoomType() {
	// 처음에는 아무것도 없기에 0부터 시작
	// 객실 타입 \${index + 1}은 화면에만 보여지는 것
	const index = roomTypeContainer.children.length;
	const prefix = `accommodation.roomTypeList[\${index}]`;
	console.log("addRoomType : prefix => ", prefix )

	// pk 존재
	const roomHtml =
	    `<div class="room-type-item" data-room-index="\${index}">
	        <div class="room-type-header">
	            <h6><i class="bi bi-door-closed me-2"></i>객실 타입 \${index + 1}</h6>
	            <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeRoomType('\${index}')">
	                <i class="bi bi-x"></i> 삭제
	            </button>
	        </div>
	        <input type="hidden" name="accommodation.roomTypeList[\${index}].roomTypeNo" />
	        <div class="row mb-3">
	            <div class="col-md-4">
	                <label class="form-label">객실명 <span class="text-danger">*</span></label>
	                <input type="text" class="form-control" name="accommodation.roomTypeList[\${index}].roomName" placeholder="예: 디럭스 트윈">
	            </div>
	            <div class="col-md-4">
	                <label class="form-label">기준 인원 <span class="text-danger">*</span></label>
	                <input type="number" class="form-control" name="accommodation.roomTypeList[\${index}].baseGuestCount" placeholder="2" min="1">
	            </div>
	            <div class="col-md-4">
	                <label class="form-label">최대 인원</label>
	                <input type="number" class="form-control" name="accommodation.roomTypeList[\${index}].maxGuestCount" placeholder="4" min="1">
	            </div>
	        </div>
	        <div class="row mb-3">
		        <div class="col-md-4">
		            <label class="form-label">1박 가격 <span class="text-danger">*</span></label>
		            <div class="input-group">
		                <input type="number" class="form-control" name="accommodation.roomTypeList[\${index}].price" placeholder="0">
		                <span class="input-group-text">원</span>
		            </div>
		        </div>
		        <div class="col-md-4">
		            <label class="form-label">할인율</label>
		            <div class="input-group">
		                <input type="number" class="form-control" name="accommodation.roomTypeList[\${index}].discount" placeholder="0" min="0" max="100">
		                <span class="input-group-text">%</span>
		            </div>
		        </div>
		        <div class="col-md-4">
		            <label class="form-label">인원 추가 비용<span class="text-danger">*</span></label>
		            <div class="input-group">
		                <input type="number" class="form-control" name="accommodation.roomTypeList[\${index}].extraGuestFee" placeholder="0" min="0">
		                <span class="input-group-text">원</span>
		            </div>
		        </div>
		    </div>
	        <div class="row mb-3">
		        <div class="col-md-4">
		            <label class="form-label">객실 수<span class="text-danger">*</span></label>
		            <div class="input-group">
		                <input type="number" class="form-control" name="accommodation.roomTypeList[\${index}].totalRoomCount" placeholder="0" min="0">
		                <span class="input-group-text">실</span>
		            </div>
		        </div>
		        <div class="col-md-4" style="magin-right:10px;">
		            <label class="form-label">객실 크기</label>
		            <div class="input-group">
		                <input type="number" class="form-control" name="accommodation.roomTypeList[\${index}].roomSize" placeholder="23">
		                <span class="input-group-text">㎡</span>
		            </div>
		        </div>
		    </div>
		    <div class="row mb-3">
		        <div class="col-md-6">
		            <label class="form-label">조식 포함 여부</label>
		            <select class="form-select" name="accommodation.roomTypeList[\${index}].breakfastYn">
		                <option value="N" selected>조식 미포함</option>
		                <option value="Y">조식 포함</option>
		            </select>
		        </div>
		        <div class="col-md-6">
		            <label class="form-label">침대 타입</label>
		            <select class="form-select" name="accommodation.roomTypeList[\${index}].bedTypeCd">
		                <option value="">선택하세요</option>
		                <option value="single">싱글</option>
		                <option value="double">더블</option>
		                <option value="queen">퀸</option>
		                <option value="king">킹</option>
		            </select>
		        </div>
		    </div>
	        <div class="mb-3">
	            <label class="form-label">객실 특징</label>
	            <div class="room-features-grid">
		            <div class="form-check">
			            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].feature.freeCancelYn" value="Y" id="freeCancel_\${index}">
			            <label class="form-check-label" for="freeCancel_\${index}"><i class="bi bi-check-circle me-1"></i>무료 취소</label>
			        </div>
			        <div class="form-check">
			            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].feature.oceanViewYn" value="Y" id="oceanView_\${index}">
			            <label class="form-check-label" for="oceanView_\${index}"><i class="bi bi-water me-1"></i>오션뷰</label>
			        </div>
			        <div class="form-check">
			            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].feature.mountainViewYn" value="Y" id="mountainView_\${index}">
			            <label class="form-check-label" for="mountainView_\${index}"><i class="bi bi-mountain me-1"></i>마운틴뷰</label>
			        </div>
			        <div class="form-check">
			            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].feature.cityViewYn" value="Y" id="cityView_\${index}">
			            <label class="form-check-label" for="cityView_\${index}"><i class="bi bi-buildings me-1"></i>시티뷰</label>
			        </div>
			        <div class="form-check">
			            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].feature.livingRoomYn" value="Y" id="livingRoom_\${index}">
			            <label class="form-check-label" for="livingRoom_\${index}"><i class="bi bi-door-open me-1"></i>거실 포함</label>
			        </div>
			        <div class="form-check">
			            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].feature.terraceYn" value="Y" id="terrace_\${index}">
			            <label class="form-check-label" for="terrace_\${index}"><i class="bi bi-flower1 me-1"></i>발코니/테라스</label>
			        </div>
			        <div class="form-check">
			            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].feature.nonSmokingYn" value="Y" id="nonSmoking_\${index}">
			            <label class="form-check-label" for="nonSmoking_\${index}"><i class="bi bi-slash-circle me-1"></i>금연</label>
			        </div>
			        <div class="form-check">
			            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].feature.kitchenYn" value="Y" id="kitchen_\${index}">
			            <label class="form-check-label" for="kitchen_\${index}"><i class="bi bi-cup-hot me-1"></i>주방/취사</label>
			        </div>
	            </div>
	        </div>
	        <div class="mb-3">
	            <label class="form-label">객실 내 시설</label>
	            <div class="amenities-grid">
	            <div class="form-check">
		            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].facility.airConYn" value="Y" id="aircon_\${index}">
		            <label class="form-check-label" for="aircon_\${index}"><i class="bi bi-snow me-1"></i>에어컨</label>
		        </div>
		        <div class="form-check">
		            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].facility.tvYn" value="Y" id="tv_\${index}">
		            <label class="form-check-label" for="tv_\${index}"><i class="bi bi-tv me-1"></i>TV</label>
		        </div>
		        <div class="form-check">
		            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].facility.minibarYn" value="Y" id="minibar_\${index}">
		            <label class="form-check-label" for="minibar_\${index}"><i class="bi bi-box me-1"></i>미니바</label>
		        </div>
		        <div class="form-check">
		            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].facility.fridgeYn" value="Y" id="fridge_\${index}">
		            <label class="form-check-label" for="fridge_\${index}"><i class="bi bi-box-seam me-1"></i>냉장고</label>
		        </div>
		        <div class="form-check">
		            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].facility.safeBoxYn" value="Y" id="safeBox_\${index}">
		            <label class="form-check-label" for="safeBox_\${index}"><i class="bi bi-safe me-1"></i>금고</label>
		        </div>
		        <div class="form-check">
		            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].facility.hairDryerYn" value="Y" id="hairDryer_\${index}">
		            <label class="form-check-label" for="hairDryer_\${index}"><i class="bi bi-wind me-1"></i>헤어드라이어</label>
		        </div>
		        <div class="form-check">
		            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].facility.bathtubYn" value="Y" id="bathtub_\${index}">
		            <label class="form-check-label" for="bathtub_\${index}"><i class="bi bi-droplet-half me-1"></i>욕조</label>
		        </div>
		        <div class="form-check">
		            <input class="form-check-input" type="checkbox" name="accommodation.roomTypeList[\${index}].facility.toiletriesYn" value="Y" id="toiletries_\${index}">
		            <label class="form-check-label" for="toiletries_\${index}"><i class="bi bi-box2 me-1"></i>세면도구</label>
		        </div>
	            </div>
	        </div>
	    </div>`;

    roomTypeContainer.insertAdjacentHTML('beforeend', roomHtml);

    // 첫 번째 객실 삭제 버튼 표시 (2개 이상일 때)
    updateRoomDeleteButtons();
// 	showToast('객실 타입이 추가되었습니다.', 'success');
}

// 선택 객실 삭제 -> 여기도 예약 고객 있는지 확인해서 삭제해야됨
// 삭제시 인덱스도 줄어들게 만들어야되고
function removeRoomType(index) {
    var roomItem = document.querySelector('.room-type-item[data-room-index="' + index + '"]');
    if (roomItem) {
        roomItem.style.transition = 'opacity 0.3s, transform 0.3s';
        roomItem.style.opacity = '0';
        roomItem.style.transform = 'translateX(-20px)';
        setTimeout(function() {
            roomItem.remove();
            updateRoomDeleteButtons();
        }, 300);
    }
}

// 여기서 삭제 버트 만듬
function updateRoomDeleteButtons() {
    var roomItems = document.querySelectorAll('.room-type-item');
    roomItems.forEach((item, idx) => {
        var deleteBtn = item.querySelector('.btn-outline-danger');
        if (deleteBtn) deleteBtn.style.display = roomItems.length > 1 ? 'block' : 'none';
    });
}

// 추가옵션 랜더링
function addOption() {
	const index = addOptionsContainer.children.length;
	const prefix = `accommodation.accOptionList[\${index}]`;
	console.log("addOption : prefix => ", prefix )
	
    const addonHtml =
        `<div class="addon-option-item" data-add-index="\${index}">
            <div class="row">
                <div class="col-md-5">
                    <label class="form-label">옵션명</label>
                    <input type="text" class="form-control" name="accommodation.accOptionList[\${index}].accOptionNm" placeholder="예: 레이트 체크아웃">
                </div>
                <input type="hidden" name="accommodation.accOptionList[\${index}].accOptionNo" />
                <input type="hidden" name="accommodation.accOptionList[\${index}].accNo" />
                <div class="col-md-2">
                    <label class="form-label">인원</label>
                    <div class="input-group">
                        <input type="number" class="form-control" name="accommodation.accOptionList[\${index}].personnelCount" placeholder="0" min="0" value="0">
                        <span class="input-group-text">명</span>
                    </div>
                </div>
                <div class="col-md-3">
                    <label class="form-label">가격</label>
                    <div class="input-group">
                        <input type="number" class="form-control" name="accommodation.accOptionList[\${index}].accOptionPrice" placeholder="0">
                        <span class="input-group-text">원</span>
                    </div>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="button" class="btn btn-outline-danger w-100" onclick="removeAddonOption(\${index})">
                        <i class="bi bi-x"></i>
                    </button>
                </div>
            </div>
        </div>`;

	addOptionsContainer.insertAdjacentHTML('beforeend', addonHtml);

    // 첫 번째 추가 옵션에 삭제 버튼 표시 (2개 이상일 때)
    updateAddonDeleteButtons();
// 	showToast('추가 옵션이 추가되었습니다.', 'success');
}

function removeAddonOption(index) {
    var addonItem = document.querySelector('.addon-option-item[data-add-index="' + index + '"]');
    if (addonItem) {
        addonItem.style.transition = 'opacity 0.3s, transform 0.3s';
        addonItem.style.opacity = '0';
        addonItem.style.transform = 'translateX(-20px)';
        setTimeout(function() {
            addonItem.remove();
            updateAddonDeleteButtons();
        }, 300);
    }
}

function updateAddonDeleteButtons() {
    var addonItems = document.querySelectorAll('.addon-option-item');
    addonItems.forEach(function(item, idx) {
        var deleteBtn = item.querySelector('.btn-outline-danger');
        if (deleteBtn) deleteBtn.style.display = addonItems.length > 1 ? 'block' : 'none';
    });
}
</script>
</body>
</html>