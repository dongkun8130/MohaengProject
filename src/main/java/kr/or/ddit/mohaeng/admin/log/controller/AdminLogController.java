package kr.or.ddit.mohaeng.admin.log.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.mohaeng.admin.accommodation.dto.AdminAccommodationDTO;
import kr.or.ddit.mohaeng.admin.accommodation.service.IAdminAccommodationService;
import kr.or.ddit.mohaeng.admin.log.service.IAdminLogService;
import kr.or.ddit.mohaeng.vo.AccommodationVO;
import kr.or.ddit.mohaeng.vo.PaginationInfoVO;
import kr.or.ddit.mohaeng.vo.SystemLogVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/admin/statistics/logs")
@CrossOrigin(origins = "http://localhost:7272")
public class AdminLogController {

	@Autowired
	private IAdminLogService adminLogService;
	
	/**
	 * <p>로그 목록 조회</p>
	 * @author sdg
	 * @date 2026-01-28
	 * @param currentPage
	 * @param searchWord
	 * @param searchType
	 * @param levelFilter
	 * @return
	 */
	@GetMapping
	public ResponseEntity<PaginationInfoVO<SystemLogVO>> getSystemLogList(
			@RequestParam(defaultValue = "1") int currentPage
			,@RequestParam(defaultValue = "") String searchWord
			,@RequestParam(defaultValue = "all") String searchType
			,@RequestParam(defaultValue = "all") String levelFilter
			,@RequestParam(required = false) String startDate
	        ,@RequestParam(required = false) String endDate
			) {
		log.info("로그 목록조회 : currentPage:{}, searchWord:{}, searchType:{}" , currentPage, searchWord, searchType);
		log.info("로그 목록조회 : startDate:{}, endDate:{}" , startDate, endDate);
		
		PaginationInfoVO<SystemLogVO> pagInfoVO = new PaginationInfoVO<>(15, 5);
		pagInfoVO.setCurrentPage(currentPage);
		pagInfoVO.setSearchWord(searchWord);
		pagInfoVO.setStartDate(startDate);
		pagInfoVO.setEndDate(endDate);
		
		if (!"all".equals(searchType)) {
			pagInfoVO.setSearchType(searchType);	// 검색타입. 
		}
		
		if (!"all".equals(levelFilter)) {
	        pagInfoVO.setLevelFilter(levelFilter);
	    }
		
		adminLogService.getSystemLogList(pagInfoVO);
		return ResponseEntity.ok(pagInfoVO);
	}
	
	
	@GetMapping("/stats")
	public ResponseEntity<Map<String, Object>> getStats(
	        @RequestParam String startDate, @RequestParam String endDate) {
	    PaginationInfoVO<SystemLogVO> vo = new PaginationInfoVO<>();
	    vo.setStartDate(startDate);
	    vo.setEndDate(endDate);
	    return ResponseEntity.ok(adminLogService.getSystemLogStats(vo));
	}
	
}
