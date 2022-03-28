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

![image](https://user-images.githubusercontent.com/62640332/160358977-f913f6c9-0eb6-4f8f-a3b9-5ce711587ae6.png)


- Layout 옵션 , PatternLayout 클래스를 사용할 시 사용

![image](https://user-images.githubusercontent.com/62640332/160359182-7c7dfdc6-db8b-4c2d-a0f2-31b0c47b1b68.png)



- 로그 설정

: 설정 파일은 "log4j.properties"

LogManager는 CLASSPATH 또는 프로젝트 root 디렉토리에 지정해야 "log4j.properties"를 읽을 수있다.

Level, Appender, Layout등을 설정한다.

```
# log4j.properties 파일
# 대부분 로그파일은 어떤 프로그램에서 사용하는 환경변수에 맞춰 경로를 지정한다.
# 그래서 미리 경로를 지정해주어 사용한다. 
log = ${user.home}/log

###################### Logger ############################### 
# rootLogger(최상위 로거)를 통해 로그레벨로 "DEBUG"를 지정.
# 최상위 로그 이름 "FILE1", "FILE2"로 지정.(다수 가능)
log4j.rootLoger = DEBUG, FILE1, FILE2

# 하위 로거 지정
log4j.logger.name.of.the.package.one=INFO console

# 로그 이름 따라 로그레벨을 따로 지정 가능
log4j.appender.console.Threshold = INFO

###################### Appender ##############################
# Appender 지정
## Appender 클래스 지정
log4j.appender.FILE=org.apache.log4j.DailyRollingFileAppender
## 출력 파일지정(대부분 절대경로 지정)
log4j.appender.FILE.File=output.log
## 날짜 패턴 추가
log4j.appender.FILE.DatePattern='.'yyyyMMDD
## WAS 재시작시 로그파일 새로 생성 여부(true: 기존파일에 추가, false: 파일 새로 생성)
log4j.appender.FILE.Append=true
## 최대크기
log4j.appender.FILE.MaxFileSize=1KB
## 파일크기 초과시 백업
log4j.appender.FILE.MaxBackupIndex=1

## Console용 클래스 지정
log4j.appender.console=org.apache.log4j.ConsoleAppender


###################### Layout ##############################
# Layout 지정
## FILE1 Layout 클래스 지정
log4j.appender.FILE.layout=org.apache.log4j.PatternLayout
## Layout 패턴 지정
log4j.appdender.FILE.ConversionPattern=[%d{HH:MM:ss}] [%-5p] (%F: %L) -%m%n

## console Layout 클래스 지정
log4j.appender.FILE.layout=org.apache.log4j.PatternLayout
## Layout 패턴 지정
log4j.appdender.FILE.ConversionPattern=%-5p%l -%m%n
```
[출처]

1. https://kurukurucoding.tistory.com/49
