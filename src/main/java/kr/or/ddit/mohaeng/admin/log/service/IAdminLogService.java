package kr.or.ddit.mohaeng.admin.log.service;

import java.util.Map;

import kr.or.ddit.mohaeng.vo.PaginationInfoVO;
import kr.or.ddit.mohaeng.vo.SystemLogVO;

public interface IAdminLogService {

	/**
	 * <p>로그 목록 가져오기</p>
	 * @author sdg
	 * @date 2026-01-28
	 * @param pagInfoVO 
	 */
	public void getSystemLogList(PaginationInfoVO<SystemLogVO> pagInfoVO);

	
	public Map<String, Object> getSystemLogStats(PaginationInfoVO<SystemLogVO> pagInfoVO);
}
