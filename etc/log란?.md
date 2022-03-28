### ㅁ 로그란?
 
모든 행위와 이벤트 정보를 시간의 경과에 따라 기록한 데이터 시스템 상에서 "로그" 를 생성하는 과정을 "로깅(Logging)" 이라고 한다.

- 로깅 라이브러리 종류


1. java.util.logging (jdk8) : JDK에 내장된 기본 로깅 라이브러리. JDK 1.4부터 포함된 표준 로깅 API
2. Apache Commons logging : Apache 재단의 Commons 라이브러리 중에 로그 출력을 제공하는 라이브러리
3. log4j : Aapache 재단에서 만든 log4j는 2001년에 처음 릴리즈된 자바의 로깅 라이브러리이다. 가장 널리 사용되는 로깅 라이브러리
4. Logback : Log4j를 개발한 Ceki Gulcu가 Log4j의 단점 개선 및 기능을 추가하여 개발한 로깅라이브러리


- Log 4j 구조

: 코어층 과 서포트층 으로 나누어 지며, 코어층이 서포트층을 유기적으로 응용하여 코어층에서 메시지를 핸들링한다.

![image](https://user-images.githubusercontent.com/62640332/160344024-31d6133b-a6f2-46b5-b64c-1135538ff472.png)

- Log 4j 레벨

![image](https://user-images.githubusercontent.com/62640332/160344107-08f81422-3e20-4a07-9dab-9f803adfefbe.png)


- Append 

: log4j에서 제공하는 출력 클래스

![image](https://user-images.githubusercontent.com/62640332/160344184-4dd80ecc-471d-4af8-a113-a97289cb78c9.png)

- Layout

: 어떤 형식으로 출력할지 정하는 클래스
