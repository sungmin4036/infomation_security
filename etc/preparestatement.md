이유는 Statement 객체에서 사용한 createStatement()라는 메소드 때문입니다. 이것을 사용할 경우 사용자의 입력 값을 미리 만들어 놓은 sql문에 적용한 후 컴파일을 하기 때문에 사용자의 입력 값에 따라 쿼리문의 형태가 바뀔 수 있어 보안에 취약합니다. 사용자가 입력 값과 함께 'OR 1=1'과 같은 코드를 함께 전달할 경우 모든 사용자의 정보 등이 노출될 수 있기 때문입니다.



따라서 해결책으로 Statement 객체의 preparedStatement(query) 메소드를 사용하였습니다. 이것은 미리 개발자가 작성한 쿼리문을 컴파일 하고 ?로 처리한 부분에 사용자의 입력 값을 넣기 때문에 쿼리문의 형태가 바뀌지 않아 보안성을 높일 수 있습니다.



PreparedStatement 와 Statement


* PreparedStatement 와 Statement의 가장 큰 차이점은 캐시(cache) 사용여부이다.

1) 쿼리 문장 분석

2) 컴파일

3) 실행

Statement를 사용하면 매번 쿼리를 수행할 때마다 1) ~ 3) 단계를 거치게 되고, PreparedStatement는 처음 한 번만 세 단계를 거친 후 캐시에 담아 재사용을 한다는 것이다. 만약 동일한 쿼리를 반복적으로 수행한다면 PreparedStatment가 DB에 훨씬 적은 부하를 주며, 성능도 좋다.


1. Statement 



String sqlstr = "SELECT name, memo FROM TABLE WHERE num = " + num 



Statement stmt = conn.credateStatement(); 



ResultSet rst = stmt.executeQuerey(sqlstr); 



sqlstr를 실행시 결과값을 생성



Statement  executeQuery() 나 executeUpdate() 를 실행하는 시점에 파라미터로 SQL문을 전달하는데, 이 때 전달되는 SQL 문은 완성된 형태로 한눈에 무슨 SQL 문인지 파악하기 쉽다. 하지만, 이 녀석은 SQL문을 수행하는 과정에서 매번 컴파일을 하기 때문에 성능상 이슈가 있다. 


2. PreparedStatement 



String sqlstr = "SELECT name, memo FROM TABLE WHERE num = ? " 

PreparedStatement stmt = conn.prepareStatement(sqlstr); 

pstmt.setInt(1, num);

ResultSet rst = pstmt.executeQuerey(); 

sqlstr 은 생성시에 실행

PreparedStatement 은 이름에서부터 알 수 있듯이 준비된 Statement 이다. 이 준비는 컴파일(Parsing) 을 이야기하며, 컴파일이 미리 되어있는 녀석이기에 Statement 에 비해 성능상 이점이 있다. 요 녀석은 보통 조건절과 함께 사용되며 재사용이 되는데, ? 부분에만 변화를 주어 지속적으로 SQL을 수행하기 때문에 한눈에 무슨 SQL 문인지 파악하기는 어렵다.


2.와 같이 이용할 경우 해당 인자만 받아서 처리하는 구조로 갈 수 있는것입니다.내부적으로 상세하게 뜯어 보지는 않았지만, 2.는 생성시 메모리에 올라가게 되므로 동일한 쿼리의 경우 인자만 달라지게 되므로, 매번 컴파일 되지 않아도 된다는 결론이 날듯 합니다. 

3. API

(1) Preparedstatement

public interface PreparedStatement extends Statement 

프리컴파일 된 SQL 문을 나타내는 오브젝트입니다. PreparedStatement 는 Statement를 상속받고 있습니다. 

SQL 문은 프리컴파일 되어 PreparedStatement 오브젝트에 저장됩니다. 거기서, 이 오브젝트는 이 문장을 여러 차례 효율적으로 실행하는 목적으로 사용할 수 있습니다. 

(2) Statement


public interface Statement 

정적 SQL 문을 실행해, 작성된 결과를 돌려주기 위해서(때문에) 사용되는 오브젝트입니다. 

디폴트에서는 Statement 오브젝트 마다 1 개의 ResultSet 오브젝트만이 동시에 오픈할 수 있습니다. 따라서, 1 개의 ResultSet 오브젝트의 read가, 다른 read에 의해 끼어들어지면(자), 각각은 다른 Statement 오브젝트에 의해 생성된 것이 됩니다. Statement 인터페이스의 모든 execution 메소드는 문장의 현재의 ResultSet 오브젝트로 오픈되고 있는 것이 존재하면, 그것을 암묵에 클로우즈 합니다. 

그리고 FOR 문등을 통하여 동일한 SELECT 를 여러번 실행해야 하는 경우에는, 그 사용성에 볼때 2번이 훨씬 효과적이라고 볼 수 있습니다. 


(3) 예제

1) Statement 

```
String sqlstr = null; 
Statement stmt = null; 
ResultSet rst = null; 
FOR(int i=0; i< 100 ; i++){ 
    sqlstr = "SELECT name, memo FROM TABLE WHERE num = " + i 
stmt = conn.credateStatement(); 
rst = stmt.executeQuerey(sqlstr); 
```


2) PreparedStatement


```
String sqlstr = null; 
PreparedStatement pstmt = null; 
ResultSet rst = null; 
sqlstr = "SELECT name, memo FROM TABLE WHERE num = ? " 
pstmt = conn.prepareStatement(sqlstr); 
FOR(int i=0; i< 100 ; i++){ 
    pstmt.setInt(1, i); 
    rst = pstmt.executeQuerey(); 
}
```






4. PreparedStatement를 사용해야 하는 경우



(1) 사용자 입력값으로 쿼리를 생성하는 경우 



사용자에의해 입력되는 값을 가지고 SQL 작업을 할 경우 statement를 사용한다면 다음과 같이 될 것이다.



String content = request.getParameter("content");



stmt= conn.createStatement();



stmt.executeUpdate("INSERT INTO TEST_TABLE (CONTENT) VALUES('"+content+"');







사용자가 제대로 입력 하였다면 상관 없지만 content값에 "AA'AA"를 입력하였다면?



stmt.executeUpdate("INSERT INTO TEST_TABLE (CONTENT) VALUES('"+content+"'); 에서 에러가 발생할 것이다.



즉 SQL문은 다음과 같이 되는 것이다. INSERT INTO TEST_TABLE (CONTENT) VALUES('AA'AA');







이를 다음과 같이 수정한다면 위와같은 에러나 장애를 원천적으로 봉쇄할 수 있다



pstmt = conn.preapreStatement("SELECT * FROM TEST_TABLE WHERE CONTENT = :content");



pstmt.setString(1, content);



pstmt.executeUpdate();



이는 content값이 "'"가 들어왔다 하더라도 알아서 파싱 해주기 때문이다.



고로 사용자 입력 값으로 쿼리를 바인딩 할 경우에는 필히 pstmt를 사용하도록 하자! :)







(2) 쿼리 반복수행 작업일 경우



일반적으로 반복 수행 작업을 할 경우 아래와 같이 코딩 하게 된다.



1) Statement 사용



for (int i = 0; i < 100000; i++) {



stmt.executeUpdate("INSERT INTO TEST_TABLE VALUES('"+content+"');



}







2) PreparedStatement 사용



pstmt = conn.preapreStatement("INSERT INTO TEST_TABLE VALUES(?)"); <--- ⓐ



for (int i = 0; i < 10000; i++) {



pstmt.setString(1, content+i);



pstmt.executeUpdate();



}



종종 실수로 ⓐ번 문장이 for문으로 들어가는것을 보게된다! 주의!







cf.) DB의 종류에 따라 상황이 달라진다.



일반적으로 위와같은 코딩을 할 경우 2)경우가 1)보다 더 나은 성능을 보인다고 알려져 있다. 즉 자바의 PreparedStatement의 사용은 오라클 DB에서 bind변수를 사용하도록 함으로 해서 DB서버에 미리 준비된 SQL을 사용하게 되고 파싱과정을 생략하기 때문에 결국 DB리소스를 효율적으로 사용하도록 하는 방법이 된다.



하지만 이것이 DB서버에 따라 다르다. MySql같은 경우는 1)과2)의 성능차이가 거의 나지 않는다.







--> 적당한 PreparedStatement의 사용



위와같은 이유로 PreparedStatement가 좋다! 모든 쿼리를 PreparedStatement로 하자! 만약 이와 같이 된다면 또다른 문제가 생긴다. 각 DB마다 SQL캐싱할 수 있는 한계가 있기 때문에 정작 성능상 캐싱되어야 할 쿼리가 그렇지 않은 쿼리 때문에 캐싱이 안 될 수 있기때문에 꼭 필요한 문장만 PreparedStatement를 쓰는것을 권고한다.







5. Statement를 받드시 사용해야 하는 경우



(1) Dynamic SQL을 사용할 경우



Dynamic SQL을 사용한다면 매번 조건절이 틀려지게 됨으로 statement가 낫다. 즉 캐싱의 장점을 잃어버립니다. 또한 Dynamic SQL일 경우 코딩도 Statement가 훨신 편하다.

