package kr.or.ddit.mohaeng.mypage.notifications.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.mohaeng.mypage.notifications.service.IAlarmService;
import kr.or.ddit.mohaeng.mypage.notifications.service.INotificationsAlarmService;
import kr.or.ddit.mohaeng.security.CustomUserDetails;
import kr.or.ddit.mohaeng.support.notice.service.NoticeServiceImpl;
import kr.or.ddit.mohaeng.vo.AlarmVO;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/alarm")
public class AlarmApiController {

	    private final IAlarmService alarmService;

	    @GetMapping("/unread-count")
	    public int unreadCount(@AuthenticationPrincipal CustomUserDetails user) {
	    	int memNo= user.getMemNo();
	    	
	      return alarmService.getUnreadCount(memNo);
	    }

	    @PostMapping("/read")
	    public Map<String, Object> read(
	        @AuthenticationPrincipal CustomUserDetails user,
	        @RequestBody Map<String, Integer> body
	    ) {
	      int alarmNo = body.getOrDefault("alarmNo", 0);
	      int memNo = user.getMemNo();
	     
	      //알람 읽음처리
	      boolean ok = alarmService.readOne(user.getMemNo(), alarmNo);
	      int unreadCount = alarmService.getUnreadCount(memNo);
	      //1.알람테이블(notification)전체목록조회(service-mapper-query)
	      List<AlarmVO> alarmList = alarmService.selectAlramList(memNo);
	      //2.전체 조회를 해 온 목록 데이터를 전달하기 위한 준비
	      		  
	      //-map이라는 컬렉션에 담아서 보내기
	      Map<String, Object> result = new HashMap<>();

	      result.put("ok", ok);          // 처리 결과
	      result.put("list", alarmList); // 전체 알람 목록
	      result.put("unreadCount", unreadCount);// 안 읽은 개수
	      // - 보낼떄 전체목록데이터와 카운트 데이터를 함께 담아 보내기.
	      return result;
	    }
	    
	    @PostMapping("/list")
	    public List<AlarmVO> alarmList(
	    		@AuthenticationPrincipal CustomUserDetails user
	    		){
	    	int memNo = user.getMemNo();
	    	List<AlarmVO> list = alarmService.selectAlramList(memNo);
	    	return list;
	    }
	    
	    @PostMapping("/test-insert")
	    public String testInsert(@AuthenticationPrincipal CustomUserDetails user){
	        alarmService.testInsert(user.getMemNo());
	        return "ok";
	    }

	    @PostMapping("/mypage/notifications/readAll")
	    @ResponseBody
	    public ResponseEntity<?> readAll(
	            @AuthenticationPrincipal CustomUserDetails user
	    ) {
	        alarmService.readAll(user.getMemNo());
	        return ResponseEntity.ok().build();
	    }
	    @PostMapping("/unread-list")
	    public List<AlarmVO> unreadList(
	            @AuthenticationPrincipal CustomUserDetails user
	    ) {
	        int memNo = user.getMemNo();
	        return alarmService.selectUnreadList(memNo);
	    }

}
