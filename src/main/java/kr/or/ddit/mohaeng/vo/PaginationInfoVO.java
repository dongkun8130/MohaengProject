package kr.or.ddit.mohaeng.vo;

import java.util.List;
import java.util.Map;

import lombok.Data;

@Data
public class PaginationInfoVO<T>{
	private int totalRecord; //총게시글
	private int totalPage;   //총 페이지스
	private int currentPage; //현재페이지
	private int screenSize =10; //페이지 당 게시글수
	private int blockSize =5;  //페이지 블록수
    private int startRow; // 시작 row
    private int endRow; // 끝 row
    private int startPage; //시작페이지
    private int endPage; // 끝 페이지
    private List<T> dataList; //결과를 넣을 데이터 리스트
    private String searchType;
    private String searchWord;
    private int memNo;
    private String searchStatus;  // 상태 필터
    private String searchRegion;  // 지역 필터

    //추가함
    private Map<String, String> filters;
    
    // 추가
    private String startDate;
    private String endDate;

    private String levelFilter;

    public PaginationInfoVO() {}


    public PaginationInfoVO(int screenSize, int blockSize){
    	this.screenSize = screenSize;
    	this.blockSize = blockSize;
    }
    public void setTotalRecord(int totalRecord) {
    	//총 게시글수를 저장하고, 총 게시글수를 페이지 당 나타낼 게시글 수로 나눠 총페이지수를 구한다.
    	this.totalRecord = totalRecord;
    	this.totalPage =(int)Math.ceil(totalRecord/(double)screenSize);
    	
    	if (this.endPage > this.totalPage) {
            this.endPage = this.totalPage;
        }	
    	
    }
    public void setCurrentPage(int currentPage) {
    	this.currentPage = currentPage; //현재페이지
    	this.endRow = currentPage *screenSize;
    	this.startRow = endRow-(screenSize-1);
    	this.endPage=(currentPage+(blockSize-1))/blockSize *blockSize;
    	this.startPage = endPage-(blockSize-1);
    }

	 //설정된 블록 사이즈만큼의 페이지 번호를 가지고있는 html 코드를 메서드로 모듈화한다.
	 public String getpagingHTML() {
		 StringBuffer html = new StringBuffer();
		 html.append("<ul class ='pagination pagination-sm m-0 float-right'>");

		 //<12345>
		 if(startPage>1) {
			 html.append("<li class='page-item'><a href='' class ='page-link' data-page='"+
					 		(startPage -blockSize) + "'>Prev</a></li>");


		 }
		 //반복문 내 조건문 총 페이지가 있고 현재 페이지에 따라서 endpage값이 결정됩니다
		 // 총 페이지가 14개고 현재 페이지가 9페이지라면 넘어가야할 페이지가 남아 있는 거시기때문에
		 //endpage만큼 반복되고 넘어가야할 페이지가 존재하지 않는 상태라면 마지막 페이지가 포함되어 있는 block영역이므로
		 //totalpage만큼 반복되게 됩니다.
		 for(int i = startPage; i<=(endPage<totalPage?endPage:totalPage); i++ ) {
			 if(i == currentPage) {
				 html.append("<li class='page-item active'><span class='page-link'>" + i+ "</span></li>");
			 }else {
				 html.append("<li class='page-item'><a href='' class='page-link' data-page='" + i + "'>" + i + "</a></li>");
			 }
		 }
		 if(endPage<totalPage) {
			 html.append("<li class='page-item'><a href='' class='page-link' data-page='"+(endPage +1) + "'>next</a></li>" );
		 }
		     html.append("</ul>");
		     return html.toString();
	 }
}
