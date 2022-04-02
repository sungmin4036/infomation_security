referer는 http 헤더중 하나이다.

HTTP 프로토콜에는 referer 라는 헤더값이 있는데, 브라우저가 서버로 이 헤더값을 설정해서 보내게 된다.
 
서버는 referer를 참조함으로써 현재 표시 하는 웹페이지가 어떤 웹페이지에서 요청되었는지 알수 있으며,

어떤 웹사이트나 웹서버에서 방문자가 왔는지를 파악할수 있는 기능을 referer 를 통해 할수 있다.

![image](https://user-images.githubusercontent.com/62640332/161367917-31cf542e-e157-4fdc-9c4c-e8988471cf83.png)

![image](https://user-images.githubusercontent.com/62640332/161367932-04908ddc-ce93-4fd3-b954-55b830d75242.png)


대부분의 웹서버에는, 이전(before) 트래픽로그가 존재하며, 브라우저가 송신한 HTTP referer을 기록하고 있다.

referer 정보는 유저의 프라이버시에 관계되는 경우가 있기 때문에, referer 정보를 송신하지 않는 설정을 할 수 있는 브라우저도 있기도 하다. 

하지만 올바른 referer 정보를 보내지 않으면 문제가 발생할 수도 있는데, 웹서버는 자신의 페이지중 일부 페이지에 올바른 referer 정보를 송신하지 않는 브라우저에 대해 엑세스를 블록해 버리기도 한다.

(이건 타 사이트 직접 링크나 이미지의 부정사용을 막기 위함이다.)

---

- referer 사용처

결국 referer의 값은 이 페이지를 요청한 이전 페이지가 무엇인지를 알려주는 정보이다.

referer는 보통 로그 분석이나 접근 제어를 할 때 이용한다

 
로그분석을 할 때,

우리 사이트로의 유입이 어떤 검색서비스를 이용한 것인지 알고자할 때 바로 이 referer를 분석한다.

이것이 일반적인 로그분석기이다.
 

접근제어도 알고 보면 단순한 로직이다.

게시물을 저장할 때에는 그 전에 게시물을 쓰는 페이지에서 저장을 요청한다.

때문에 '저장' 페이지에서 referer값을 체크해서, '쓰기' 페이지가 referer값이 아니면 요청을 거부할 수 있다.

물론 이러한 방법은 아주 단순한 방법이기 때문에 완벽한 접근제어는 아니지만, 임시적으로 제어를 할 경우에는 간단하기 때문에 꽤 유용하게 이용될 수 도 있다.

---

- 스크립트에서 referer 데이터 얻기

```
if (document.referrer) {
    var myReferer = document.referrer;
    document.write(myReferer);
}
```

```
/* Node.js */
const { headers: { referer } } = req
console.log(referer);
```

```
if (isset ($ _ SERVER ['HTTP_REFERER'])) {
	echo $ _SERVER ['HTTP_REFERER'];
}

```

if (document.referrer) {
    var myReferer = document.referrer;
    document.write(myReferer);
}
/* Node.js */
const { headers: { referer } } = req
console.log(referer);
if (isset ($ _ SERVER ['HTTP_REFERER'])) {
	echo $ _SERVER ['HTTP_REFERER'];
}


출처: https://inpa.tistory.com/entry/WEB-📚-HTTP-referer-란 [👨‍💻 Dev Scroll]

