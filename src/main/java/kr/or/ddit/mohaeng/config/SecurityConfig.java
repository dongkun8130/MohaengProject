package kr.or.ddit.mohaeng.config;

import java.util.List;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.security.servlet.PathRequest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.authorization.AuthorizationDecision;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.RememberMeServices;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.rememberme.JdbcTokenRepositoryImpl;
import org.springframework.security.web.authentication.rememberme.PersistentTokenBasedRememberMeServices;
import org.springframework.security.web.authentication.rememberme.PersistentTokenRepository;
import org.springframework.security.web.savedrequest.HttpSessionRequestCache;
import org.springframework.security.web.savedrequest.RequestCache;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import jakarta.servlet.DispatcherType;
import kr.or.ddit.mohaeng.filter.TokenAuthenticationFilter;
import kr.or.ddit.mohaeng.login.service.CustomOAuth2UserService;
import kr.or.ddit.mohaeng.security.CustomAccessDeniedHandler;
import kr.or.ddit.mohaeng.security.CustomUserDetails;
import kr.or.ddit.mohaeng.security.CustomUserDetailsService;
import kr.or.ddit.mohaeng.util.TokenProvider;
import kr.or.ddit.mohaeng.vo.MemberVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {


 private final CustomOAuth2UserService customOAuth2UserService;

	@Autowired
	private DataSource dataSource;

	@Autowired
	private CustomUserDetailsService customUserDetailsService;

	@Autowired
	private TokenProvider tokenProvider;

	// 비회원 허용 url
	private static final String[] PASS_URL = {
			"/",
			"/member/login",
			"/member/register",
			"/member/register/member",
			"/member/register/company",
			"/member/find",
			"/member/idCheck",
			"/member/find",
			"/member/find/id",
			"/member/find/password",
			"/member/sns/**",
			"/mypage/profile",
			"/mypage/business/profile",
			"/mypage/profile/update",
			"/mypage/profile/checkPassword",
			"/mypage/profile/withdraw",
			"/idCheck",
			"/error",
			"/api/chatbot",
			"/tour",
			"/tour/**",
			"/schedule/search",
			"/schedule/rcmd-result",
			"/schedule/planner",
			"/schedule/common/**",
			"/product/flight",
			"/product/accommodation",
			"/product/accommodation/**",
			"/mohaeng/**",
			"/.well-known/**",		// 크롬 개발자 도구로의 요청
			"/upload/**",
			"/batch/load-acc-detail",
			"/batch/accommodation/search",
			"/support/faq/**",
			"/support/notice/**"
	};

	// 일반회원 허용 url test
	private static final String[] MEMBER_PASS_URL = {
			"/",
			"/error",
			"/mohaeng",
			"/schedule/**",
			"/.well-known/**",		// 크롬 개발자 도구로의 요청
			"/oauth2/**",
			"/login/oauth2/**"

	};

	// 기업회원 허용 url test
	private static final String[] BUSINESS_PASS_URL = {
			"/",
			"/error",
			"/mohaeng",
			"/statistics/**",
			"/.well-known/**"		// 크롬 개발자 도구로의 요청
	};


	// 관리자 허용 url
	private static final String[] REACT_PASS_URL = {
			"/api/admin/login",
			"/api/schedule/**",
			"/api/admin/schedule/**",
			"/api/admin/members/**",
			"/api/admin/notices/thumbnail/**",
			"/api/admin/inquiry/**",
			"/api/admin/products/**",
			"/api/admin/transactions/payments/**",
		    "/api/admin/stats/**"
		};

	SecurityConfig(TokenProvider tokenProvider, CustomUserDetailsService customUserDetailsService, CustomOAuth2UserService customOAuth2UserService) {

		this.tokenProvider = tokenProvider;
		this.customUserDetailsService = customUserDetailsService;
		this.customOAuth2UserService = customOAuth2UserService;
	}

	// 정적 리소스 허용
	@Bean
	public WebSecurityCustomizer configure() {
		return (web) -> web.ignoring()
				.requestMatchers(PathRequest.toStaticResources().atCommonLocations())
				.requestMatchers("/resources/**", "/upload/**"); // 정적 리소스
	}

	// 시큐리티 체인 - react 관리자 페이지
	@Order(1)
	@Bean
	protected SecurityFilterChain filterChainReact(HttpSecurity http) throws Exception {
		http.cors(cors -> cors.configurationSource(corsConfigurationSource()))
			.csrf((csrf) -> csrf.disable())
			.formLogin((login) -> login.disable())
			.httpBasic((basic) -> basic.disable())
			.headers(
					(config) -> config.frameOptions((fOpt) -> fOpt.sameOrigin())
			);

		http.sessionManagement(
				(management) -> management.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
			);
		http.addFilterBefore(new TokenAuthenticationFilter(tokenProvider), UsernamePasswordAuthenticationFilter.class);
		http.securityMatcher("/api/admin/**")
			.authorizeHttpRequests(
			(authorize) ->
				authorize.dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ASYNC).permitAll()
						.requestMatchers(REACT_PASS_URL).permitAll()
						.anyRequest().authenticated()
		);
		return http.build();
	}

	// 시큐리티 체인 - 회원 페이지
	@Order(2)
	@Bean
	protected SecurityFilterChain filterChainSession(HttpSecurity http) throws Exception {
		// csrf 토큰 보내기
		// 로그인 페이지에 <sec:csrfInput/>이거 계속 담기

	    http
	    .securityMatcher("/**")
	    .csrf(csrf -> csrf.disable())   // 일단 테스트용
	    .requestCache(cache -> {
            HttpSessionRequestCache requestCache = new HttpSessionRequestCache();
            requestCache.setRequestMatcher(request -> {
                // /api/ 로 시작하는 주소나, ajax 요청 등은 저장하지 않음 (true면 저장, false면 저장안함)
                return !request.getRequestURI().startsWith("/api/");
            });
            cache.requestCache(requestCache);
        })
        .authorizeHttpRequests(authorize ->
            authorize
                .dispatcherTypeMatchers(
                    DispatcherType.FORWARD,
                    DispatcherType.ASYNC
                ).permitAll()
                .requestMatchers("/oauth2/**", "/login/oauth2/**").permitAll()
                .requestMatchers("/ws/**").permitAll()
                .requestMatchers("/files/**").permitAll()
                .requestMatchers("/community/travel-log/write").hasRole("MEMBER")
                
                .requestMatchers(PASS_URL).permitAll()

                
                // 조회(GET)는 허용
                .requestMatchers(HttpMethod.GET, "/community/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/travel-log/records/**").permitAll()

                // 등록/수정/삭제는 MEMBER만
                .requestMatchers(HttpMethod.POST, "/api/travel-log/records/**").hasRole("MEMBER")
                .requestMatchers(HttpMethod.PUT, "/api/travel-log/records/**").hasRole("MEMBER")
                .requestMatchers(HttpMethod.DELETE, "/api/travel-log/records/**").hasRole("MEMBER")


//                .requestMatchers(MEMBER_PASS_URL).hasRole("MEMBER")
//                .requestMatchers(BUSINESS_PASS_URL).hasRole("BUSINESS")

                .requestMatchers("/member/login").permitAll()
                .requestMatchers("/member/sns/**").authenticated()

                // 마이페이지 접근 제어 (SNS 미완성 차단)
                .requestMatchers("/mypage/**").access((authentication, context) -> {
                    Authentication auth = authentication.get();

                    if (auth == null || !(auth.getPrincipal() instanceof CustomUserDetails)) {
                    	return new AuthorizationDecision(false);
                    }

                    CustomUserDetails user = (CustomUserDetails) auth.getPrincipal();
                    MemberVO member = user.getMember();

                    if ("Y".equals(member.getMemSnsYn())
                    		 && "N".equals(member.getJoinCompleteYn())) {
                    	return new AuthorizationDecision(false);
                    }

                    return new AuthorizationDecision(true);
                })
                .anyRequest().authenticated()

         )
        .formLogin(form -> form.disable())
        .httpBasic(hbasic -> hbasic.disable());
	    http.headers(headers -> headers.frameOptions(frame -> frame.sameOrigin()));

	    http.exceptionHandling(exception ->
	        exception.accessDeniedHandler(new CustomAccessDeniedHandler())
	    );
	
	    http.sessionManagement(session ->
	        session.maximumSessions(1)
	    );
	
	    // google 로그인
	    http
	    .oauth2Login(oauth2 -> oauth2
	        .loginPage("/member/login")
	        .userInfoEndpoint(userInfo -> userInfo.userService(customOAuth2UserService))
	        .successHandler((request, response, authentication) -> {
	            response.sendRedirect("/");
	        })
	    );
	
	    // 로그인 상태 유지
	    http.rememberMe(remember -> remember
	    		.key("mohaengKey") 								// 쿠키 암호화 키 (원하는 문자열)
	    		.tokenRepository(persistentTokenRepository()) 	// DB 저장소 설정
	    		.userDetailsService(customUserDetailsService) 	// 인증 유저 확인 서비스
	    		.tokenValiditySeconds(604800) 					// 쿠키 유효기간 (7일: 60*60*24*7)
	    		.rememberMeServices(rememberMeServices())
	    );
	
	    http.logout(logout ->
	        logout.logoutUrl("/logout")
	              .logoutRequestMatcher(new AntPathRequestMatcher("/member/logout", "GET")) // GET 방식 허용 추가
	              .addLogoutHandler((request, response, authentication) -> {
	                  log.info("로그아웃 핸들러 진입!");
	                  if (authentication != null) {
	                      log.info("로그아웃 유저명: " + authentication.getName());
	                      persistentTokenRepository().removeUserTokens(authentication.getName());
	                  }
	              })
				.invalidateHttpSession(true)           		// 세션 무효화
				.deleteCookies("JSESSIONID", "remember-me")	// 세션 쿠키와 자동로그인 쿠키 모두 삭제
				.clearAuthentication(true)
				.logoutSuccessUrl("/member/login")
	    );


	    return http.build();
	}

	@Bean
	protected CorsConfigurationSource corsConfigurationSource() {
	    CorsConfiguration config = new CorsConfiguration();
	    config.setAllowedOrigins(List.of("http://localhost:7272"));
	    config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS","PATCH")); //<-여기 "PATCH" 추가했어요~~
	    config.setAllowedHeaders(List.of("*"));
	    config.setAllowCredentials(true);

	    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
	    source.registerCorsConfiguration("/**", config);
	    return source;

	}

	@Bean
	protected AuthenticationManager authenticationManager(
			PasswordEncoder passwordEncoder
			) {
		DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
		authProvider.setUserDetailsService(customUserDetailsService);
		authProvider.setPasswordEncoder(passwordEncoder);
		return new ProviderManager(authProvider);
	}


	@Bean
	protected PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}

	// DB 저장소 
	@Bean
	protected PersistentTokenRepository persistentTokenRepository() {
		log.info("Remember-Me DB 저장소 빈 생성 시작");
        JdbcTokenRepositoryImpl repo = new JdbcTokenRepositoryImpl();
        repo.setDataSource(dataSource);
        return repo;
    }

	@Bean
	protected RememberMeServices rememberMeServices() {
	    JdbcTokenRepositoryImpl db = new JdbcTokenRepositoryImpl();
	    db.setDataSource(dataSource);

	    // 키값("mohaengKey")은 설정과 반드시 일치해야 함
	    PersistentTokenBasedRememberMeServices service =
	        new PersistentTokenBasedRememberMeServices("mohaengKey", customUserDetailsService, db);

	    service.setParameter("remember-me"); // 체크박스 name값
	    service.setTokenValiditySeconds(604800); // 7일
	    return service;
	}
	
	@Bean
	protected RequestCache requestCache() {
	    return new HttpSessionRequestCache();
	}

}
