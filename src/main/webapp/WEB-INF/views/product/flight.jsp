<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="항공권 검색" />
<c:set var="pageCss" value="product" />

<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/product-flight.css">

<div class="product-page">
	<!-- 헤더 -->
	<div class="product-header">
		<div class="container">
			<h1>
				<i class="bi bi-airplane me-3"></i>항공권 검색
			</h1>
			<p>국내 항공권을 한 번에 비교하고 최저가를 찾아보세요</p>
			<br/>
		</div>
	</div>
	
	<div class="container">
		<!-- 검색 박스 -->
		<div class="search-box">
			<div class="search-tabs">
				<button class="search-tab active" data-type="round">왕복</button>
				<button class="search-tab" data-type="oneway">편도</button>
				<div class="api-source-text">국토교통부_(TAGO)_국내항공운항정보 API</div>
			</div>
							
			<form id="flightSearchForm">
				<!-- 왕복/편도 검색 폼 -->
				<div id="normalSearchForm">
					<div class="search-form-row">
						<div class="form-group">
							<label class="form-label">출발지</label>
							<div class="search-input-group">
								<span class="input-icon"><i class="bi bi-geo-alt"></i></span> 
								<input type="text" class="form-control airport-autocomplete"
									id="departure" placeholder="도시 또는 공항" autocomplete="off"/>
								<div class="autocomplete-dropdown" id="departureDropdown"></div>
							</div>
							<input type="hidden" name="depAirportId" id="depAirportId"/>
							<input type="hidden" name="depIataCode" id="depIataCode"/> 
						</div>
						
						<div class="form-group">
							<label class="form-label">도착지</label>
							<div class="search-input-group">
								<span class="input-icon"><i class="bi bi-geo-alt-fill"></i></span>
								<input type="text" class="form-control airport-autocomplete"
									id="destination" placeholder="도시 또는 공항" autocomplete="off"/>
								<div class="autocomplete-dropdown" id="destinationDropdown"></div>
							</div>
							<input type="hidden" name="arrAirportId" id="arrAirportId" />
							<input type="hidden" name="arrIataCode" id="arrIataCode"/> 
						</div>
						
						<div class="form-group">
							<label class="form-label">가는날</label> <input type="text"
								class="form-control" id="departDate"
								placeholder="날짜 선택"/>
						</div>
						<div class="form-group" id="returnDateGroup">
							<label class="form-label">오는날</label> <input type="text"
								class="form-control" id="returnDate"
								placeholder="날짜 선택" />
						</div>
						<button type="submit" class="btn btn-primary btn-search">
							<i class="bi bi-search me-2"></i>검색
						</button>
					</div>
				</div>

				<!-- 승객 정보 -->
				<div class="search-form-row mt-3">
					<div class="form-group passenger-dropdown">
						<label class="form-label">승객</label> <input type="text"
							class="form-control passenger-input" id="passengerInput"
							value="성인 1명" readonly onclick="togglePassengerPanel()"/>
						<div class="passenger-panel" id="passengerPanel">
							<div class="passenger-row">
								<div class="passenger-label">
									성인 <span>만 12세 이상</span>
								</div>
								<div class="passenger-counter">
									<button type="button" class="counter-btn"
										onclick="updatePassenger('adult', -1)">-</button>
									<span class="counter-value" id="adultCount">1</span>
									<button type="button" class="counter-btn"
										onclick="updatePassenger('adult', 1)">+</button>
								</div>
							</div>
							<div class="passenger-row">
								<div class="passenger-label">
									소아 <span>만 2~11세</span>
								</div>
								<div class="passenger-counter">
									<button type="button" class="counter-btn"
										onclick="updatePassenger('child', -1)">-</button>
									<span class="counter-value" id="childCount">0</span>
									<button type="button" class="counter-btn"
										onclick="updatePassenger('child', 1)">+</button>
								</div>
							</div>
							<div class="passenger-row">
								<div class="passenger-label">
									유아 <span>만 2세 미만</span>
								</div>
								<div class="passenger-counter">
									<button type="button" class="counter-btn"
										onclick="updatePassenger('infant', -1)">-</button>
									<span class="counter-value" id="infantCount">0</span>
									<button type="button" class="counter-btn"
										onclick="updatePassenger('infant', 1)">+</button>
								</div>
							</div>
						</div>
					</div>
					<div class="form-group">
						<label class="form-label">좌석 등급</label> 
						<select class="form-control form-select" id="cabinClass">
							<option value="economy">일반석</option>
							<option value="business">비즈니스석</option>
						</select>
					</div>
				</div>
			</form>
		</div>
		
		<!-- 선택한 항공편 표시 영역 -->
		<div class="selected-flights-container" id="selectedFlightsContainer"
			style="display: none;">
			<div class="selected-flights-header">
				<h5>
					<i class="bi bi-check-circle-fill me-2"></i>선택한 항공편
				</h5>
				<button type="button" class="btn btn-outline-secondary btn-sm"
					onclick="resetFlightSelection()"><!-- 이거 누르면 초기 상태로 돌아가야됨 - 아니면 첫번쨰 검색한결과를 조회해줘야됨 -->
					<i class="bi bi-arrow-counterclockwise me-1"></i>다시 선택
				</button>
			</div>
			<div class="selected-flights-list" id="selectedFlightsList"></div>
		</div>

		<!-- 현재 선택 단계 표시 -->
		<div class="selection-step-indicator" id="selectionStepIndicator"
			style="display: none;">
			<div class="step-badge">
				<span id="currentStepText">오는날 선택</span>
			</div>
		</div>

		<!-- 검색 결과 -->
		<div class="flight-results" id="flightResults">
			<div class="results-header">
				<p class="results-count">
					<!-- 검색 결과 출력 -->
				</p>
				<div class="sort-options">
					<button class="sort-btn active" data-sort="price">최저가순</button>
					<button class="sort-btn" data-sort="departure">출발시간순</button>
					<button class="sort-btn" data-sort="duration">최단시간순</button>
				</div>
			</div>

			<div class="flight-result">
				<!-- 항공권 출력 -->
			</div>
			<!-- 로딩 인디케이터 -->
			<div class="infinite-scroll-loader" id="flightScrollLoader" style="display: none;">
				<div class="loader-spinner">
					<div class="spinner-border text-primary" role="status">
						<span class="visually-hidden">Loading...</span>
					</div>
				</div>
			</div>

			<!-- 더 이상 데이터 없음 -->
			<div class="infinite-scroll-end" id="flightScrollEnd"
				style="display: none;">
				<p>모든 항공편을 불러왔습니다</p>
			</div>
		</div>
	</div>
</div>

<script>
let passengers = { adult: 1, child: 0, infant: 0 };
let currentSearchType = 'round'; 	// round - 왕복, oneway - 편도
let currentSelectionStep = 0; 		// 현재 선택 단계 (0: 가는편, 1: 오는편)
let selectedFlights = []; 			// 선택된 항공편 목록
let totalSegments = 2; 				// 총 선택해야 할 구간 수 (왕복: 2, 편도: 1)

let storedData = null;				// storage에 저장된 정보
let airportList = [];				// 공항 목록

const list = document.querySelector("#selectedFlightsList");	// 선택된 항공권
let currentSearchState = null;		// 현재 상태?
let loader = null;		// 인피니티 스크롤
let cabin = "";			// 탑승 정보
const result = document.querySelector('.flight-result'); // 항공권 출력란 

// session데이터 가져오기 
function restoreSearchForm() {
    const saved = sessionStorage.getItem('flightProduct');
    if (!saved) return;

    const data = JSON.parse(saved);
    console.log("data : ", data);
    
    currentSearchState = data.flights[0]; // 상태 복원
    console.log("복원 코드 : ", currentSearchState);
    
    
    currentSearchType = data.tripType || 'round';
    totalSegments = data.totalSegments || 2;
    
    document.querySelectorAll('.search-tab').forEach(t => {
        t.classList.toggle('active', t.dataset.type === currentSearchType);
    });
    document.getElementById('returnDateGroup').style.display = (currentSearchType === 'oneway') ? 'none' : 'block';

    // 2. 단계(Step) 결정 및 선택 목록 전역 변수 복원
    if (currentSearchType === 'round' && data.flights.length === 1) {
        currentSelectionStep = 1;
        selectedFlights[0] = data.flights[0]; 
        updateSelectedFlightsDisplay();       
    } else {
        // 처음 검색 폼을 복원하는 단계라면 스텝을 0으로 굳혀야 여정이 꼬이지 않습니다.
        currentSelectionStep = 0;
        selectedFlights = [];
    }
    
	// UI 필드 복원
    document.querySelector('#departure').value = currentSearchState.depAirportNm;
    document.querySelector('#depAirportId').value = currentSearchState.depAirportId;
    document.querySelector('#depIataCode').value = currentSearchState.depIata;
    document.querySelector('#destination').value = currentSearchState.arrAirportNm;
    document.querySelector('#arrAirportId').value = currentSearchState.arrAirportId;
    document.querySelector('#arrIataCode').value = currentSearchState.arrIata;
   
    updateFlightButtons();				// 버튼 텍스트 업데이트
    updateSelectionStepIndicator(); 	// 선택 단계 표시 업데이트
    
    
    if (departurePicker && departurePicker.selectedDates.length > 0) {
        const restoreDepDate = new Date(departurePicker.selectedDates[0]);
        restoreDepDate.setDate(restoreDepDate.getDate() + 1); // 가는날 다음날 계산
        
        arrivalPicker.set("minDate", restoreDepDate); // 오는날 달력의 하한선을 강제 업데이트!
    }
    
}

// 검색 타입 탭 전환
document.querySelectorAll('.search-tab').forEach(tab => {
    tab.addEventListener('click', function() {
        document.querySelectorAll('.search-tab').forEach(t => t.classList.remove('active'));
        this.classList.add('active');

        const type = this.dataset.type;
        currentSearchType = type;
 
//         resetFlightSelection();
		
        if (type === 'oneway') {
            document.getElementById('returnDateGroup').style.display = 'none';
            totalSegments = 1;
        } else {
            document.getElementById('returnDateGroup').style.display = 'block';
            totalSegments = 2;
        }

        updateFlightButtons();				// 버튼 텍스트 업데이트
        updateSelectionStepIndicator(); 	// 선택 단계 표시 업데이트
    });
});

// 버튼 텍스트 업데이트
function updateFlightButtons() {
    const buttons = document.querySelectorAll('.flight-action-btn');
    const isLastStep = (currentSelectionStep >= totalSegments - 1);
	console.log("isLastStep : ", isLastStep);
    
    buttons.forEach(btn => {
        if (currentSearchType === 'oneway') btn.textContent = '결제하기';
        else btn.textContent = isLastStep ? '결제하기' : '선택';
    });
}

// 선택 단계 표시 업데이트
function updateSelectionStepIndicator() {
    const indicator = document.getElementById('selectionStepIndicator');
    const stepText = document.getElementById('currentStepText');

    if (currentSearchType === 'oneway') {
        indicator.style.display = 'none';
        return;
    }

    indicator.style.display = 'block';

    if (currentSearchType === 'round') stepText.textContent = currentSelectionStep === 0 ? '가는편 선택' : '오는편 선택';
}

// 항공편 선택 처리 - id, data, searchData, startDate, duration, 
function selectFlight(jsonSendData) {
	const flightData = JSON.parse(jsonSendData); 
    console.log("flightData : ", flightData)
    
    selectedFlights[currentSelectionStep] = flightData;
    
    // 편도인 경우 바로 결제 페이지로 이동
    if (currentSearchType === 'oneway' || currentSelectionStep === 1) {
        goToBooking();
        return;
    } else {
	    currentSelectionStep = 1;
	    
	    // ui 업데이트
	    updateSelectedFlightsDisplay();
	    updateSelectionStepIndicator();
	    updateFlightButtons();
	    
// 	    console.log("selectFlight 에서 searchFlights() : ", searchData);
	    flightFullData = [];
	    searchFlights();
	    console.log("selectFlight 에서 searchFlights() - currentSearchData: ", currentSearchData);
		document.getElementById('flightResults').scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

// 선택한 항공편 검색 창 밑에 업데이트 
function updateSelectedFlightsDisplay() {
    const container = document.getElementById('selectedFlightsContainer');
 
    if (selectedFlights.length === 0) {
        container.style.display = 'none';
        return;
    }

    container.style.display = 'block';

    let html = '';
    let totalPrice = 0;

    selectedFlights.forEach((flight, index) => {
    	const label = currentSearchType === 'round' ? (index === 0 ? '가는편' : '오는편') : '편도';
    		
        totalPrice += parseInt(flight.price);
        html += `
        <div class="selected-flight-item">
             <div class="selected-flight-info">
                 <span class="selected-flight-label">\${label}</span>
                 <div class="selected-flight-detail">\${flight.startDate} (\${flight.domesticDays}) 
                     <span class="selected-flight-time">\${flight.depTimeFormmater} → \${flight.arrTimeFormmater}</span>
                     <span class="selected-flight-route">\${flight.depIata} → \${flight.arrIata}</span>
                 </div>
                 <span class="selected-flight-airline">\${flight.airlineNm} (\${flight.flightSymbol})</span>
 				 <i class="bi bi-luggage-fill"></i>
                 <div class="selected-flight-airline">
	 				<span> 무료 위탁 수하물 \${flight.checkedBaggage} kg<span><br/>
					<span> 기내 수하물 \${flight.carryOnBaggage} kg</span>
	 			</div>
             </div>
             <span class="selected-flight-price">\${flight.price.toLocaleString()}원</span>
        </div>`;
    });

    // 모든 구간 선택 완료 시 총 금액 및 결제 버튼 표시
    if (currentSelectionStep >= totalSegments) {
        html += `<div class="selected-flights-total">
            <div>
                <span class="total-price-label">총 금액</span>
                <span class="total-price-value ms-3">\${totalPrice}원</span>
            </div>
            <div class="btn btn-primary btn-lg" onclick="goToBooking()">
                <i class="bi bi-credit-card me-2"></i>결제하기
            </div>
        </div>`;
    }
    list.innerHTML = html;
}

// 1번째 검색한 부분으로 돌아감
function resetFlightSelection() {
    currentSelectionStep = 0;

    document.getElementById('selectedFlightsContainer').style.display = 'none';
    list.innerHTML = '';
    document.querySelector(".flight-result").innerHTML = '';
    
    updateFlightButtons();
    updateSelectionStepIndicator();
    searchFlights();
}

// 결제 페이지로 이동
function goToBooking() {
	if (!selectedFlights || selectedFlights.length === 0) return;
	
    const bookingData = {
        tripType: currentSearchType,
        totalSegments: totalSegments,
        flights: selectedFlights.map((f, index) => ({
            ...f,
            segmentIndex: index,
            segmentLabel: currentSearchType === "oneway" ? "편도" : (index === 0 ? '가는편' : '오는편')
        }))
    };
    // 항공편 데이터를 sessionStorage에 저장
    sessionStorage.setItem('flightProduct', JSON.stringify(bookingData));
    window.location.href = `/product/flight/booking`;
}

// 승객 패널 토글
function togglePassengerPanel() {
    document.getElementById('passengerPanel').classList.toggle('active');
    // 여기서 여부 바꾸고 싶은데
    // flightFullData이거 sorted 해서 renderFlightBatch
}

// 패널 외부 클릭 시 닫기
document.addEventListener('click', function(e) {
    // 일반 검색 승객 드롭다운
    const dropdown = document.querySelector('.search-form-row.mt-3 .passenger-dropdown');
    if (dropdown && !dropdown.contains(e.target)) document.getElementById('passengerPanel').classList.remove('active');
});

// 승객 수 업데이트
function updatePassenger(type, delta) {
    const newValue = passengers[type] + delta;

    if (type === 'adult' && newValue < 1) return;
    if (newValue < 0) return;
    if (newValue > 9) return;

    passengers[type] = newValue;
    document.getElementById(type + 'Count').textContent = newValue;

    // 입력 필드 업데이트
    let text = [];
    if (passengers.adult > 0) text.push('성인 ' + passengers.adult + '명');
    if (passengers.child > 0) text.push('소아 ' + passengers.child + '명');
    if (passengers.infant > 0) text.push('유아 ' + passengers.infant + '명');
    document.getElementById('passengerInput').value = text.join(', ');
}

// ==================== 인피니티 스크롤 ====================
let flightFullData = [];      // API로부터 받은 전체 항공권 데이터 저장소
let flightCurrentPage = 1;    // 현재 페이지
let flightItemsPerPage = 10;  // 한 번에 보여줄 개수
let flightIsLoading = false;  // 로딩 중복 방지 플래그
let flightHasMore = false;    // 더 가져올 데이터가 있는지 여부
let currentSearchData = null; // 검색 조건 저장 (카드 생성용)

// 인피니티 스크롤 초기화
function initFlightInfiniteScroll() {
    if (!loader) return;

    // loader가 돌아가는 순간 실행 하는 객체 intersection
    const observer = new IntersectionObserver((entries) => {
    	// 0으로 지정한 것 loader가 들어오는 순간 스크롤 가동
    	if (entries[0].isIntersecting && !flightIsLoading && flightHasMore) {
            flightIsLoading = true;

            setTimeout(() => {
                flightCurrentPage++;
                renderFlightBatch(); // 10개씩 그리는 함수 호출
                console.log("flightIsLoading : ", flightIsLoading);
            }, 1000);
        }
    }, {
        root: null,
        rootMargin: '100px', // 보이기 100px 전에 미리 호출하여 부드러운 연결
        threshold: 0
    });

    observer.observe(loader);	// 로딩바 조회
}

// 항공권 생성 카드 호출
function renderFlightBatch(){
    flightIsLoading = true;
	
    const start = (flightCurrentPage - 1) * flightItemsPerPage;	// 처음에는 0
    const end = start + flightItemsPerPage;						// 처음에는 10
    const batch = flightFullData.slice(start, end);				// 10개
    
    let html = '';

    console.log("renderFlightBatch - currentSearchData : ", currentSearchData);
    
    batch.forEach((item, i) => {
        html += createFlightCard(item, currentSearchData, cabin, start + i);
    });
    
    result.insertAdjacentHTML('beforeend', html);
    setTimeout(() => { flightIsLoading = false }, 2000);
    
    
    if (end >= flightFullData.length) {
        flightHasMore = false;
        loader.style.display = 'none';
        document.getElementById('flightScrollEnd').style.display = 'block';
    } else {
        flightHasMore = true;
        loader.style.display = 'flex';
        document.getElementById('flightScrollEnd').style.display = 'none';
    }
}

// 조건에 맞는 항공권 카드 생성
function createFlightCard(data, searchData, cabin, id) {
	
	console.log("createFlightCard의 searchDate : ", searchData)
	
	// 버튼 텍스트 결정
    let isLastStep = (currentSelectionStep >= totalSegments - 1);
    let buttonText = (currentSearchType === 'oneway' || isLastStep) ? '결제하기' : '선택';
	
    // 시간
    let startDate = searchData.startDt.substring(0, 4) + "년 " + searchData.startDt.substring(4, 6) + "월 " + searchData.startDt.substring(6, 8) + "일 "; 
	
	// 출발 시간 가져오기
	let timeFormmater = durationFormmater(data.depTime, data.arrTime, "timeFormmater").split("split");
	let depTimeFormmater = timeFormmater[0];
	let arrTimeFormmater = timeFormmater[1];
	
	// 소요시간 가져오기
	let timeSet = durationFormmater(data.depTime, data.arrTime, "duration"); 
	let duration = parseInt(timeSet / 60) + "시간 " + (timeSet % 60 === 0 ? "" : (timeSet % 60) + "분"); 
	
	let price = cabin === "economy" ? data.economyCharge : data.prestigeCharge;
	let pirceFormat = price.toLocaleString(); 
	
	const sendData = {
		...data,
		...searchData,
		id : id,	
		startDate : startDate,
		duration : duration,
		step: currentSelectionStep,		// 숫자 낮은것 부터 insert
	    adult : passengers.adult,		
	    child : passengers.child,
	    infant : passengers.infant,
	    cabinClass : cabin === "economy" ? "일반석" : "비즈니스",
	    price : price,					// 가격 세팅 1개 가격
	    depTimeFormmater : depTimeFormmater,
	    arrTimeFormmater : arrTimeFormmater
	};
	
	console.log("출발 공항 : ", searchData.depAirportNm);
	
	const jsonSendData = JSON.stringify(sendData).replace(/"/g, '&quot;');
	
    return `<div class="flight-card" data-flight-id="\${id}">
        <div class="flight-card-content">
            <div class="flight-info">
                <div class="flight-time">
                    <div class="time">\${depTimeFormmater}</div>
                    <div class="airport">\${searchData.depAirportNm}</div>
                </div>
            </div>
            <div class="flight-duration">
                <div class="duration-text">\${duration}</div>
                <div class="duration-line">
                    <i class="bi bi-airplane"></i>
                </div>
                <div class="flight-airline">\${data.airlineNm} \${data.flightSymbol}</div>
            </div>
            <div class="flight-info">
                <div class="flight-time">
                    <div class="time">\${arrTimeFormmater}</div>
                    <div class="airport">\${searchData.arrAirportNm}</div>
                </div>
            </div>
            <div class="flight-baggage">
				<i class="bi bi-luggage-fill"></i><span>\${data.checkedBaggage} kg</span>
			</div>
            <div class="flight-price">
                <div class="price">\${pirceFormat}<span class="price-unit">원</span></div>
                <button type="button" class="btn btn-primary btn-sm flight-action-btn" 
                    onclick="selectFlight('\${jsonSendData}')">
                    \${buttonText}
                </button>
            </div>
        </div>
    </div>`;
}

// 도착지는 출발지와 같을수 없음 필터 - 설정
document.querySelector('#destination').addEventListener("click", function(e){
	let dp = document.querySelector('#departure').value;
	let ds = document.querySelector('#destination').value;
	if(dp === ds){
		// 같은 것 삭제
		document.querySelector('#returnDate').value = "";
		showToast('도착지는 출발지와 같을 수 없습니다.', 'error');
	}
});

let departurePicker;
let arrivalPicker;
// 달력 보여주기위한 설정
function dateChange(){
    // 1. 세션 스토리지에서 기존 검색 데이터 가져오기
    const savedProduct = sessionStorage.getItem('flightProduct');
    const savedData = savedProduct ? JSON.parse(savedProduct) : null;
    
    // 2. 가는날, 오는날 데이터가 있는지 확인하고 YYYY-MM-DD 포맷으로 가공
    const savedDepDate = savedData?.flights?.[0]?.startDt?.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3') || null;
    let savedArrDate = savedData?.flights?.[1]?.startDt?.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3') || null;

    // 오는날이 가는날보다 같거나 빠르면 데이터 무효화
    if (savedDepDate && savedArrDate && new Date(savedArrDate) <= new Date(savedDepDate)) {
        savedArrDate = null; 
    }
    
 	// 초기 minDate 설정: 가는날 복원 데이터가 있으면 '가는날+1일', 없으면 '오늘'
    let initialMinArrival = "today";
    if (savedDepDate) {
        const nextDay = new Date(savedDepDate);
        nextDay.setDate(nextDay.getDate() + 1);
        initialMinArrival = nextDay;
    }
    
    // 오는날 달력 설정
	arrivalPicker = flatpickr("#returnDate", {
		dateFormat: "Y-m-d",
        minDate: "today",
        locale: "ko",
        defaultDate: savedArrDate 
	});
	
    // 가는날 달력 설정
	departurePicker = flatpickr("#departDate", {
	    dateFormat: "Y-m-d",
	    minDate: "today", 
	    locale: "ko",
        defaultDate: savedDepDate, 
	    onChange: function(selectedDates) {
            if (selectedDates.length > 0) {
            	const nextDay = new Date(selectedDates[0]);
                nextDay.setDate(nextDay.getDate() + 1);
                
                if (arrivalPicker.selectedDates[0] && +arrivalPicker.selectedDates[0] < +nextDay) {
                    showToast('오는날은 가는날 이후여야 합니다.', 'error');
                    arrivalPicker.clear();
                    arrivalPicker.open();
                }
                arrivalPicker.set("minDate", nextDay);	
            }
        }
	});
}

// 검색 폼 제출 (1번만 함)
document.getElementById('flightSearchForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    // 초기화
   	currentSelectionStep = 0;
   	
   	updateFlightButtons();
 	updateSelectionStepIndicator();
   	selectedFlights = [];	// 검색 한번해서 
   	updateSelectedFlightsDisplay();		// 선택된 거 없애줌
    searchFlights();
});

// 항공권 조회
// async function searchFlights() {
function searchFlights() {
	
    result.innerHTML = ``;
    const searchCount = document.querySelector(".results-count");
    searchCount.innerHTML = ``;
    
    const activeTab = document.querySelector('.search-tab.active');
    const searchType = activeTab ? activeTab.dataset.type : 'round';	// 왕복, 편도
    
    const departure = document.querySelector('#departure').value;
    const destination = document.querySelector('#destination').value;
    const depAirportId = document.querySelector('#depAirportId').value;
    const arrAirportId = document.querySelector('#arrAirportId').value;
    const depIata = document.querySelector('#depIataCode').value;
    const arrIata = document.querySelector('#arrIataCode').value;
	const startDt = document.querySelector('#departDate').value;
    const endDt = document.querySelector('#returnDate').value;
	
    cabin = document.querySelector("#cabinClass").value;	// 좌석 등급
    
    const activeSortBtn = document.querySelector('.sort-btn.active');
    const sorted = activeSortBtn ? activeSortBtn.dataset.sort : 'departure';
    
    if (!departure) {
        showToast('출발지를 입력해주세요.', 'error');
        return;
    }
    
    if (!destination) {
        showToast('도착지를 입력해주세요.', 'error');
        return;
    }
    
    if(!startDt){
    	showToast('가는날을 입력해주세요.', 'error');
    	return;
    }
    
    if(currentSearchType === 'round' && !endDt){
    	showToast('오는날을 입력해주세요.', 'error');
    	return;
    }
    
	// 출발시간 = vo에 매칭할 정보
    const searchData = {
    	type : searchType,
    	depAirportNm : (currentSelectionStep === 0) ? departure : destination, 		// 출발지
    	depAirportId : (currentSelectionStep === 0) ? depAirportId : arrAirportId,	// 출발지 코드
    	depIata : (currentSelectionStep === 0) ? depIata : arrIata,					// 출발지 3글자 코드
    	startDt : (currentSelectionStep === 0) ? startDt.replaceAll("-", "") : endDt.replaceAll("-", ""), 	// 뭔가 조건 걸기
    	arrAirportNm : (currentSelectionStep === 0) ? destination : departure, 		// 도착지  
    	arrAirportId : (currentSelectionStep === 0) ? arrAirportId : depAirportId,	// 도착지 코드
    	arrIata : (currentSelectionStep === 0) ? arrIata : depIata,					// 도착지 3글자 코드
		cabin : cabin		// 중복되지만 일단 넣자
    }
    
// 	console.log("searchFlights() - searchData : ", searchData);
	
    if (loader) {
        loader.style.display = 'flex'; // 로더 노출
        document.getElementById('flightScrollEnd').style.display = 'none'; // '마지막' 메시지 숨김
    }
	
    // 왕복/편도 검색
    showToast('항공편을 검색하고 있습니다...', 'info');
    
    axios.post(`/product/flight/searchFlight`, searchData
    ).then(res => {
    	const flight = res.data;	// 데이터 조회
    	console.log("axios : ", flight);
    	
    	if (!flight || flight.length === 0) {	// 데이터 없을때
            result.innerHTML = `<div class="no-results-msg">조회된 조건에 맞는 항공편이 없습니다.</div>`;
            flightHasMore = false;
            return;
        }
    	
    	// 가격 없는것, 항공편명 없는것, 이미 출발할 항공권 필터
    	const filteredFlight = flight.filter(item => 
            item.airlineNm && item.airlineNm !== '/' && timeCheck(item.depTime) && (item.economyCharge !== 0)
        );
    	
    	// 필터 된 데이터 없을시 출력할 메시지
    	if (filteredFlight.length === 0) {
            result.innerHTML = `<div class="no-results-msg">조회된 조건에 맞는 항공편이 없습니다.</div>`;
            flightHasMore = false;
            if (loader) loader.style.display = 'none';
            return;
        }
    	
    	// 금액 sorting
    	if(sorted === "price") filteredFlight.sort((a, b) => a.economyCharge - b.economyCharge);
    	
    	// 소요시간 sorting
    	if(sorted === "duration") {
    		filteredFlight.sort((a, b) => durationFormmater(a.depTime, a.arrTime, "duration") - durationFormmater(b.depTime, b.arrTime, "duration"));
    	}
    	
    	// 인핀니티 적용
		flightFullData = filteredFlight; // 인피니티 배열에 담기
        currentSearchData = searchData;
        flightHasMore = flightFullData.length > flightItemsPerPage;	// 인피니티 배열이 10개보다 커야지 의미있음
        flightCurrentPage = 1;
        renderFlightBatch();	// 랜더링
        searchCount.innerHTML = `<strong>\${searchData.depAirportNm} (\${searchData.depIata})</strong> → <strong>\${searchData.arrAirportNm} (\${searchData.arrIata})</strong> 검색 결과 <strong>\${filteredFlight.length}</strong>개`;
    })
    .catch(error => {
    	console.log("error 발생 : ", error);
  		flightHasMore = false;
    });
}

// 출발 시간이 이미 지난시간인지 확인
function timeCheck(time){
	const year = parseInt(time.substring(0, 4));
	const month = parseInt(time.substring(4, 6));
	const day = parseInt(time.substring(6, 8));
	const hour = parseInt(time.substring(9, 11));
	const minute = parseInt(time.substring(12, 14));
	
	const targetDate = new Date(year, month - 1, day, hour, minute);
	
	const now = new Date();
	return targetDate > now ? true : false;	// 지난 시간
}

// 소요시간 가져오기
function durationFormmater(depTime, arrTime, indentifer) {
	
	let depTimeSet = depTime.split(" ");	// 날짜 시간 분리
	let arrTimeSet = arrTime.split(" ");
	
	let depAp = depTimeSet[1].split(":");	// 시 분 분리	
	let arrAp = arrTimeSet[1].split(":");
	
	let depTimeFormmater = parseInt(depAp[0]) > 12
			? "오후 " + (parseInt(depAp[0]) - 12) + ":" + depAp[1]
			: "오전 " + depTimeSet[1];
	let arrTimeFormmater = parseInt(arrAp[0]) > 12 
			? "오후 " + (parseInt(arrAp[0]) - 12) + ":" + arrAp[1]
			: "오전 " + arrTimeSet[1];
	
	if(indentifer === "duration") {
		return (parseInt(arrAp[0] * 60) + parseInt(arrAp[1])) - (parseInt(depAp[0] * 60) + parseInt(depAp[1]));
	}

	else return depTimeFormmater + "split" + arrTimeFormmater;	//	split으로 분리	
}

// 출발지, 도착지 검색
function showSegmentAutocomplete(dropdown, query) {

	// 중복 방지
	const checkData = (dropdown.id === 'departureDropdown') ? 
	document.querySelector('#destination').value : document.querySelector('#departure').value;
	
	const filteredAirportList = airportList.filter(airport => {
		const isMatch = airport.airportNm.includes(query) || airport.cityName.includes(query) ;
	    const isNotDuplicate = airport.airportNm !== checkData;
	    return isMatch && isNotDuplicate;
	});
	
    let html = '';
    if(filteredAirportList.length > 0){
        html += filteredAirportList.map(function(airport) {
            return createAutocompleteItemHtml(airport, query);
        }).join('');
    } else html = `<div class="autocomplete-empty"><i class="bi bi-search"></i>\${query}에 대한 검색 결과가 없습니다.</div>`;

    dropdown.innerHTML = html;
    dropdown.classList.add('active');
    
    // 클릭 이벤트 바인딩
    dropdown.querySelectorAll('.autocomplete-item').forEach((item) => {
        item.addEventListener('click', function() {
        	selectAirportItem(this, dropdown);
        });
    });
}

// 출발지 도착지 선택
function selectAirportItem(item, dropdown) {
    const input = dropdown.previousElementSibling;
    const parent = input.closest('.form-group');
    
    input.value = item.dataset.name;
    
    const idInput = parent.querySelector('input[name*="AirportId"]');	// hidden태그에 값 입력
    const iataInput = parent.querySelector('input[name*="IataCode"]');	// hidden태그에 값 입력
    
    if (idInput) idInput.value = item.dataset.id;
    if (iataInput) iataInput.value = item.dataset.code;
    dropdown.classList.remove('active');
}

// 자동완성 아이템 HTML 생성 -> 검색창에 들어갈 데이터 입력
function createAutocompleteItemHtml(location, query) {
    const highlightedName = query ? location.airportNm.replace(new RegExp('(' + query + ')', 'gi'), '<mark>$1</mark>') : location.airportNm;
    
    return `<div class="autocomplete-item" data-name="\${location.airportNm}" data-code="\${location.iataCode}" data-id="\${location.airportId}">
				<div class="autocomplete-item-icon"><i class="bi-geo-alt"></i></div>
		  		<div class="autocomplete-item-info">
			  		<div class="autocomplete-item-name">\${highlightedName}</div>
			    	<div class="autocomplete-item-sub">\${location.cityName}</div>
		    	</div>
	    	</div>`;

}

function renderStoredData(storedData) {
	console.log("storedData : ", storedData);
}

document.addEventListener('DOMContentLoaded', function() {

	airportList = JSON.parse('${airportList}');	// 공항 목록 받은 것
    loader = document.querySelector("#flightScrollLoader");	// 인피니티 스크롤 객체
    initFlightInfiniteScroll();
	
    const autoInputs = document.querySelectorAll('.airport-autocomplete');
    autoInputs.forEach(input => {
        const dropdown = input.nextElementSibling; // 바로 뒤에 있는 .autocomplete-dropdown

        // 1. 글자를 입력할 때 실행
        input.addEventListener('input', function() {
            showSegmentAutocomplete(dropdown, this.value.trim());
        });

        // 2. 입력창을 클릭(포커스)했을 때 실행
        input.addEventListener('focus', function() {
            showSegmentAutocomplete(dropdown, this.value.trim());
        });
    });
    
	// 정렬
    document.querySelectorAll('.sort-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.sort-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
        });
    });
    
    dateChange();	// 달력 설정
    restoreSearchForm();
});
</script>

<%@ include file="../common/footer.jsp"%>