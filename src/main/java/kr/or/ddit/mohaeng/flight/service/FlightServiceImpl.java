package kr.or.ddit.mohaeng.flight.service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.DefaultUriBuilderFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import kr.or.ddit.mohaeng.flight.mapper.IFlightMapper;
import kr.or.ddit.mohaeng.vo.AirlineVO;
import kr.or.ddit.mohaeng.vo.AirportVO;
import kr.or.ddit.mohaeng.vo.FlightProductVO;
import kr.or.ddit.mohaeng.vo.MemberVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class FlightServiceImpl implements IFlightService {

	@Autowired
	private IFlightMapper flightMapper;

	// api 서비스키
	@Value("${flight.api.key}")
	private String serviceKey;

	@Value("${flight.api.base}")
	private String baseUrl;
	
	@Override
	public List<AirportVO> getAirportList() {
		return flightMapper.getAirportList();
	}

	@Override
	public List<AirlineVO> getAirlineList() {
		return flightMapper.getAirlineList();
	}

	@Override
	public List<FlightProductVO> getFlightList(FlightProductVO flightProduct) {
		List<FlightProductVO> flightProductList = new ArrayList<>();

		try {

			StringBuilder urlBuilder = new StringBuilder(baseUrl);
			urlBuilder.append("?serviceKey=" + serviceKey);
			urlBuilder.append("&_type=json");
			urlBuilder.append("&pageNo=" + flightProduct.getPageNo());
			urlBuilder.append("&numOfRows=" + flightProduct.getNumOfRows());
			urlBuilder.append("&depAirportId=" + flightProduct.getDepAirportId());
			urlBuilder.append("&arrAirportId=" + flightProduct.getArrAirportId());
			urlBuilder.append("&depPlandTime=" + flightProduct.getStartDt().toString().replaceAll("-", ""));

			
			// 1. 인코딩 이중 처리 방지
			RestTemplate restTemplate = new RestTemplate();
			DefaultUriBuilderFactory factory = new DefaultUriBuilderFactory();
			factory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.NONE);
			restTemplate.setUriTemplateHandler(factory);

			
			// 2. Jackson ObjectMapper를 이용한 파싱
			ObjectMapper objectMapper = new ObjectMapper();
			String jsonResponse = restTemplate.getForObject(urlBuilder.toString(), String.class);
			JsonNode root = objectMapper.readTree(jsonResponse);
			JsonNode items = root.path("response").path("body").path("items").path("item");

			// 비즈니스 이코노미 분기
			int limit = flightProduct.getCabin().equals("economy") ? 102 : 18;
			
			// 3. 응답 타입(단일 객체/배열)에 관계없이 동일한 파싱 로직 적용
			if (items.isArray()) {
				for (JsonNode node : items) {
					parseFlightProduct(node, flightProduct, limit, flightProductList);
				}
			} else if (items.isObject()) {
				parseFlightProduct(items, flightProduct, limit, flightProductList);				
			}

			
			
			
			
		} catch (JsonProcessingException e) {
			e.printStackTrace();
		}

		return flightProductList;
	}

	/**
	 * <p>시간데이터 포맷 설정</p>
	 * @author sdg
	 * @param vo      데이터 설정할 객체
	 * @param rawTime api의 시간 문자열
	 * @param form    출발, 도착 여부
	 */
	public void timeFormatter(FlightProductVO vo, String rawTime, int form) {
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmm");
		if (rawTime != null && !rawTime.isEmpty()) {
			if (form == 1) { // 출발
				LocalDateTime parseDateTime = LocalDateTime.parse(rawTime, formatter);
				String dayOfWeek = parseDateTime.getDayOfWeek().getDisplayName(TextStyle.SHORT, Locale.KOREAN);
				vo.setDepTime(parseDateTime);
				vo.setStartDt(parseDateTime.toLocalDate());
				vo.setDomesticDays(dayOfWeek);
			} else {
				LocalDateTime parseDateTime = LocalDateTime.parse(rawTime, formatter);
				vo.setArrTime(parseDateTime);
				vo.setEndDt(parseDateTime.toLocalDate());
			}
		}
	}

	
	
	
	
	
	@Override
	public MemberVO getPayPerson(String memId) {
		MemberVO result = flightMapper.getPayPerson(memId);
		if (result != null) {
			return result;
		}
		return null;
	}

	@Override
	public List<String> getFlightSeat(FlightProductVO flightProductVO) {
		log.info("getSeatInfo 실행 : {}", flightProductVO);

		List<String> seatList = flightMapper.getFlightSeat(flightProductVO);
		log.info("seatList : {}", seatList);

		return seatList;
	}

	@Override
	public int registerAirport() {
		String url = "http://apis.data.go.kr/1613000/DmstcFlightNvgInfoService/getArprtList?serviceKey=" + serviceKey
				+ "&_type=json";

		// 공항정보 - vo에 있는 정보와 매칭하는 것
		RestTemplate restTemplate = new RestTemplate(); // json끌어오기 

		// response -> body -> items 
		Map<String, Object> response = restTemplate.getForObject(url, Map.class);
		Map<String, Object> res = (Map<String, Object>) response.get("response");
		Map<String, Object> body = (Map<String, Object>) res.get("body");
		Map<String, Object> items = (Map<String, Object>) body.get("items");
		List<Map<String, Object>> airportList = (List<Map<String, Object>>) items.get("item");

		int status = 0;
		for (Map<String, Object> airport : airportList) {
			AirportVO vo = new AirportVO();

			vo.setAirportId((String) airport.get("airportId"));
			vo.setAirportNm((String) airport.get("airportNm"));
			log.info("airportId : ", vo.getAirportId());
			log.info("airportNm : ", vo.getAirportNm());
			// 정보 있는지 조회하는 코드 필요
			status = flightMapper.registerAirport(vo);
			log.info("registerAirport : regist ", status);
		}

		return status;
	}

	@Override
	public int registerAirline() {
		String url = "http://apis.data.go.kr/1613000/DmstcFlightNvgInfoService/getAirmanList?serviceKey=" + serviceKey
				+ "&_type=json";

		RestTemplate restTemplate = new RestTemplate();

		// response -> body -> items 구조
		Map<String, Object> response = restTemplate.getForObject(url, Map.class);
		Map<String, Object> res = (Map<String, Object>) response.get("response");
		Map<String, Object> body = (Map<String, Object>) res.get("body");
		Map<String, Object> items = (Map<String, Object>) body.get("items");
		List<Map<String, Object>> airlineList = (List<Map<String, Object>>) items.get("item");

		int status = 0;
		for (Map<String, Object> airline : airlineList) {
			AirlineVO vo = new AirlineVO();

			vo.setAirlineId((String) airline.get("airlineId"));
			vo.setAirlineNm((String) airline.get("airlineNm"));
			log.info("airlineId : ", vo.getAirlineId());
			log.info("airportNm : ", vo.getAirlineNm());
			status = flightMapper.registerAirline(vo);
			log.info("registerAirport : regist ", status);
		}
		return status;
	}

	@Override
	public void parseFlightProduct(JsonNode node, FlightProductVO flightProduct,
            int limit, List<FlightProductVO> flightProductList) {
		FlightProductVO vo = new FlightProductVO();

	    vo.setAirlineNm(node.path("airlineNm").asText());       // 항공사명
	    vo.setFlightSymbol(node.path("vihicleId").asText());    // 편명
	    vo.setEconomyCharge(node.path("economyCharge").asInt()); // 요금

	    vo.setArrAirportNm(flightProduct.getArrAirportNm());
	    vo.setDepAirportNm(flightProduct.getDepAirportNm());
	    vo.setDepAirportId(flightProduct.getDepAirportId());
	    vo.setArrAirportId(flightProduct.getArrAirportId());

	    if (vo.getAirlineNm().indexOf("대한") != -1 || vo.getAirlineNm().indexOf("아시아나") != -1) {
	    	int prestige = (int) (vo.getEconomyCharge() * 1.5);
			vo.setPrestigeCharge(prestige);
            vo.setCheckedBaggage(20);
        } else {
            vo.setCheckedBaggage(15);
        }

	    timeFormatter(vo, node.path("depPlandTime").asText(), 1);
	    timeFormatter(vo, node.path("arrPlandTime").asText(), 2);

	    AirlineVO airlineVO = flightMapper.selectAirline(vo.getAirlineNm());
	    if (airlineVO != null) {
	        vo.setAirlineId(airlineVO.getAirlineId());
	    }

	    List<String> seatList = flightMapper.getFlightSeat(vo);
	    if (seatList.size() < limit) {
	        flightProductList.add(vo);
	    }
	    
	}


}
