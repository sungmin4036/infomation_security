

---

- log4j란?

: log4j의 기능은 웹 서비스 동작 과정에서 일어나는 모든 기록을 남겨 침해사고 발생 및 이상징후를 점검하기 위해 필수적으로 필요한 기능.  무료로 제공되는 오픈소스 프로그램으로 Java 기반의 몯느 어플리케이션에서 사용할 수 있습니다.

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
    - CVE-2021-44228, CVE-2021-45046 : JndiLookup 클래스를 경로에서 제거
    
    \* zip -q -d log4j-core-*.jar org/apache/logging/log4j/core/lookup/JndiLookup.class

    \*  log4j-core JAR 파일 없이 log4j-api JAR파일만 사용하는 경우 취약점의 영향 받지 않음

    - CVE-2021-4104 : JMSAppender 사용 확인 후 코드 수정 또는 삭제


<br>

- 보안 업데이트 안되있을시 발생할수 있는것

: 원격의 공격자가 이 취약점을 이요하여 악성코드 유포, 중요 데이터 탕취, 임의의 파일 다운로드 및 실행 가능.

