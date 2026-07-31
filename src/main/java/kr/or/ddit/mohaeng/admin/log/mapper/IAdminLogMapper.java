package kr.or.ddit.mohaeng.admin.log.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.mohaeng.tour.vo.TripProdVO;
import kr.or.ddit.mohaeng.vo.PaginationInfoVO;
import kr.or.ddit.mohaeng.vo.SystemLogVO;

@Mapper
public interface IAdminLogMapper {

	/**
	 * <p>페이지 수</p>
	 * @author sdg
	 * @date 2026-01-28
	 * @param pagInfoVO
	 * @return
	 */
	public int getSystemLogCount(PaginationInfoVO<SystemLogVO> pagInfoVO);

	
	/**
	 * <p>로그 데이터 수</p>
	 * @author sdg
	 * @date 2026-01-28
	 * @param pagInfoVO
	 * @return
	 */
	public List<SystemLogVO> getSystemLogList(PaginationInfoVO<SystemLogVO> pagInfoVO);
	
	
	public Map<String, Object> getSystemLogStats(PaginationInfoVO<SystemLogVO> pagInfoVO);
}
