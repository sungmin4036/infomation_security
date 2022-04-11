![image](https://user-images.githubusercontent.com/62640332/138555395-15e27ea8-f567-4017-a3f7-56d2fad6c0c3.png)




![image](https://user-images.githubusercontent.com/62640332/138555404-8220221a-8bdf-441d-812d-211372beebcc.png)



![image](https://user-images.githubusercontent.com/62640332/138555414-1ffee5b8-fd7d-4abd-959e-e5bd56b84cb6.png)


![image](https://user-images.githubusercontent.com/62640332/162669047-47713da2-a677-48cf-be4e-89f9d0e113ac.png)


### ㅁ CharGen(Character Generator Protocol)

: CharGen(Character Generator Protocol)은 클라이언트의 요청에 대해 랜덤한 개수(0-512)의문자열을 응답으로 보내주는 프로토콜이다. 

네트워크 연결에 대한 디버깅, 대역폭 테스팅 등에사용되었다. 

60byte의 요청 패킷에 대해서 랜덤한(74 ~ 1472 bytes) 크기의 응답을 보내주므로 평균적으로 수백 배 정도의 증폭효과를 갖는다.

UDP 19번 포트를 이용하며 nmap등의 스캐닝 툴을 이용해 CharGen 서버를 찾을 수 있다.

<br>
<br>

### ㅁ Memcached DDoS/DrDos Attack

```
멤캐시드는 분산 메모리 캐싱 시스템입니다. 콘텐츠를 디바이스에 임시 저장하여 방문자가 웹사이트를 다시 찾았을 때 효율적으로 로드하여 
웹사이트와 애플리케이션이 콘텐츠를 더 빨리 로드하게 돕는 데 목적이 있습니다.

Memcache란 메모리를 사용해 캐시서비스를 제공해주는 데몬으로 기업에서 대역폭을 효과적으로 사용하기 위하여 구축합니다.
```

Memcached 반사 공격은 공용 네트워크 상에 공개되어 있는 대량의 Memcached 서버(분산식 캐시 시스템)에 존재하는 인증과 설계의 취약점을 이용하는 것입니다. 

공격자는 memcached 서버 ip주소의 기본 포트인 `11211번` 포트로 희생자 IP주소로 위장된 특정 명령의 `UDP` 패킷(stats,set/get 명령 등)을 전송하면 

memcached 서버가 희생자 IP로 원래 패킷보다 수배의 패킷(이론상으로는 5만배 까지 가능)을 반사하며 DRDoS 공격이 수행되게 됩니다. 

<br>

<조치 방안>


- Memcached를 로컬 인터페이스에서만 사용 가능하도록 바인드 합니다.
- memcached 서버 혹은 memcached가 있는 네트워크 상단에 방화벽을 설치하고 업무관련 IP만 memcached 서버에 접속하도록 허용합니다. 
- memcached 서버의 리스닝 포트를 기본 포트인 11211이 아닌 다른 포트로 바꿔 악의적으로 이용되지 않도록 합니다. 
- memcache를 최신 버전으로 업데이트 하고, SASL 을 사용하여 비밀번호 설정 및 권한을 제어합니다.



