package kr.or.ddit.mohaeng.mypage.notifications.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import kr.or.ddit.mohaeng.vo.AlarmVO;
import kr.or.ddit.mohaeng.vo.PaginationInfoVO;

@Mapper
public interface INotiAlarmMapper {

	public int selectAlarmCount(PaginationInfoVO<AlarmVO> pagingVO);

	public List<AlarmVO> selectAlarmList(PaginationInfoVO<AlarmVO> pagingVO);
	
	public int updateReadOne (@Param("memNo") int memNo,
					          @Param("alarmNo") int alarmNo);
	public int selectUnreadCount(int memNo);

	public void insertAlarm(AlarmVO alarm);
	
	// 헤더에 알람 목록 가져오기 위한 이벤트
	public List<AlarmVO> selectAlramList(int memNo);
	
	public int updateAllRead(int memNo);

	public List<AlarmVO> selectUnreadList(int memNo);
	

}