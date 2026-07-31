package kr.or.ddit.mohaeng.admin.log.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.or.ddit.mohaeng.admin.log.mapper.IAdminLogMapper;
import kr.or.ddit.mohaeng.vo.PaginationInfoVO;
import kr.or.ddit.mohaeng.vo.SystemLogVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class AdminLogServiceImpl implements IAdminLogService {

	@Autowired
	private IAdminLogMapper adminLogMapper;
	
	@Override
	public void getSystemLogList(PaginationInfoVO<SystemLogVO> pagInfoVO) {
		log.info("pagInfoVO : {}", pagInfoVO);
		int totalRecord = adminLogMapper.getSystemLogCount(pagInfoVO);
		log.info("totalRecord : {}", totalRecord);
		pagInfoVO.setTotalRecord(totalRecord);
		
        List<SystemLogVO> dataList = adminLogMapper.getSystemLogList(pagInfoVO);
        log.info("dataList : {}", dataList);
        
        // 카운트 변수 지정해줘야됨
        
        pagInfoVO.setDataList(dataList);
	}
	
	@Override
	public Map<String, Object> getSystemLogStats(PaginationInfoVO<SystemLogVO> pagInfoVO) {
	    return adminLogMapper.getSystemLogStats(pagInfoVO);
	}

}
