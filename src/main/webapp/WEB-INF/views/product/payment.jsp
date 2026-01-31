<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="pageTitle" value="결제 완료" />
<c:set var="pageCss" value="product" />

<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/product.css">

<sec:authorize access="isAuthenticated()">
    <sec:authentication property="principal" var="user" />
</sec:authorize>

<div class="booking-page">
    <div class="container">
        <!-- 결제 단계 -->
        <div class="booking-steps">
            <div class="booking-step completed">
                <div class="step-icon"><i class="bi bi-check"></i></div>
                <span>결제 정보</span>
            </div>
            <div class="booking-step completed">
                <div class="step-icon"><i class="bi bi-check"></i></div>
                <span>결제</span>
            </div>
            <div class="booking-step">
                <div class="step-icon">3</div>
                <span>완료</span>
            </div>
        </div>
		
		<c:set var="error" value="${error}" />
		
		<c:if test="${empty error }">
			<input type="hidden" id="paymentType" value="${paymentType }"/>	
			<input type="hidden" id="orderId" value="${orderId }"/>	
			<input type="hidden" id="paymentKey" value="${paymentKey }"/>	
			<input type="hidden" id="amount" value="${amount }"/>	
			<input type="hidden" id="productType" value="${productType}"/>
		</c:if>
		
		<div id="payment-loading" class="text-center py-5">
            <div class="spinner-border text-primary"></div>
            <p>결제 승인 요청 중...</p>
        </div>
		
        <!-- 결제 완료 -->
        <c:if test="${empty error}">
		    <div class="payment-complete" style="display: none">
		        <div class="complete-header">
		            <div class="complete-icon">
		                <i class="bi bi-check-lg"></i>
		            </div>
		            <h1 class="complete-title">결제가 완료되었습니다!</h1>
		            <p class="complete-message">
		                결제 확인 메일이 <strong id="memEmail" class="text-teal">이메일</strong>으로 발송되었습니다.<br>
		                모행과 함께 즐거운 여행 되세요!
		            </p>
		        </div>
		
		        <div class="complete-details-card">
		            <div class="receipt-top-line"></div>
		            <h4>결제 상세 내역</h4>
		            <div class="detail-rows">
		                <div class="detail-row">
		                    <span class="label">결제번호</span>
		                    <span class="value" id="payNo"></span>
		                </div>
		                <div class="detail-row">
		                    <span class="label">상품명</span>
		                    <span class="value" id="orderName"></span>
		                </div>
		                <div class="detail-row">
		                    <span class="label">이용일시</span>
		                    <span class="value" id="payDt"></span>
		                </div>
		                <div class="detail-row">
		                    <span class="label">인원 구성</span>
		                    <span class="value" id="person"></span>
		                </div>
		                <div class="detail-row">
		                    <span class="label">결제수단</span>
		                    <span class="value" id="method"></span>
		                </div>
		                <div class="receipt-divider"></div>
		                <div class="detail-row total-row">
		                    <span class="label">최종 결제금액</span>
		                    <span class="value"><strong id="totalAmount"></strong>원</span>
		                </div>
		            </div>
		        </div>

<!--        상품 결제시
		    <div class="alert alert-warning mb-4">
                <i class="bi bi-exclamation-triangle me-2"></i>
                <strong>이용 안내</strong>
                <ul class="mb-0 mt-2 ps-3">
                    <li>예약 시간 10분 전까지 현장에 도착해주세요.</li>
                    <li>수영복, 타월을 지참해주세요.</li>
                    <li>기상 악화 시 일정이 변경될 수 있습니다.</li>
                </ul>
            </div> -->

            <div class="complete-actions text-center">
	            <a href="${pageContext.request.contextPath}/mypage/payments/list" class="btn btn-outline btn-lg">
	                <i class="bi bi-receipt me-2"></i>결제 내역 보기
	            </a>
	            <a href="${pageContext.request.contextPath}/" class="btn btn-primary btn-lg">
	                <i class="bi bi-house me-2"></i>홈으로
	            </a>
	        </div>
	    </div>
        
    	<!--  결제 실패 시 구간 만들기 -->
		<div class="payment-fail" style="display: none">
	        <div class="complete-icon fail">
	            <i class="bi bi-exclamation-circle"></i>
	        </div>
	        <h1 class="fail-title">결제에 실패하였습니다</h1>
	        <p class="fail-message text-danger"></p>
	        
	        <div class="fail-details-card">
	            <div class="detail-row">
	                <span class="label">실패 사유</span>
	                <span class="value text-danger" id="failReason">네트워크 오류 또는 잔액 부족</span>
	            </div>
	            <div class="detail-row">
	                <span class="label">주문 번호</span>
	                <span class="value" id="orderFailName"></span>
	            </div>
	        </div>
	        
	        <div class="complete-actions">
	            <button onclick="history.back()" class="btn btn-outline-secondary btn-lg">
	                <i class="bi bi-arrow-left me-2"></i>다시 시도하기
	            </button>
	        </div>
	    </div>
	</c:if>
		
		
		<!-- 서버 접근도 못했을때 -->
		<c:if test="${not empty error }">
		<div class="payment-fail">
            <div class="complete-icon fail"> <i class="bi bi-exclamation-circle"></i> </div>
            <h1 class="fail-title">결제가 실패되었습니다</h1>
            <hr/>
            <p class="fail-message">${message }</p>
			<div class="fail-details">
				<div detail-row>
					<span class="label">결제 상태</span>
					<span class="value" id="failCode">${code }</span>
				</div>
				<div detail-row>
					<span class="label">상품명</span>
					<span class="value" id="orderName">${orderId}</span>
				</div>
			</div>
		</div>
		</c:if>
		
    </div>
</div>


<script>
let loading = null;

let paymentKey = null;
let orderId = null;
let amount = 0;
let paymentType = null;
let productType = null;

// 예약 세션 스토리지 가져올 객체 
let storedData = null;

let flightProduct = null;	// 항공 product storage
let passengers = null;

document.addEventListener("DOMContentLoaded", async function(){
	// api용
	paymentKey = document.querySelector("#paymentKey");
	orderId = document.querySelector("#orderId");
	amount = document.querySelector("#amount");
	paymentType = document.querySelector("#paymentType");
	productType = document.querySelector("#productType");
	loading = document.querySelector("#payment-loading");
	
	// db에 넣을 정보
	flightProduct = sessionStorage.getItem("flightProduct");
	passengers = sessionStorage.getItem("passengers");
	reservationList = sessionStorage.getItem("reservationList");
	reserveAgree = sessionStorage.getItem("reserveAgree");
	console.log("flightProduct : ", flightProduct);
	console.log("passengers : ", passengers);
	console.log("reservationList : ", reservationList);
	console.log("reserveAgree : ", reserveAgree);
	
	let payNo = document.querySelector("#payNo");
	let orderName = document.querySelector("#orderName");
	let payDt = document.querySelector("#payDt");
	let person = document.querySelector("#person");
	let totalAmount = document.querySelector("#totalAmount");
	let method = document.querySelector("#method");
	let memEmail = document.querySelector("#memEmail");

	let message = document.querySelector(".fail-message");	// 결제 실패시 보여줄 부분
	
	if('${error}' != "error"){
		console.log("user.username : ", "${user.username}");
		const userData = await fetch("/product/flight/user", {
			method : "post",
			headers : {"Content-Type" : "application/json"},
			body : JSON.stringify({memId : "${user.username}"})
		});
		
		console.log("userData : ", userData);
		const customData = await userData.json();
		console.log("customData : ", customData);
		
	    memEmail.innerHTML = customData.memEmail;	// 결제자 이메일 정보 
	    
		// 상품 타입 분기
		const pType = productType ? productType.value : "flight";

		if (pType === "tour") {
			// 투어 상품 결제
			await processTourPayment(customData, payNo, orderName, payDt, person, totalAmount, method, message);
		} else if (pType === "accommodation") {
			// 숙박 상품 결제
		    await processAccommodationPayment(customData, payNo, orderName, payDt, person, totalAmount, method, message);
		} else {
			if(flightProduct) flightProduct = JSON.parse(flightProduct); 
			
			if(passengers) passengers = JSON.parse(passengers);
			
			if(reservationList) reservationList = JSON.parse(reservationList);
			
			if(reserveAgree) reserveAgree = JSON.parse(reserveAgree);
			
			const requestData = {
		        paymentKey: paymentKey.value,
		        orderId: orderId.value,
		        amount: amount.value,
		        paymentType : paymentType.value,
		        memNo : customData.memNo,
		        flightProductList : flightProduct != null ? flightProduct.flights : null,
		        flightPassengersList : passengers != null ? passengers : null,
	       		flightReservationList : reservationList != null ? reservationList : null,
	       		flightResvAgree : reserveAgree != null ? reserveAgree : null,
	    		productType : "flight"
		    };
			
			console.log("requestData ", requestData);
			
			const response = await fetch("/product/payment/confirm", {
				method : "post",
				headers : {"Content-Type" : "application/json"},
				body : JSON.stringify(requestData)
			});
			
			console.log("response : ", response);
			
		    const resultData = await response.json(); 
			if (response.ok) {
				if (resultData.approvedAt && resultData.payNo) {
			        // 우리만의 규격: 2026012900001234 처럼 바뀜!
			        payNo.innerHTML = formatPayNo(resultData.approvedAt, resultData.payNo);
			    } else {
			        // 만약 payNo가 안 넘어오면 백업용으로 기존꺼라도 보여줌
			        payNo.innerHTML = resultData.orderId;
			    }

			    orderName.innerHTML = resultData.orderName;

			    // 2. 승인 시간 포맷팅 (Intl.DateTimeFormat 사용)
			    const date = new Date(resultData.approvedAt);
			    const formattedDate = new Intl.DateTimeFormat('ko-KR', {
			        year: 'numeric',
			        month: 'long',
			        day: 'numeric',
			        weekday: 'long',
			        hour: '2-digit',
			        minute: '2-digit',
			        hour12: true
			    }).format(date);

			    console.log(formattedDate);
			    payDt.innerHTML = formattedDate;
			    
			    // 3. 탑승 인원 정보 구성
			    let personParts = [];
			    if (resultData.adult) personParts.push(resultData.adult);
			    if (resultData.child) personParts.push(resultData.child);
			    if (resultData.infant) personParts.push(resultData.infant);

			    let personCount = personParts.join(", ");
			    person.innerHTML = personCount;
			    
			    // 4. 결제 금액 및 수단
			    totalAmount.innerHTML = (resultData.totalAmount).toLocaleString();
			    
			    if (resultData.method == '간편결제'){
			        method.innerHTML = resultData.easyPay.provider;
			    } else{
			        method.innerHTML = resultData.method;
			    }

			    // 5. 화면 전환 및 항공 관련 세션 삭제
			    document.querySelector(".payment-complete").style.display = "block";
			    completed3Step();
			    
			    sessionStorage.removeItem("flightProduct");
			    sessionStorage.removeItem("passengers");
			    sessionStorage.removeItem("reservationList");
			    sessionStorage.removeItem("reserveAgree");
			    sessionStorage.removeItem("@tosspayments/session-id");
			    
			    console.log("✈️ 항공 예약 완료 - 예약번호: " + payNo.innerHTML);
			} else {
				try {
				    const msgSplit = resultData.message.split(': "');
				    const jsonStr = msgSplit[msgSplit.length - 1].replace(/"$/, ''); // 마지막 따옴표 제거
	
				    const errorDetail = JSON.parse(jsonStr);
	
				    console.log("에러 메세지:", errorDetail.message);  // 이미 처리된 결제 입니다.
					message.innerHTML = errorDetail.message;
					document.querySelector("#orderFailName").innerHTML = orderId.value;		// 주문 번호
				    
	// 			    console.log("에러 코드:", errorDetail.code);       // ALREADY_PROCESSED_PAYMENT
	// 				failCode.innerHTML = errorDetail.code; // 에러 코드
					document.querySelector(".payment-fail").style.display = "block";
	// 				document.querySelector(".payment-complete").style.display = "none";
				} catch (e) {
				    console.error("파싱 실패:", e);
				}
				console.log("resultData : ", resultData);
				console.log("resultData.message : ", resultData);
			}
		}
		
		loading.style.display = "none";
		
	}else{
		console.log("error 발생");
		console.log('${error}', '${code}');
		loading.style.display = "none";
	}
});

// 투어 상품 결제
async function processTourPayment(customData, payNo, orderName, payDt, person, totalAmount, method, message) {
	let tourPaymentData = sessionStorage.getItem("tourPaymentData");
	tourPaymentData = JSON.parse(tourPaymentData);
	console.log("tourPaymentData:", tourPaymentData);
	
	const requestData = {
		paymentKey: paymentKey.value,
		orderId: orderId.value,
		amount: amount.value,
		paymentType: paymentType.value,
		productType: "tour",
		memNo: customData.memNo,
		usePoint: tourPaymentData.usePoint || 0,
		tripProdList: tourPaymentData.tripProdList,
		mktAgreeYn: tourPaymentData.mktAgreeYn
	};
	
	console.log("투어 결제 요청 데이터:", requestData);
	
	try {
		const response = await fetch("/product/payment/confirm", {
			method: "post",
			headers: {"Content-Type": "application/json"},
			body: JSON.stringify(requestData)
		});
		
		const resultData = await response.json();
		
		if (response.ok) {
			console.log("투어 결제 승인 성공:", resultData);
			
			payNo.innerHTML = formatPayNo(resultData.approvedAt, resultData.payNo);
			orderName.innerHTML = resultData.orderName;
			
			// 이용 예정일
		    const resvDt = tourPaymentData.tripProdList[0].resvDt;
		    const useTime = tourPaymentData.tripProdList[0].useTime;
		    payDt.innerHTML = resvDt + " " + useTime;
		    
		    person.innerHTML = tourPaymentData.tripProdList[0].quantity + "명";
		    totalAmount.innerHTML = resultData.totalAmount.toLocaleString();
		    
		    if (resultData.method === '간편결제') {
		        method.innerHTML = resultData.easyPay.provider;
		    } else {
		        method.innerHTML = resultData.method;
		    }
		    
		    document.querySelector(".payment-complete").style.display = "block";
		    completed3Step();
		    
		    sessionStorage.removeItem("tourPaymentData");
		    sessionStorage.removeItem("tourCart");
		    sessionStorage.removeItem("tourCartCheckout");
		    sessionStorage.removeItem("@tosspayments/session-id");
		} else {
			if (resultData.success === false && resultData.message) {
		        message.innerHTML = resultData.message;
		    } else {
		        // 토스페이먼츠 API 에러
		        try {
		            const msgSplit = resultData.message.split(': "');
		            const jsonStr = msgSplit[msgSplit.length - 1].replace(/"$/, '');
		            const errorDetail = JSON.parse(jsonStr);
		            message.innerHTML = errorDetail.message;
		        } catch (e) {
		            console.error("파싱 실패:", e);
		            message.innerHTML = "결제 처리 중 오류가 발생했습니다.";
		        }
		    }
		    
		    document.querySelector("#orderFailName").innerHTML = orderId.value;
		    document.querySelector(".payment-fail").style.display = "block";
		}
	} catch (error) {
		console.error("결제 처리 오류:", error);
		message.innerHTML = "결제 처리 중 오류가 발생했습니다.";
		document.querySelector(".payment-fail").style.display = "block";
	}
}

// ------- 숙박 상품 결제 -------
async function processAccommodationPayment(customData, payNo, orderName, payDt, person, totalAmount, method, message) {
  try{
	let pendingBooking = JSON.parse(sessionStorage.getItem("pendingBooking"));
    
    console.log("숙소 대기 데이터:", pendingBooking);
    
    pendingBooking.resvMemNo = customData.memNo;
    
    const requestData = {
        paymentKey: paymentKey.value,
        orderId: orderId.value,
        amount: amount.value,
        paymentType: paymentType.value,
        productType: "accommodation",
        memNo: customData.memNo,
        accResvVO: pendingBooking 
    };

    const response = await fetch("/product/payment/confirm", {
        method: "post",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(requestData)
    });
    
    const resultData = await response.json();
    
    if (response.ok) {
        // UI 업데이트
	    	if (resultData.approvedAt && resultData.payNo) {
	            payNo.innerText = formatPayNo(resultData.approvedAt, resultData.payNo);
	        } else {
	            payNo.innerText = resultData.orderId || ""; 
	        }
	
	        // 2. 상품명 업데이트
	        orderName.innerText = resultData.orderName || "";
	        
	        // 3. 인원 구성: 성인/아동/유아 문자열 합치기
	        if (resultData.guestInfo) {
	            person.innerHTML = resultData.guestInfo; 
	        } else {
	            var adult = pendingBooking.adultCnt || 0;
	            var child = pendingBooking.childCnt || 0;
	            var infant = pendingBooking.infantCnt || 0;
	            
	            // JSP/옛날 브라우저에서도 안전하게 문자열 연결 (+) 사용
	            var guestText = "성인 " + adult + "명";
	            if (child > 0) guestText += ", 아동 " + child + "명";
	            if (infant > 0) guestText += ", 유아 " + infant + "명";
	            person.innerHTML = guestText;
	        }
	        
	        // 4. 이용 기간 (체크인 ~ 체크아웃)
	        payDt.innerHTML = pendingBooking.startDt + " ~ " + pendingBooking.endDt;
	        
	        // 5. 금액 포맷팅 (천단위 콤마)
	        totalAmount.innerHTML = resultData.totalAmount.toLocaleString();
	        
	        // 6. 결제 수단: 간편결제 여부에 따른 분기
	        if (resultData.method === '간편결제') {
	            method.innerHTML = resultData.easyPay.provider;
	        } else {
	            method.innerHTML = resultData.method;
	        }
	        
	        // 7. 화면 전환 및 세션 정리
	        document.querySelector(".payment-complete").style.display = "block";
	        sessionStorage.removeItem("pendingBooking"); 
	        
	        completed3Step();
	        
	        console.log("🏨 숙박 예약 완료 - 주문번호: " + payNo.innerText);
	    }
    } catch (error) {
        console.error("결제 프로세스 에러:", error);
        document.querySelector(".payment-fail").style.display = "block";
    }
    
}

function formatPayNo(dateStr, payNo) {
    // dateStr: "2026-01-24T14:30:52" 형식
    var date = new Date(dateStr);
    var datePart = date.getFullYear() +
                   String(date.getMonth() + 1).padStart(2, '0') +
                   String(date.getDate()).padStart(2, '0');
    var payNoPart = String(payNo).padStart(8, '0');
    return datePart + payNoPart;
}

function completed3Step() {
	let completedTag = document.querySelectorAll(".booking-step")[2];
	// 1. class 추가 (classList.add 사용)
	completedTag.classList.add("completed");
	
	// 2. 내부 HTML 교체
	completedTag.innerHTML = `
		<div class="step-icon">
			<i class="bi bi-check"></i>
		</div>
		<span>완료</span>
	`;
}
</script>

<%-- <c:set var="pageJs" value="product" /> --%>
<%@ include file="../common/footer.jsp" %>