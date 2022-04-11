![image](https://user-images.githubusercontent.com/62640332/138555395-15e27ea8-f567-4017-a3f7-56d2fad6c0c3.png)




![image](https://user-images.githubusercontent.com/62640332/138555404-8220221a-8bdf-441d-812d-211372beebcc.png)



![image](https://user-images.githubusercontent.com/62640332/138555414-1ffee5b8-fd7d-4abd-959e-e5bd56b84cb6.png)


![image](https://user-images.githubusercontent.com/62640332/162669047-47713da2-a677-48cf-be4e-89f9d0e113ac.png)


### ㅁ CharGen(Character Generator Protocol)

: CharGen(Character Generator Protocol)은 클라이언트의 요청에 대해 랜덤한 개수(0-512)의문자열을 응답으로 보내주는 프로토콜이다. 

네트워크 연결에 대한 디버깅, 대역폭 테스팅 등에사용되었다. 

60byte의 요청 패킷에 대해서 랜덤한(74 ~ 1472 bytes) 크기의 응답을 보내주므로 평균적으로 수백 배 정도의 증폭효과를 갖는다.

UDP 19번 포트를 이용하며 nmap등의 스캐닝 툴을 이용해 CharGen 서버를 찾을 수 있다.
