package kr.or.ddit.mohaeng.flight.service;

import java.util.List;

import com.fasterxml.jackson.databind.JsonNode;

import kr.or.ddit.mohaeng.vo.AirlineVO;
import kr.or.ddit.mohaeng.vo.AirportVO;
import kr.or.ddit.mohaeng.vo.FlightProductVO;
import kr.or.ddit.mohaeng.vo.MemberVO;

public interface IFlightService {

	/**
	 * <p>공항 정보 등록</p>
	 * @author sdg
	 * @return 성공시 1, 실패시 -1
	 */
	public int registerAirport();
	
	/**
	 * <p>항공사 정보 등록</p>
	 * @author sdg
	 * @return 성공시 1, 실패시 -1
	 */
	public int registerAirline();

	/**
	 * <p>전체 공항 조회</p>
	 * @author sdg
	 * @return 전체 공항 목록
	 */
	public List<AirportVO> getAirportList();

	/**
	 * <p>전체 항공사 조회</p>
 	 * @author sdg
	 * @return 전체 항공사 목록
	 */
	public List<AirlineVO> getAirlineList();

	/**
	 * <p>항공권 조회</p>
	 * @author sdg
	 * @param flightProduct api 필요 정보
	 * @return 항공권
	 */
	public List<FlightProductVO> getFlightList(FlightProductVO flightProduct);
	
	
	/**
	 * <p>결제자 번호, 이름, 이메일, 전화번호, 포인트 조회</p>
	 * @author sdg
	 * @param memId
	 * @return mem_no, mem_name, mem_email, point, tel
	 */
	public MemberVO getPayPerson(String memId);

	/**
	 * <p>좌석 정보 조회</p>
	 * @author sdg
	 * @param flightProductVO 항공권 정보
	 * @return 좌석정보
	 */
	public List<String> getFlightSeat(FlightProductVO flightProductVO); 
	
	
	
	public void parseFlightProduct(JsonNode node, FlightProductVO flightProduct,
            int limit, List<FlightProductVO> flightProductList);
}
