###ㅁ MIME 타입   
: MIME 타입이란 클라이언트에게 전송된 문서의 다양성을 알려주기 위한 메커니즘   
웹에서 파일의 확장자는  의미X 각 문서와 함께 올바른 MIME 타입을 전송하도록, 
서버가 정확히 설정하는 것이 중요
- Type: text, image, audio, video, application
Image Type: image/ gif, jpeg, png, svg+xml
Aduio Type: audtio/ wave, wav, x-wav, x-pn-wav, webm, ogg
Video Type: video/ webm, ogg
Application Type: application/ ogg
<br>
- 서버측에 있는 프로그램을 서버 사이드 프로그램
- 서버 사이드 스크립트는 프로그램 중에서도 스크립트 형태의 프로그램

####ㅁ ARP Spoofing
: ARP 프로토콜을 이용하여 동일 네트워크에 존재하는 두 Victim의 ARP 테이블에서 두 Victim의 IP에 대한 MAC주소를 Attacker자신의 MAC주소로 바꾸는 공격이다.
####ㅁ ARP Redirect
: ARP Spoofing에서 속이는 대상을 게이트웨이로 한 것이다.
 Victim은 Attacker가 Gateway인 줄 알고 외부로 통신할 때 Attacker에게 패킷을 보내기 때문에 외부로 나가는 패킷을 Sniffing할 수 있다.

 #### ㅁ ICMP Redirect
 : 라우터가 송신 측 호스트에 적합하지 않은 경로로 되어 있으면 해당 호스트에 대한 최적 경로를 다시 지정해주는 ICMP Type (이를 악용하면 패킷을 가로채는 것이 가능.)

 #### ㅁ SSL/TLS
 - SSL(Secure Sockets Layer)
 - TLS(Transport Layer Escurity)
: 네트워크 통신 환경에서 주고받는 데이터를 암호화 해주는 규약(다양한 애플리케이션에서 암호화된 통신을 위해 사용)
ㅁ SSL/TLS 주요 보안 이슈
> o HEIST(HTTP Encrypted Information can be Stolen through  공격 (2016년 8월, Black Hat 발표)
>>: 브라우저에 대한 사이드-채널 공격(side-channel attack)(8)을 통해 SSL/TLS로 암호화된 데이터의 정확한 크기를 알아내는 공격   
이미 알려진 이전 공격과 HEIST의 차이점은 중간자 공격(man-in-the-middle attack, MITM)(9) 없이 사용자의 브라우저만 있으면 웹사이트의 광고 등에 몰래 숨겨 놓은 악성 JavaScript를 이용하여 공격 가능    
HEIST를 이용하여 암호화된 데이터 크기를 정확히 알아내기만 하면 압축-기반 공격(compressionbased attack)(10)이나 크기-노출 공격(size-exposing attack) 등에 취약해져 사용자계정, 패스워드, 의료데이터 등 민감한 정보가 탈취될 가능성이 높아짐      
JavaScript의 Fetch API(데이터 전송 시작)와 타이밍 API(데이터 전송 종료)를 사용하면 첫 번째 TCP window(11) 안에 암호화된 데이터가 전송 완료되었는지 아니면 두 번째 TCP window 안에 전송 완료 되었는지를 알아낼 수 있음           

> o DROWN(Decrypting RSA with Obsolete and Weakened eNcryption) 공격 (2016년 3월, CVE-2016-0800)
> >: RSA 키교환 단계에서 암호화된 세션키(서버와 클라이언트 간 데이터를 암호화하는 대칭키)를 해독하는 공격   
> SSL 2.0 프로토콜에서 사용된 RSA 개인키(private key)와 동일한 개인키를 사용하는 RSA 키교환 기반의 TLS 연결은 DROWN 공격에 의해 암호화된 통신이 해독될 수 있음
> DROWN 공격은 SSL 2.0에서 사용한 RSA 개인키를 유출하는 것이 아니라 Bleichenbacher RSA패딩 오라클 공격을 통해 암호화된 세션키를 해독함
> SSL 2.0과 동일한 개인키를 사용하는 RSA 키교환 기반의 TLS 연결은 해독된 세션키를 이용하여 복호화 할 수 있기 때문에 클라이언트와 서버 간 비밀 통신을 엿볼 수 있음

![image](https://user-images.githubusercontent.com/62640332/136651311-3750ddce-806b-48e2-bb0f-be38a56d9c40.png)

> o FREAK (Factoring attack on RSA-EXPORT Keys) 공격(2015년 1월, CVE-2015-0204)
>>: 공격자는 중간자 공격(man-in-the-middle attack, MITM)을 통해 SSL 연결시 보안이 취약한 “수출 등급” RSA 알고리즘을 사용하도록 유도한 후 brute-force 공격(14)으로 RSA키를 알아내는 공격
>과거 미국에서는 자국 소프트웨어 수출시 암호화 수준을 낮추도록 규제하였는데 이를 “수출 등급(export-grade)” 암호화 알고리즘이라 함
>RSA_EXPORT는 512비트의 암호화키를 사용하는 수출 등급의 RSA 암호화 알고리즘으로서 현재 주로 사용되는 2,048비트 이상의 암호화키에 비해 brute-force 공격에 취약
![image](https://user-images.githubusercontent.com/62640332/136651398-33bffaed-0a8d-4c24-932e-fbebe2f548a7.png)
> - OpenSSL 0.9.8zd 이전 버전과 OpenSSL 1.0.0 ~ 1.0.0p 버전, OpenSSL 1.0.1 ~ 1.0.1k 버전 등이 취약하기 때문에 최신 버전으로 패치해야 함
> - 패치가 적용되기 전까지는 “RSA_EXPORT Cipher Suites” 비활성화 필요



> - POODLE(Padding Oracle On Downgraded Legacy Encryption) 공격(2014년 10월, CVE-2014-3566)
>> SSL 3.0은 Netscape사가 웹에서 암호화된 통신을 위해 1996년 발표한 스펙으로써 패딩 오라클 공격(Padding Oracle Attack)에 취약하여 2015년 RFC 7568에 의해 공식적으로 사용 제한(DEPRECATED) 됨
>POODLE 공격은 SSL 3.0의 CBC(Cipher Block Chaining) 암호 모드의 취약점을 통해 패딩 오라클 공격을 수행하여 주고받는 암호문을 해독할 수 있음
>공격자는 SSL 3.0의 패딩 오라클 취약점을 이용하기 위해 중간자 공격을 통해 TLS 연결 시도를 모두 무시(drop)하고 SSL 3.0 연결을 유도함
>SSL 3.0으로 연결되면 자바스크립트를 이용하여 브라우저가 특정 사이트의 인증정보(쿠키, 토큰 등)를 탈취할 수 있으며 패딩 오라클 공격으로 암호문을 해독할 수 있음
> ![image](https://user-images.githubusercontent.com/62640332/136651577-d36e5c48-ed47-4600-bb91-603e05148a56.png)
>- POODLE 공격을 대처하는 최선책은 더 이상 SSL 프로토콜을 지원하지 않는 것
>- 서버는 웹서버 설정을 통해 SSL 3.0 프로토콜 미지원 조치
>- 클라이언트는 브라우저 설정을 통해 SSL 3.0 연결 제한 조치

> Heartbleed 취약점 (2014년 4월, CVE-2014-0160)
>>: TLS/DTLS(15)에서 keep-alive 기능을 제공하는 Heartbeat Extension 스펙(16)이 OpenSSL 라이브러리에서 잘못 구현되어 공격자는 웹서버의 시스템 메모리 내용을 탈취할 수 있음
>이러한 취약점에 Heartbleed(심장출혈)라는 별명이 붙게 된 이유는 공격자가 스펙과 다른 Heartbeat을 서버에 지속적으로 보내면 이러한 취약점을 갖고 있는 서버의 응답에 민감한 정보가 조금씩 흘러나오기 때문임
>Heartbeat의 정상적인 사용 방법은 <그림 9>에서와 같이 클라이언트가 서버에 “bird”라는 내용(payload)을 보내면서 payload의 크기가 4byte라고 알려주면, 서버는 응답시 클라이언트로부터 받은 4byte의 “bird”를 되돌려줌
![image](https://user-images.githubusercontent.com/62640332/136651690-24fa9fc4-ccea-4a1d-befa-bac296fa962d.png)
![image](https://user-images.githubusercontent.com/62640332/136651711-51e88085-b859-42e3-9e38-8a575264a405.png)
> - Heartbleed 취약점에 노출된 경우, SSL 인증서를 무효화(revoke)하고 재발행해야 함

#### ㅁ Insecure Deserialization(안전하지 않은 역직렬화)
- 직렬화(Serialization) : 서로간에 원활한 통신을 위하여 객체를 직렬 화하여 전송 가능한 형태로 변환
- 역직렬화(Deserialization) : 직렬화된 파일 등을 역으로 직렬화하여 다시 객체의 형태로 변환
(저장된 파일을 읽거나 전송된 Stream 데이터를 읽어 원래 객체의 형태로 복원)
- 공격의 발생 원인
  >1. 애플리케이션 및 API가 공격자의 악의적이거나 변조된 객체를 역직렬화하면 취약해질 수 있습니다.

  >2. 공격자가 애플리케이션 로직을 수정하거나 애플리케이션에 사용 가능한 클래스가 있는 경우 임의의 원격코드를 실행하여 역직렬화 중이나 이후에 동작을 변경할 수 있습니다. 

  >3. 기존 데이터 구조가 사용되지만 내용이 변경되는 일반적인 데이터 변조 공격

- 공격 대응 방법 
  >1. 신뢰할 수 없는 출처로부터 직렬화된 객체 차단

  >2. 원시 데이터 유형만을 허용하는 직렬화 매체를 사용

  >3. 악성 객체 생성이나 데이터 변조를 방지하기 위해 직렬화된 객체에 대한 디지털 서명과 같은 무결성 검사를 구현

  >3. 객체 생성 전 코드가 일반적으로 정의하는 클래스 집합을 기대하므로 역 직렬화에 대한 엄격한 형식 제약조건 적용

  >4. 역직렬화 하는 컨테이너 또는 서버에서 들어오고 나가는 네트워크 연결을 제한하거나 모니터링 필터링하여 차단