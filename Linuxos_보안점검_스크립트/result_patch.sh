#!/bin/sh

###########################################################################################
#                                                                           		      #
#   Program Name : Security Check_result for LINUX                         			      #
#   Version : V1.03                                                        			      #
#   Description : 이 프로램은 LINUX 서버 시스템 보안패치 결과를 보여주는 스크립트 입니다.      #
#                                                                          			      #
#-----------------------------------------------------------------------------------------#
#                                                                          			      #
#                                                                             			  #
# 																						  #
#                                                                             			  #
###########################################################################################



HOSTNAME=`hostname`
LANG=C
export LANG

#----------------------함수 목록 시작----------------------#
# 개행 지원 함수
# $1 : 파일명
function NewLine() {
	echo "" >> $1 2>&1
}

# 구분선 함수
# $1 : 파일명
function DividingLine() {
	echo "------------------------------------------------------------------------------" >> $1 2>&1
}

# echo로 파일에 텍스트 쓰기 함수
# $1 : 파일명
# $2 : 텍스트
function WriteEcho() {
	echo $2 >> $1 2>&1
}

# 새 파일 생성
# $1 : 파일명
function NewFile() {
	echo "" > $1
}

# 리눅스 버전 확인
function CheckVersion() {
	if grep -q -i "release 5" /etc/redhat-release ; then
		return 5
	elif grep -q -i "release 6" /etc/redhat-release ; then
		return 6
	elif grep -q -i "release 7" /etc/redhat-release ; then
		return 7
	else
		return 0
	fi

	return -1
}

# $OSTYPE으로 OS 종류 확인
function CheckOSTYPE() {
	case "$OSTYPE" in
		solaris*) echo "SOLARIS" ;;
		darwin*)  echo "OSX" ;;
		linux*)   echo "LINUX" ;;
		bsd*)     echo "BSD" ;;
		msys*)    echo "WINDOWS" ;;
		*)        echo "unknown: $OSTYPE" ;;
	esac
}

# uname으로 OS 종류 확인
function CheckOSTYPE_uname() {
	# Detect the platform (similar to $OSTYPE)
	OS="`uname`"
	case $OS in
		'Linux')
			OS='Linux'
			alias ls='ls --color=auto'
			;;

		'FreeBSD')
			OS='FreeBSD'
			alias ls='ls -G'
			;;
		'WindowsNT')
			OS='Windows'
			;;
		'Darwin')
			OS='Mac'
			;;
		'SunOS')
			OS='Solaris'
			;;
		'AIX')
			OS='AIX'
			;;
		*) ;;
	esac
}

# 쉘 종류 확인
# 함수 호출 및 반환값 방법
# variable=`CheckShell`
# 변수=`함수 이름`
function CheckShell() {
	checkSh="`echo $SHELL | awk -F "/" '{print $NF}'`"

	case $checkSh in
		'sh')
			echo 'sh'
			;;
		'csh')
			echo 'csh'
			;;
		'tcsh')
			echo 'tcsh'
			;;
		'ksh')
			echo 'ksh'
			;;
		'bash')
			echo 'bash'
			;;
		*)
			echo 'unknown'
			;;
	esac
}
#----------------------함수 목록 끝----------------------#

#파일 검사 시간이 지연(10분 이상)되는 시스템을 위한 파일 검사를 인터뷰로 대체하기 위한 변수
# 0 : 파일 검사 진행
# 1 : 파일 검사 패스(인터뷰)
filecheck_pass=0

#파일 이름 설정
filepath=$HOSTNAME"_CentOS_result.txt"

#기존 결과 파일 삭제
rm -f $filepath

#2>&1 : stderr를 stdout으로 리디렉션

echo "U-01 Check Start..."
echo "■ U-01. 1. 계정관리 > 1.1 root 계정 원격 접속 제한" >> $filepath 2>&1
echo "■ 기준: /etc/securetty 파일에 pts/* 설정이 있으면 취약"	>> $filepath 2>&1
echo "■ 기준: /etc/securetty 파일에 pts/* 설정이 없거나 주석처리가 되어 있고, /etc/pam.d/login에서 auth required /lib/security/pam_securetty.so 라인에 주석(#)이 없으면 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

#파일에서 pts 중 주석처리가 안된 목록이 있으면 취약
if [ `cat /etc/securetty | grep "pts" | grep -v "^#" | wc -l` -gt 0 ]; then
	echo "U-01,X,,"	>> $filepath 2>&1
	echo "root 계정 원격 접속을 제한하고 있지 않음" >> $filepath 2>&1

	cat /etc/securetty | grep "pts"	>> $filepath 2>&1
else
	# /etc/pam.d/login 파일 설정에서 pam_securetty.so 설정이 주석인지 확인
	if [ `cat /etc/pam.d/login | grep "pam_securetty.so" | grep "^#" | wc -l` -gt 0 ]; then
		echo "U-01,X,,"	>> $filepath 2>&1
		NewLine $filepath
		echo "root 계정 원격 접속을 제한하고 있지 않음"	>> $filepath 2>&1
	else
		echo "U-01,O,,"	>> $filepath 2>&1
		NewLine $filepath
		echo "root 계정 원격 접속을 제한하고 있음"	>> $filepath 2>&1
	fi

	cat /etc/pam.d/login | grep "pam_securetty.so"	>> $filepath 2>&1
fi
NewLine $filepath

echo "telnet 서비스 추가 확인 /etc/services 파일에서 포트 확인"	>> $filepath 2>&1
DividingLine $filepath

cat /etc/services | awk -F" " '$1=="telnet" {print $1 "   " $2}' | grep "tcp"	>> $filepath 2>&1

NewLine $filepath
echo "서비스 포트 활성화 여부 확인"	>> $filepath 2>&1
DividingLine $filepath

if [ `cat /etc/services | awk -F" " '$1=="telnet" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="telnet" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | wc -l` -gt 0 ]; then
		netstat -na | grep ":$port " | grep -i "^tcp"	>> $filepath 2>&1
	else
		echo "Telnet Service Disable"	>> $filepath 2>&1
	fi
fi

NewLine $filepath


echo "U-02 Check Start..."
echo "■ U-02. 1. 계정관리 > 1.2 패스워드 복잡성 설정" >> $filepath 2>&1
echo "■ 기준: 영문/숫자/특수문자가 혼합된 8자리 이상의 패스워드가 설정된 경우 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

echo "U-02,C,," >> $filepath 2>&1
echo "리눅스-RHEL 버전별로 패스워드 정책 확인" >> $filepath 2>&1

CheckVersion
if [ $? -eq 7 ]; then
	echo "최소 소문자 요구 1자 이상" >> $filepath 2>&1
	grep -i "lcredit" /etc/security/pwquality.conf >> $filepath 2>&1

	echo "최소 대문자 요구 1자 이상" >> $filepath 2>&1
	grep -i "ucredit" /etc/security/pwquality.conf >> $filepath 2>&1

	echo "최소 숫자 요구 1자 이상" >> $filepath 2>&1
	grep -i "dcredit" /etc/security/pwquality.conf >> $filepath 2>&1

	echo "최소 특수문자 요구 1자 이상" >> $filepath 2>&1
	grep -i "ocredit" /etc/security/pwquality.conf >> $filepath 2>&1

	echo "최소 패스워드 길이 8자 이상" >> $filepath 2>&1
	grep -i "minlen" /etc/security/pwquality.conf >> $filepath 2>&1

	echo "패스워드 입력 실패 재시도 횟수 3번" >> $filepath 2>&1
	grep -i "retry" /etc/security/pwquality.conf >> $filepath 2>&1

	echo "기존 패스워드 비교. 기본값 10(50%)" >> $filepath 2>&1
	grep -i "difok" /etc/security/pwquality.conf >> $filepath 2>&1

	echo "패스워드 기간 만료 경고 알림(7 : 7일이 남은 시점부터 알림)" >> $filepath 2>&1
	grep -i "pass_warn_age" /etc/login.defs >> $filepath 2>&1

	echo "최대 패스워드 사용 기간 설정(60일)" >> $filepath 2>&1
	grep -i "pass_max_days" /etc/login.defs >> $filepath 2>&1

	echo "최소 패스워드 사용 기간 설정(1일 : 최소 1일 경과 후 패스워드 변경 가능)" >> $filepath 2>&1
	grep -i "pass_max_days" /etc/login.defs >> $filepath 2>&1
else
	#centos 6.x 버전
	cat /etc/pam.d/system-auth >> $filepath 2>&1
fi

NewLine $filepath




echo "U-03 Check Start..."
echo "■ U-03. 1. 계정관리 > 1.3 패스워드 파일 보호" >> $filepath 2>&1
echo "■ 기준: 패스워드가 /etc/shadow 파일에 암호화 되어 저장되고 있으면 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

if [ -f /etc/passwd ]; then
	if [ `awk -F : '$2=="x"' /etc/passwd | wc -l` -eq 0 ]; then
		echo "U-03,X,,"	>> $filepath 2>&1
		echo "/etc/passwd 파일에 패스워드가 암호화 되어 있지 않음"	>> $filepath 2>&1
	else
		echo "U-03,O,,"	>> $filepath 2>&1
		echo "/etc/passwd 파일에 패스워드가 암호화 되어 있음"	>> $filepath 2>&1
	fi

	NewLine $filepath
	echo "[참고] /etc/passwd Top 5 목록"	>> $filepath 2>&1
	DividingLine $filepath
	cat /etc/passwd | head -5	>> $filepath 2>&1
	echo "이하생략..."	>> $filepath 2>&1
else
	echo "U-03,N/A,,"	>> $filepath 2>&1
	echo "/etc/passwd 파일이 없음"	>> $filepath 2>&1
fi

NewLine $filepath
echo "■ /etc/shadow 파일"	>> $filepath 2>&1
DividingLine $filepath

if [ -f /etc/shadow ]; then
	cat /etc/shadow | head -5	>> $filepath 2>&1
else
	echo "/etc/shadow 파일이 없음"	>> $filepath 2>&1
fi

NewLine $filepath



echo "U-04 Check Start..."
echo "■ U-04. 1. 계정관리 > 1.4 root 이외의 UI가 ‘0’ 금지"	>> $filepath 2>&1
echo "■ 기준: root 계정만이 UID가 0이면 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

# UID가 0이 1개이면 양호 2개 이상이면 취약
if [ `awk -F : '$3=="0"' /etc/passwd | wc -l` -eq 1 ]; then
	echo "U-04,O,,"	>> $filepath 2>&1
  echo "root 계정과 동일한 UID를 갖는 계정이 존재하지 않음" >> $filepath 2>&1
else
  echo "U-04,X,,"	>> $filepath 2>&1
  echo "root 계정과 동일한 UID를 갖는 계정이 존재함"	>> $filepath 2>&1
fi

awk -F : '$3==0 { print $1 " -> UID=" $3 }' /etc/passwd	>> $filepath 2>&1

NewLine $filepath
echo "/etc/passwd 파일 내용"	>> $filepath 2>&1
DividingLine $filepath

cat /etc/passwd	>> $filepath 2>&1

NewLine $filepath


echo "U-05 Check Start..."
echo "■ U-05. 1. 계정관리 > 1.5 패스워드 최소 길이 설정" >> $filepath 2>&1
echo "■ 기준: 패스워드 최소 길이가 8자 이상으로 설정되어 있으면 양호"	>> $filepath 2>&1
echo "  (PASS_MIN_LEN 8 이상이면 양호)" >> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

CheckVersion
if [ $? -eq 7 ]; then
	#RHEL7
	if [ `grep -i "minlen" /etc/security/pwquality.conf | grep -v '#' | awk '{print $3}'` -ge 8 ]; then
		echo "U-05,O,,"		>> $filepath 2>&1
		echo "패스워드 최소 길이가 8자 이상으로 설정되어 있음"	>> $filepath 2>&1
	else
		echo "U-05,X,,"		>> $filepath 2>&1
		echo "패스워드 최소 길이가 8자 미만으로 설정되어 있음"	>> $filepath 2>&1
	fi

	NewLine $filepath
	grep -i "minlen" /etc/security/pwquality.conf >> $filepath 2>&1
else
	if [ `cat /etc/login.defs | grep PASS_MIN_LEN | grep -v '#' | awk '{print $2}'` -ge 8 ]; then
		echo "U-05,O,," >> $filepath 2>&1
		echo "패스워드 최소 길이가 8자 이상으로 설정되어 있음"	>> $filepath 2>&1
	else
		echo "U-05,X,," >> $filepath 2>&1
		echo "패스워드 최소 길이가 8자 미만으로 설정되어 있음"	>> $filepath 2>&1
	fi

	NewLine $filepath
	grep -v '^ *#' /etc/login.defs | grep -i "PASS_MIN_LEN"	>> $filepath 2>&1
fi

NewLine $filepath




echo "U-06 Check Start..."
echo "■ U-06. 1. 계정관리 > 1.6 불필요한 계정 제거" >> $filepath 2>&1
echo "■ 기준: /etc/passwd 파일에 lp, uucp, nuucp 계정이 모두 제거되어 있으면 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

# 주요정보통신기반시설 기술적 취약점 분석평가 가이드에는 UID 100 이하 또는 60000 이상의 계정들은 시스템 계정으로 로그인이 필요없음이라고 서술됨
# 3개의 계정 외에 UID를 기준으로 진단하는 것을 고려
# 일반적으로 영향 없으나 업무 영향도 파악 후 삭제 권고

if [ `cat /etc/passwd | egrep "^lp|^uucp|^nuucp" | wc -l` -eq 0 ]; then
	echo "U-06,O,," >> $filepath 2>&1
	echo "lp, uucp, nuucp 계정이 존재하지 않음" >> $filepath 2>&1
else
	echo "U-06,X,," >> $filepath 2>&1
	echo "lp, uucp, nuucp 계정이 존재하므로 취약함" >> $filepath 2>&1
fi

cat /etc/passwd | egrep "^lp|^uucp|^nuucp"	>> $filepath 2>&1

NewLine $filepath


echo "U-07 Check Start..."
echo "■ U-07. 1. 계정관리 > 1.7 관리자 그룹에 최소한의 계정 포함" >> $filepath 2>&1
echo "■ 기준: 관리자 계정이 포함된 그룹에 불필요한 계정이 존재하지 않는 경우 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

echo "U-07,C,," >> $filepath 2>&1
echo "[수동진단]관리자 계정이 포함된 그룹에 불필요한 계정이 존재 유뮤 확인 필요"	>> $filepath 2>&1

echo "① 관리자 계정" >> $filepath 2>&1
DividingLine $filepath
if [ -f /etc/passwd ]; then
	# UID가 0인 계정 이름과 UID를 기록
	awk -F : '$3==0 { print $1 " -> UID=" $3 }' /etc/passwd	>> $filepath 2>&1
else
	echo "/etc/passwd 파일이 없음" >> $filepath 2>&1
fi

NewLine $filepath
echo "② 관리자 계정이 포함된 그룹 확인" >> $filepath 2>&1
DividingLine $filepath

# UID가 0인 계정으로 /etc/group의 내용을 검색해서 기록
for group in `awk -F: '$3==0 {print $1}' /etc/passwd`; do
	cat /etc/group | grep "$group"	>> $filepath 2>&1
done

NewLine $filepath



echo "U-08 Check Start..."
echo "■ U-08. 1. 계정관리 > 1.8 Session Timeout 설정" >> $filepath 2>&1
echo "■ 기준: /etc/profile 에서 TMOUT=600 이하 또는 /etc/csh.login 에서 autologout=10 이하로 설정되어 있으면 양호"	>> $filepath 2>&1
echo "  (1) sh, ksh, bash 쉘의 경우 /etc/profile 파일 설정을 적용받음" >> $filepath 2>&1
echo "  (2) csh, tcsh 쉘의 경우 /etc/csh.cshrc 또는 /etc/csh.login 파일 설정을 적용받음"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

# 모니터링 용도이면 업무가 불가능하므로 예외처리

# 쉘 확인
chkSH=`CheckShell`
case $chkSH in
	'sh'|'ksh'|'bash')
		# /etc/profile
		if [ -f /etc/profile ]; then
			# TMOUT이 600초 이하이면 양호
			if [ `cat /etc/profile | grep -i TMOUT | grep -v "^#" | awk -F "=" '{print $2}'` -le 600 ]; then
				echo "U-08,O,,"	>> $filepath 2>&1
				echo "TMOUT이 600초 이하로 설정되어 있음"	>> $filepath 2>&1
				cat /etc/profile | grep -i TMOUT | grep -v "^#"	>> $filepath 2>&1
			else
				echo "U-08,X,,"	>> $filepath 2>&1
				echo "TMOUT이 600초 초과하거나 설정이 없음" >> $filepath 2>&1
				cat /etc/profile | grep -i TMOUT	>> $filepath 2>&1
			fi
		else
			echo "U-08,X,,"	>> $filepath 2>&1
			echo "/etc/profile 파일이 없음"	>> $filepath 2>&1
		fi
		;;

	'csh'|'tcsh')
		# /etc/csh.cshrc 또는 /etc/csh.login
		if [ -f /etc/csh.cshrc ]; then
			# autologout이 10분 이하이면 양호
			if [ `cat /etc/csh.cshrc | grep -i autologout | grep -v "^#" | awk -F "=" '{print $2}'` -le 10 ]; then
				echo "U-08,O,,"	>> $filepath 2>&1
				echo "autologout이 10분 이하로 설정되어 있음"	>> $filepath 2>&1
				cat /etc/csh.cshrc | grep -i autologout	>> $filepath 2>&1

				break
			fi
		fi

		if [ -f /etc/csh.login ]; then
			# autologout이 10분 이하이면 양호
			if [ `cat /etc/csh.login | grep -i autologout | grep -v "^#" | awk -F "=" '{print $2}'` -le 10 ]; then
				echo "U-08,O,,"	>> $filepath 2>&1
				echo "autologout이 10분 이하로 설정되어 있음"	>> $filepath 2>&1
				cat /etc/csh.login | grep -i autologout	>> $filepath 2>&1
			else
				echo "U-08,X,,"	>> $filepath 2>&1
				echo "/etc/csh.cshrc과 /etc/csh.login 파일이 없거나 autologout이 10분 초과함"	>> $filepath 2>&1
			fi
		else
			echo "U-08,X,,"	>> $filepath 2>&1
			echo "/etc/csh.cshrc과 /etc/csh.login 파일이 없거나 autologout이 10분 초과함"	>> $filepath 2>&1
		fi
		;;

	*)
		echo "U-08,C,,"	>> $filepath 2>&1
		echo "정의된 쉘이 아니므로 수동 검사"	>> $filepath 2>&1
		;;
esac

NewLine $filepath



echo "U-09 Check Start..."
echo "■ U-09. 2. 파일 및 디렉토리 관리 > 2.1 root 홈, 패스 디렉터리 권한 및 패스 설정" >> $filepath 2>&1
echo "■ 기준: Path 설정에 "." 이 맨 앞이나 중간에 포함되어 있지 않을 경우 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

# $PATH의 끝에서 . 또는 :: 을 제외하고 있는지 확인 필요

# :: 판단
# :: 이 있는지 확인(수량도 같이 확인)
# :: 이 끝에 있는지 확인
case `echo $PATH | grep '::' | wc -l` in
	0)
		# . 판단

		# . 만 있는 위치
		checkPoint=-1

		# . 만 있는 위치의 총 개수
		TotalPoint=0

		# $PATH에 있는 경로 전체 개수
		LoopCount=0
		for i in $(echo $IN | tr ":" "\n"); do
			LoopCount=$((LoopCount + 1))

			# . 만 있는지 확인
			if [ "$i" = "." ]; then
				checkPoint=$LoopCount
				TotalPoint=$((TotalPoint + 1))
			fi
		done

		if [ $checkPoint -eq -1 ]; then
			# -1이면 .이 없음
			echo "U-09,O,,"	>> $filepath 2>&1
			echo "PATH 환경변수에 "." 이 맨 앞이나 중간에 포함되지 않음" >> $filepath 2>&1
		elif [ $TotalPoint -gt 1 ]; then
			# .만 있는 경로 개수가 1보다 큰 경우
			echo "U-09,X,,"	>> $filepath 2>&1
			echo "PATH 환경변수에 "." 이 맨 앞이나 중간에 포함되어 있음" >> $filepath 2>&1
		elif [ $checkPoint -eq $LoopCount ]; then
			# .만 있는 경로가 마지막에 있는 경우
			echo "U-09,O,,"	>> $filepath 2>&1
			echo "PATH 환경변수에 "." 이 맨 앞이나 중간에 포함되지 않음" >> $filepath 2>&1
		else
			# 나머지는 .만 있는 경로가 처음 또는 중간에 포함되는 경우
			echo "U-09,X,,"	>> $filepath 2>&1
			echo "PATH 환경변수에 "." 이 맨 앞이나 중간에 포함되어 있음" >> $filepath 2>&1
		fi
		;;

	1)
		# ::가 끝에 없으면 취약
		if [ `echo $PATH | grep '::$' | wc -l` -eq 1 ]; then
			echo "U-09,O,,"	>> $filepath 2>&1
			echo "PATH 환경변수에 "." 이 맨 앞이나 중간에 포함되지 않음" >> $filepath 2>&1
		else
			echo "U-09,X,,"	>> $filepath 2>&1
			echo "PATH 환경변수에 "." 이 맨 앞이나 중간에 포함되어 있음" >> $filepath 2>&1
		fi
		;;

	*)
		# ::가 2개 이상이므로 끝에 있어도 처음이나 중간에 있다고 판단하므로 취약
		echo "U-09,X,,"	>> $filepath 2>&1
		echo "PATH 환경변수에 "." 이 맨 앞이나 중간에 포함되어 있음" >> $filepath 2>&1
		;;
esac

echo "PATH 설정 확인"	>> $filepath 2>&1
DividingLine $filepath
echo $PATH	>> $filepath 2>&1

NewLine $filepath



echo "U-10 Check Start..."
echo "■ U-10.2. 파일 및 디렉토리 관리 > 2.2 /etc/passwd 파일 소유자 및 권한 설정" >> $filepath 2>&1
echo "■ 기준: /etc/passwd 파일의 소유자가 root 이고, 권한이 644 이하이면 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

# /etc/passwd 파일 유무 확인
if [ -f /etc/passwd ]; then
	# /etc/passwd 소유자 root 확인
	if [ `ls -alL /etc/passwd | awk '{print $3}'` = 'root' ]; then
		# /etc/passwd 권한이 644보다 높은지 확인
		if [ `stat -c %a /etc/passwd` -gt 644 ]; then
			echo "U-10,X,,"	>> $filepath 2>&1
			echo "/etc/passwd 파일의 소유자가 root이고 권한이 644보다 높음"	>> $filepath 2>&1
			ls -alL /etc/passwd	>> $filepath 2>&1
		else
			echo "U-10,O,,"	>> $filepath 2>&1
			echo "/etc/passwd 파일의 소유자가 root이고 권한이 644보다 낮거나 같음"	>> $filepath 2>&1
			ls -alL /etc/passwd	>> $filepath 2>&1
		fi
	else
		echo "U-10,X,,"	>> $filepath 2>&1
		echo "/etc/passwd 파일의 소유자가 root가 아님"	>> $filepath 2>&1
		ls -alL /etc/passwd	>> $filepath 2>&1
		NewLine $filepath
	fi
else
	echo "U-10,N/A,,"	>> $filepath 2>&1
	echo "[수동진단]/etc/passwd 파일이 없음"	>> $filepath 2>&1
fi

NewLine $filepath


echo "U-11 Check Start..."
echo "■ U-11. 2. 파일 및 디렉토리 관리 > 2.3 /etc/shadow 파일 소유자 및 권한 설정" >> $filepath 2>&1
echo "■ 기준: /etc/shadow 파일의 소유자가 root 이고, 권한이 400 이하이면 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

if [ -f /etc/shadow ]; then
	if [ `ls -alL /etc/shadow | awk '{print $3}'` = 'root' ]; then
		if [ `stat -c %a /etc/shadow` -le 400 ]; then
			echo "U-11,O,,"	>> $filepath 2>&1
			echo "/etc/shadow 파일의 소유자가 root이며 파일의 권한이 400보다 낮거나 같음"	>> $filepath 2>&1
			ls -alL /etc/shadow	>> $filepath 2>&1
		else
			echo "U-11,X,,"	>> $filepath 2>&1
			echo "/etc/shadow 파일의 소유자가 root이며 파일의 권한이 400보다 높음"	>> $filepath 2>&1
			ls -alL /etc/shadow	>> $filepath 2>&1
		fi
	else
		echo "U-11,X,,"	>> $filepath 2>&1
		echo "/etc/shadow 파일의 소유자가 root가 아님"	>> $filepath 2>&1
		ls -alL /etc/shadow	>> $filepath 2>&1
	fi
else
	echo "U-11,N/A,,"	>> $filepath 2>&1
	echo "[수동진단]/etc/shadow 파일이 없음"	>> $filepath 2>&1
fi

NewLine $filepath


echo "U-12 Check Start..."
echo "■ U-12. 2. 파일 및 디렉토리 관리 > 2.4 /etc/hosts 파일 소유자 및 권한 설정" >> $filepath 2>&1
echo "■ 기준: /etc/hosts 파일의 소유자가 root 이고, 권한이 600 이하이면 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

if [ -f /etc/hosts ]; then
	if [ `ls -alL /etc/hosts | awk '{print $3}'` = 'root' ]; then
		if [ `stat -c %a /etc/hosts` -le 600 ]; then
			echo "U-12,O,,"	>> $filepath 2>&1
			echo "/etc/hosts 파일의 소유자가 root이며 파일의 권한이 600보다 낮거나 같음"	>> $filepath 2>&1
			ls -alL /etc/hosts	>> $filepath 2>&1
		else
			echo "U-12,X,,"	>> $filepath 2>&1
			echo "/etc/hosts 파일의 소유자가 root이며 파일의 권한이 600보다 높음"	>> $filepath 2>&1
			ls -alL /etc/hosts	>> $filepath 2>&1
		fi
	else
		echo "U-12,X,,"	>> $filepath 2>&1
		echo "/etc/hosts 파일의 소유자가 root가 아님"	>> $filepath 2>&1
		ls -alL /etc/hosts	>> $filepath 2>&1
	fi
else
	echo "U-12,N/A,,"	>> $filepath 2>&1
	echo "[수동진단]/etc/hosts 파일이 없음"	>> $filepath 2>&1
fi

NewLine $filepath



echo "U-13 Check Start..."
echo "■ U-13. 2. 파일 및 디렉토리 관리 > 2.5 /etc/syslog.conf 파일 소유자 및 권한 설정"	>> $filepath 2>&1
echo "■ 기준: /etc/syslog.conf 파일의 소유자가 root(또는 bin, sys)이고 권한이 644 이하이면 양호"	>> $filepath 2>&1
echo "■ 현황"	>> $filepath 2>&1

# 기본적으로 /etc/syslog.conf를 확인
# Linux(CentOS 6 이상)이면 rsyslog.conf를 확인

if [ -f /etc/syslog.conf ]; then
	u08sysuser=`ls -alL /etc/syslog.conf | awk '{print $3}'`
	if [ $u08sysuser = 'root' ] || [ $u08sysuser = 'bin' ] || [ $u08sysuser = 'sys' ]; then
		if [ `stat -c %a /etc/syslog.conf` -gt 644 ]
		then
			echo "U-13,X,," >> $filepath 2>&1
			echo "/etc/syslog.conf 파일의 권한 확인 필요"	>> $filepath 2>&1
		else
			echo "U-13,O,," >> $filepath 2>&1
			echo "/etc/syslog.conf 파일의 소유자가 root|bin|sys이고 파일의 권한이 644보다 낮거나 같음"	>> $filepath 2>&1
		fi
	else
		echo "U-13,X,," >> $filepath 2>&1
		echo "/etc/syslog.conf 파일의 소유자가 root|bin|sys 중 1개도 아님"	>> $filepath 2>&1
	fi

	ls -alL /etc/syslog.conf	>> $filepath 2>&1
elif [ -f /etc/rsyslog.conf ]; then
	u08rsysuser=`ls -alL /etc/rsyslog.conf | awk '{print $3}'`
	if [ $u08rsysuser = 'root' ] || [ $u08rsysuser = 'bin' ] || [ $u08rsysuser = 'sys' ]; then
		if [ `stat -c %a /etc/rsyslog.conf` -gt 644 ]; then
			echo "U-13,X,," >> $filepath 2>&1
			echo "/etc/rsyslog.conf 파일의 소유자가 root|bin|sys이고 파일의 권한이 644보다 높음"	>> $filepath 2>&1
		else
			echo "U-13,O,," >> $filepath 2>&1
			echo "/etc/rsyslog.conf 파일의 소유자가 root|bin|sys이고 파일의 권한이 644보다 낮거나 같음"	>> $filepath 2>&1
		fi
	else
		echo "U-13,X,," >> $filepath 2>&1
		echo "/etc/rsyslog.conf 파일의 소유자가 root|bin|sys가 아닌 다른 소유자임"	>> $filepath 2>&1
	fi

	ls -alL /etc/rsyslog.conf	>> $filepath 2>&1
else
	echo "U-13,N/A,," >> $filepath 2>&1
	echo "/etc/syslog.conf 또는 /etc/rsyslog.conf 파일이 없음"	>> $filepath 2>&1
fi

NewLine $filepath


echo "U-14 Check Start..."
echo "■ U-14. 2. 파일 및 디렉토리 관리 > 2.6 /etc/services 파일 소유자 및 권한 설정"	>> $filepath 2>&1
echo "■ 기준: /etc/services 파일의 권한이 644 이하이면 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

if [ -f /etc/services ]; then
	if [ `ls -alL /etc/services | awk '{print $3}'` = 'root' ]; then
		if [ `stat -c %a /etc/services` -le 644 ]; then
			echo "U-14,O,,"	>> $filepath 2>&1
			echo "/etc/services 파일의 소유자가 root이고 파일의 권한이 644보다 낮거나 같음"	>> $filepath 2>&1
		else
			echo "U-14,X,,"	>> $filepath 2>&1
			echo "/etc/services 파일의 소유자가 root이고 파일의 권한이 644보다 높음" >> $filepath 2>&1
		fi
	else
		echo "U-14,X,,"	>> $filepath 2>&1
		echo "/etc/services 파일의 소유자가 root가 아님"	>> $filepath 2>&1
	fi

	ls -alL /etc/services	>> $filepath 2>&1
else
	echo "U-14,N/A,,"	>> $filepath 2>&1
	echo "/etc/services 파일이 없음"	>> $filepath 2>&1
fi

NewLine $filepath




echo "U-15 Check Start..."
echo "■ U-15. 2. 파일 및 디렉토리 관리 > 2.7 접속 IP 및 포트 제한"	>> $filepath 2>&1
echo "■ 기준: 접속을 허용할 특정 호스트에 대한 IP 주소 및 포트 제한을 설정한 경우 양호"	>> $filepath 2>&1
echo "■ 현황"	>> $filepath 2>&1

# 3가지 애플리케이션 확인
# 1. TCP Wrapper
# /etc/hosts.deny 파일에 ALL:ALL로 모두 차단
# 2. IPTables
# chain INPUT 에서 ACCEPT의 정책 확인
# 3. IPFilter
# /etc/ipf/ipf.conf 파일에 정책 확인


if [ -f /etc/hosts.deny ]; then
	if [ `cat /etc/hosts.deny | grep -v "#" | grep -E "ALL:.*ALL" | wc -l` -eq 0 ]; then
		echo "U-15,X,,"	>> $filepath 2>&1
		echo "/etc/hosts.deny 파일에 ALL Deny 설정이 존재하지 않음" >> $filepath 2>&1
	else
		echo "U-15,O,,"	>> $filepath 2>&1
		echo "/etc/hosts.deny 파일에 ALL Deny 설정이 적용됨" >> $filepath 2>&1

		echo "현황" >> $filepath 2>&1
		ls -l /etc/hosts.deny >> $filepath 2>&1
		cat /etc/hosts.deny | grep -v "#" >> $filepath 2>&1
		ls -l /etc/hosts.allow >> $filepath 2>&1
		cat /etc/hosts.allow | grep -v "#" >> $filepath 2>&1
	fi
else
	echo "U-15,X,,"	>> $filepath 2>&1
	echo "/etc/hosts.deny 파일이 존재하지 않음" >> $filepath 2>&1
fi

NewLine $filepath



echo "U-16 Check Start..."
echo "■ U-16. 2. 파일 및 디렉토리 관리 > 2.8 UMASK 설정 관리" >> $filepath 2>&1
echo "■ 기준: UMASK 값이 022 이면 양호" >> $filepath 2>&1
echo "       : (1) sh, ksh, bash 쉘의 경우 /etc/profile 파일 설정을 적용받음"	>> $filepath 2>&1
echo "       : (2) csh, tcsh 쉘의 경우 /etc/csh.cshrc 또는 /etc/csh.login 파일 설정을 적용받음" >> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

if [ -f /etc/profile ]; then
	echo "① /etc/profile 파일(올바른 설정: umask 022)"	>> $filepath 2>&1
	DividingLine $filepath
	if [ `cat /etc/profile | grep -i umask | grep -v ^# | wc -l` -gt 0 ]; then
		cat /etc/profile | grep -i umask | grep -v ^#	>> $filepath 2>&1
		echo "U-16,O,,"	>> $filepath 2>&1
		echo "UMASK 설정이 양호함"	>> $filepath 2>&1
	else
		echo "U-16,X,,"	>> $filepath 2>&1
		echo "UMASK 설정이 없음"	>> $filepath 2>&1
	fi
else
	echo "U-16,N/A,,"	>> $filepath 2>&1
	echo "/etc/profile 파일이 없음"	>> $filepath 2>&1
fi

NewLine $filepath



echo "U-17 Check Start..."
echo "■ U-17. 3. 서비스 관리 > 3.1 Finger 서비스 비활성화" >> $filepath 2>&1
echo "■ 기준: Finger 서비스가 비활성화 되어 있을 경우 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

if [ `cat /etc/services | awk -F" " '$1=="finger" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="finger" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | wc -l` -eq 0 ]; then
		echo "U-17,O,,"	>> $filepath 2>&1
		echo "Finger 서비스가 비활성화 되어 있음"	>> $filepath 2>&1
	else
		echo "U-17,X,,"	>> $filepath 2>&1
		echo "Finger 서비스가 활성화 되어 있음"	>> $filepath 2>&1
	fi
else
	if [ `netstat -na | grep ":79 " | grep -i "^tcp" | wc -l` -eq 0 ]; then
		echo "U-17,O,,"	>> $filepath 2>&1
		echo "Finger 서비스가 비활성화 되어 있음"	>> $filepath 2>&1
	else
		echo "U-17,X,,"	>> $filepath 2>&1
		echo "Finger 서비스가 활성화 되어 있음"	>> $filepath 2>&1
	fi
fi

NewLine $filepath
echo "① /etc/services 파일에서 포트 확인"	>> $filepath 2>&1
DividingLine $filepath

cat /etc/services | awk -F" " '$1=="finger" {print $1 "   " $2}' | grep "tcp"	>> $filepath 2>&1
NewLine $filepath
echo "② 서비스 포트 활성화 여부 확인"	>> $filepath 2>&1
DividingLine $filepath

if [ `cat /etc/services | awk -F" " '$1=="finger" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="finger" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | wc -l` -eq 0 ]; then
		NewLine $filepath
	else
		netstat -na | grep ":$port " | grep -i "^tcp"	>> $filepath 2>&1
	fi
else
	if [ `netstat -na | grep ":79 " | grep -i "^tcp" | wc -l` -eq 0 ]; then
		NewLine $filepath
	else
		netstat -na | grep ":79 " | grep -i "^tcp"	>> $filepath 2>&1
	fi
fi

NewLine $filepath


echo "U-18 Check Start..."
echo "■ U-18. 3. 서비스 관리 > 3.2 Anonymous FTP 비활성화" >> $filepath 2>&1
echo "■ 기준: Anonymous FTP (익명 ftp)를 비활성화 시켰을 경우 양호"	>> $filepath 2>&1
echo "(1)ftpd를 사용할 경우: /etc/passwd 파일내 FTP 또는 anonymous 계정이 존재하지 않으면 양호"	>> $filepath 2>&1
echo "(2)proftpd를 사용할 경우: /etc/passwd 파일내 FTP 계정이 존재하지 않으면 양호" >> $filepath 2>&1
echo "(3)vsftpd를 사용할 경우: vsftpd.conf 파일에서 anonymous_enable=NO 설정이면 양호" >> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1


echo "U-18,C,,"	>> $filepath 2>&1
NewLine $filepath
echo "① /etc/services 파일에서 포트 확인"	>> $filepath 2>&1
DividingLine $filepath

if [ `cat /etc/services | awk -F" " '$1=="ftp" {print "(1)/etc/service파일:" $1 " " $2}' | grep "tcp" | wc -l` -gt 0 ]; then
	cat /etc/services | awk -F" " '$1=="ftp" {print "(1)/etc/service파일:" $1 " " $2}' | grep "tcp" >> $filepath 2>&1
else
	echo "(1)/etc/service파일: 포트 설정 X (Default 21번 포트)"	>> $filepath 2>&1
fi

if [ -s vsftpd.txt ]; then
	if [ `cat $vsfile | grep "listen_port" | grep -v "^#" | awk '{print "(3)VsFTP 포트: " $1 "  " $2}' | wc -l` -gt 0 ]; then
		cat $vsfile | grep "listen_port" | grep -v "^#" | awk '{print "(3)VsFTP 포트: " $1 "  " $2}' >> $filepath 2>&1
	else
		echo "(2)VsFTP 포트: 포트 설정 X (Default 21번 포트 사용중)"	>> $filepath 2>&1
	fi
else
	echo "(2)VsFTP 포트: VsFTP가 설치되어 있지 않음"	>> $filepath 2>&1
fi

if [ -s proftpd.txt ]; then
	if [ `cat $profile | grep "Port" | grep -v "^#" | awk '{print "(2)ProFTP 포트: " $1 "  " $2}' | wc -l` -gt 0 ]; then
		cat $profile | grep "Port" | grep -v "^#" | awk '{print "(2)ProFTP 포트: " $1 "  " $2}'    >> $filepath 2>&1
	else
		echo "(3)ProFTP 포트: 포트 설정 X (/etc/service 파일에 설정된 포트를 사용중)"	>> $filepath 2>&1
	fi
else
	echo "(3)ProFTP 포트: ProFTP가 설치되어 있지 않음"	>> $filepath 2>&1
fi

NewLine $filepath
echo "② 서비스 포트 활성화 여부 확인"	>> $filepath 2>&1
DividingLine $filepath
################# /etc/services 파일에서 포트 확인 #################
if [ `cat /etc/services | awk -F" " '$1=="ftp" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="ftp" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`

	if [ `netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]; then
		netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN"	>> $filepath 2>&1
		NewLine ftpenable.txt
	fi
else
	netstat -nat | grep ":21 " | grep -i "^tcp" | grep -i "LISTEN"	>> $filepath 2>&1
	NewLine ftpenable.txt
fi

################# vsftpd 에서 포트 확인 ############################
if [ -s vsftpd.txt ]; then
	if [ `cat $vsfile | grep "listen_port" | grep -v "^#" | awk -F"=" '{print $2}' | wc -l` -eq 0 ]; then
		port=21
	else
		port=`cat $vsfile | grep "listen_port" | grep -v "^#" | awk -F"=" '{print $2}'`
	fi

	if [ `netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]; then
		netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN"	>> $filepath 2>&1
		NewLine ftpenable.txt
	fi
fi

################# proftpd 에서 포트 확인 ###########################
if [ -s proftpd.txt ]; then
	port=`cat $profile | grep "Port" | grep -v "^#" | awk '{print $2}'`

	if [ `netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]; then
		netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN"	>> $filepath 2>&1
		NewLine ftpenable.txt
	fi
fi

if [ -f ftpenable.txt ]; then
	rm -f ftpenable.txt
else
	echo "FTP Service Disable"	>> $filepath 2>&1
fi

NewLine $filepath
echo "③ Anonymous FTP 설정 확인"	>> $filepath 2>&1
DividingLine $filepath

if [ -s vsftpd.txt ]; then
	cat $vsfile | grep -i "anonymous_enable" | awk '{print "● VsFTP 설정: " $0}'	>> $filepath 2>&1
fi

if [ `cat /etc/passwd | egrep "^ftp:|^anonymous:" | wc -l` -gt 0 ]; then
	echo "● ProFTP, 기본FTP 설정:"	>> $filepath 2>&1
	cat /etc/passwd | egrep "^ftp:|^anonymous:"	>> $filepath 2>&1
	NewLine $filepath
else
	echo "● ProFTP, 기본FTP 설정: /etc/passwd 파일에 ftp 또는 anonymous 계정이 없음"	>> $filepath 2>&1
fi

NewLine $filepath


echo "U-19 Check Start..."
echo "■ U-19. 3. 서비스 관리 > 3.3 r 계열 서비스 비활성화" >> $filepath 2>&1
echo "■ 기준: r-commands 서비스를 사용하지 않으면 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

if [ `cat /etc/services | awk -F" " '$1=="login" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="login" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | wc -l` -gt 0 ]; then
		NewLine rcommand.txt
	fi
fi

if [ `cat /etc/services | awk -F" " '$1=="shell" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="shell" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`

	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | wc -l` -gt 0 ]; then
		NewLine rcommand.txt
	fi
fi

if [ `cat /etc/services | awk -F" " '$1=="exec" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="exec" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`

	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | wc -l` -gt 0 ]; then
		NewLine rcommand.txt
	fi
fi

if [ -f rcommand.txt ]; then
	rm -f rcommand.txt
	echo "U-19,X,," >> $filepath 2>&1
	echo "r 계열 서비스가 활성화 되어 있음" >> $filepath 2>&1
else
	echo "U-19,O,," >> $filepath 2>&1
	echo "r 계열 서비스가 비활성화 되어 있음"	>> $filepath 2>&1
fi


echo "① /etc/services 파일에서 포트 확인"	>> $filepath 2>&1
DividingLine $filepath

cat /etc/services | awk -F" " '$1=="login" {print $1 "   " $2}' | grep "tcp"	>> $filepath 2>&1
cat /etc/services | awk -F" " '$1=="shell" {print $1 "   " $2}' | grep "tcp"	>> $filepath 2>&1
cat /etc/services | awk -F" " '$1=="exec" {print $1 "    " $2}' | grep "tcp"	>> $filepath 2>&1

NewLine $filepath
echo "② 서비스 포트 활성화 여부 확인(서비스 중지시 결과 값 없음)"	>> $filepath 2>&1
DividingLine $filepath

if [ `cat /etc/services | awk -F" " '$1=="login" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="login" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | wc -l` -gt 0 ]; then
		netstat -na | grep ":$port " | grep -i "^tcp"	>> $filepath 2>&1
	fi
fi

if [ `cat /etc/services | awk -F" " '$1=="shell" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="shell" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | wc -l` -gt 0 ]; then
		netstat -na | grep ":$port " | grep -i "^tcp"	>> $filepath 2>&1
	fi
fi

if [ `cat /etc/services | awk -F" " '$1=="exec" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="exec" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | wc -l` -gt 0 ]; then
		netstat -na | grep ":$port " | grep -i "^tcp"	>> $filepath 2>&1
	fi
fi

NewLine $filepath


echo "U-20 Check Start..."
echo "■ U-20. 3. 서비스 관리 > 3.4 cron 파일 소유자 및 권한 설정" >> $filepath 2>&1
echo "■ 기준: cron.allow 또는 cron.deny 파일 권한이 640 이하이면 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

# 1 : 파일이 없음
# 2 : 파일 권한 양호
# 3 : 파일 권한 취약
U14_ALLOW=0
U14_DENY=0

if [ -f /etc/cron.allow ]; then
	if [ `stat -c %a /etc/cron.allow` -le 640 ]; then
		U14_ALLOW=2
	else
		U14_ALLOW=3
	fi
else
	U14_ALLOW=1
fi

if [ -f /etc/cron.deny ]; then
	if [ `stat -c %a /etc/cron.deny` -le 640 ]; then
		U14_DENY=2
	else
		U14_DENY=3
	fi
else
	U14_DENY=1
fi

if [ $U14_ALLOW -eq 1 -a $U14_DENY -eq 1 ]; then
	echo "U-20,O,," >> $filepath 2>&1
	echo "cron.allow와 cron.deny 파일이 없음"	>> $filepath 2>&1
elif [ $U14_ALLOW -eq 3 -o $U14_DENY -eq 3 ]; then
	echo "U-20,X,," >> $filepath 2>&1
	echo "cron.allow 또는 cron.deny 파일이 권한이 640보다 높음"	>> $filepath 2>&1
else
	echo "U-20,O,," >> $filepath 2>&1
	echo "cron.allow와 cron.deny 파일의 권한이 640보다 낮거나 같음"	>> $filepath 2>&1
fi

if [ $U14_ALLOW -ne 1 ]; then
	ls -l /etc/cron.allow	>> $filepath 2>&1
fi

if [ $U14_DENY -ne 1 ]; then
	ls -l /etc/cron.deny	>> $filepath 2>&1
fi

NewLine $filepath



echo "U-21 Check Start..."
echo "■ U-21. 3. 서비스 관리 > 3.5 NFS 서비스 비활성화" 		>> $filepath 2>&1
echo "■ 기준: 불필요한 NFS 서비스 관련 데몬이 제거되어 있는 경우 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

if [ `ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" | wc -l` -gt 0 ]; then
	echo "U-21,X,,"	>> $filepath 2>&1
	echo "NFS 서비스 관련 데몬이 활성화 되어 있음"	>> $filepath 2>&1
	echo "NFS Server Daemon(nfsd)확인"	>> $filepath 2>&1

	ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep"	>> $filepath 2>&1
else
	if [ `ps -ef | egrep "statd|lockd" | egrep -v "grep|emi|statdaemon|dsvclockd" | wc -l` -gt 0 ]; then
		echo "U-21,X,,"	>> $filepath 2>&1
		echo "NFS 서비스 관련 데몬이 활성화 되어 있음"	>> $filepath 2>&1
		echo "NFS Client Daemon(statd,lockd)확인"	>> $filepath 2>&1

		ps -ef | egrep "statd|lockd" | egrep -v "grep|emi|statdaemon|dsvclockd"	>> $filepath 2>&1
	else
		echo "U-21,O,,"	>> $filepath 2>&1
		echo "NFS 서비스 관련 데몬이 비활성화 되어 있음"	>> $filepath 2>&1
	fi
fi

NewLine $filepath


echo "U-22 Check Start..."
echo "■ U-22. 3. 서비스 관리 > 3.6 NFS 접근통제" >> $filepath 2>&1
echo "■ 기준: NFS 서버 데몬이 동작하지 않으면 양호"	>> $filepath 2>&1
echo "■ 기준: NFS 서버 데몬이 동작하는 경우 /etc/exports 파일에 everyone 공유 설정이 없으면 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

# (취약 예문) /tmp/test/share *(rw)
if [ `ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" | wc -l` -gt 0 ]; then
	echo "U-22,C,,"	>> $filepath 2>&1
	echo "① NFS Server Daemon(nfsd)확인"	>> $filepath 2>&1
	DividingLine $filepath

	ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep"	>> $filepath 2>&1

	if [ -f /etc/exports ]; then
		if [ `cat /etc/exports | grep -v "^#" | grep -v "^ *$" | wc -l` -gt 0 ]; then
			echo "U-22,X,,"	>> $filepath 2>&1
			echo "NFS 서버 데몬이 동작하는 경우 /etc/exports 파일에 everyone 공유 설정이 있음"	>> $filepath 2>&1
			echo "② /etc/exports 파일 설정"	>> $filepath 2>&1
			DividingLine $filepath

			cat /etc/exports | grep -v "^#" | grep -v "^ *$"	>> $filepath 2>&1
		else
			echo "U-22,O,,"	>> $filepath 2>&1
			echo "NFS 서버 데몬이 동작하는 경우 /etc/exports 파일에 everyone 공유 설정이 없음"	>> $filepath 2>&1
		fi
	else
		echo "U-22,N/A,,"	>> $filepath 2>&1
		echo "/etc/exports 파일이 없음"	>> $filepath 2>&1
	fi
 else
	echo "U-22,O,,"	>> $filepath 2>&1
	echo "NFS 서버 데몬이 동작하지 않음"	>> $filepath 2>&1
fi

NewLine $filepath


echo "U-23 Check Start..."
echo "■ U-23. 3. 서비스 관리 > 3.7 automountd 제거" >> $filepath 2>&1
echo "■ 기준: automountd 서비스가 동작하지 않을 경우 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

# automount 서비스를 찾기 위해 automount 또는 autofs로 검색
# 목록 중에 grep, statdaemon, emi 제외하고 출력
if [ `ps -ef | egrep 'automount|autofs' | grep -v "grep" | egrep -v "statdaemon|emi" | wc -l` -gt 0 ]; then
	echo "U-23,X,,"	>> $filepath 2>&1
	echo "automountd 서비스가 활성화 되어 있음"	>> $filepath 2>&1
else
	echo "U-23,O,,"	>> $filepath 2>&1
	echo "automountd 서비스가 비활성화 되어 있음"	>> $filepath 2>&1
fi

echo "① Automountd Daemon 확인"	>> $filepath 2>&1
DividingLine $filepath

ps -ef | egrep 'automount|autofs' | grep -v "grep" | egrep -v "statdaemon|emi"	>> $filepath 2>&1

NewLine $filepath


echo "U-24 Check Start..."
echo "■ U-24. 3. 서비스 관리 > 3.8 RPC 서비스 확인" >> $filepath 2>&1
echo "■ 기준: 불필요한 rpc 관련 서비스가 존재하지 않으면 양호"	>> $filepath 2>&1
echo "(rpc.cmsd|rpc.ttdbserverd|sadmind|rusersd|walld|sprayd|rstatd|rpc.nisd|rpc.pcnfsd|rpc.statd|rpc.ypupdated|rpc.rquotad|kcms_server|cachefsd|rexd)" >> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

SERVICE_INETD="rpc.cmsd|rpc.ttdbserverd|sadmind|rusersd|walld|sprayd|rstatd|rpc.nisd|rpc.pcnfsd|rpc.statd|rpc.ypupdated|rpc.rquotad|kcms_server|cachefsd|rexd"

if [ -d /etc/xinetd.d ]; then
	if [ `ls -alL /etc/xinetd.d/* | egrep $SERVICE_INETD | wc -l` -eq 0 ]; then
		echo "U-24,O,,"	>> $filepath 2>&1
		echo "불필요한 RPC 서비스가 비활성화 되어있음"	>> $filepath 2>&1
	else
		echo "U-24,X,,"	>> $filepath 2>&1
		echo "불필요한 RPC 서비스가 활성화 되어있음"	>> $filepath 2>&1
		echo "불필요한 RPC 서비스 동작 확인"	>> $filepath 2>&1
		DividingLine $filepath
	fi
		ls -alL /etc/xinetd.d/* | egrep $SERVICE_INETD	>> $filepath 2>&1
else
	echo "U-24,O,,"	>> $filepath 2>&1
	echo "/etc/xinetd.d 디렉터리가 존재하지 않음"	>> $filepath 2>&1
fi

NewLine $filepath



echo "U-25 Check Start..."
echo "■ U-25. 3. 서비스 관리 > 3.9 tftp, talk 서비스 비활성화" >> $filepath 2>&1
echo "■ 기준: tftp, talk, ntalk 서비스가 구동 중이지 않을 경우에 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

if [ `cat /etc/services | awk -F" " '$1=="tftp" {print $1 "   " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="tftp" {print $1 "   " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -na | grep ":$port " | grep -i "^udp" | wc -l` -gt 0 ]; then
		NewLine 1.25.txt
	fi
fi

if [ `cat /etc/services | awk -F" " '$1=="talk" {print $1 "   " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="talk" {print $1 "   " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -na | grep ":$port " | grep -i "^udp" | wc -l` -gt 0 ]; then
		NewLine 1.25.txt
	fi
fi

if [ `cat /etc/services | awk -F" " '$1=="ntalk" {print $1 "   " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="ntalk" {print $1 "   " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -na | grep ":$port " | grep -i "^udp" | wc -l` -gt 0 ]; then
		NewLine 1.25.txt
	fi
fi

if [ -f 1.25.txt ]; then
	rm -f 1.25.txt
	echo "U-25,X,,"		>> $filepath 2>&1
	echo "tftp, talk, ntalk 서비스가 활성화 되어 있음"	>> $filepath 2>&1
else
	echo "U-25,O,,"		>> $filepath 2>&1
	echo "tftp, talk, ntalk 서비스가 비활성화 되어 있음"	>> $filepath 2>&1
fi

echo "① /etc/services 파일에서 포트 확인"	>> $filepath 2>&1
DividingLine $filepath

cat /etc/services | awk -F" " '$1=="tftp" {print $1 "   " $2}' | grep "udp"	>> $filepath 2>&1
cat /etc/services | awk -F" " '$1=="talk" {print $1 "   " $2}' | grep "udp"	>> $filepath 2>&1
cat /etc/services | awk -F" " '$1=="ntalk" {print $1 "  " $2}' | grep "udp"	>> $filepath 2>&1

NewLine $filepath
echo "② 서비스 포트 활성화 여부 확인"	>> $filepath 2>&1
DividingLine $filepath

if [ `cat /etc/services | awk -F" " '$1=="tftp" {print $1 "   " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="tftp" {print $1 "   " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -na | grep ":$port " | grep -i "^udp" | wc -l` -gt 0 ]; then
		netstat -na | grep ":$port " | grep -i "^udp"	>> $filepath 2>&1
	fi
fi

if [ `cat /etc/services | awk -F" " '$1=="talk" {print $1 "   " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="talk" {print $1 "   " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -na | grep ":$port " | grep -i "^udp" | wc -l` -gt 0 ]; then
		netstat -na | grep ":$port " | grep -i "^udp"	>> $filepath 2>&1
	fi
fi

if [ `cat /etc/services | awk -F" " '$1=="ntalk" {print $1 "   " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="ntalk" {print $1 "   " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -na | grep ":$port " | grep -i "^udp" | wc -l` -gt 0 ]; then
		netstat -na | grep ":$port " | grep -i "^udp"	>> $filepath 2>&1
	fi
fi

NewLine $filepath





echo "U-26 Check Start..."
echo "■ U-26. 3. 서비스 관리 > 3.10 ssh 원격접속 허용" >> $filepath 2>&1
echo "■ 기준: SSH 서비스가 활성화 되어 있으면 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

NewFile ssh.txt
ServiceDIR="/etc/sshd_config /etc/ssh/sshd_config /usr/local/etc/sshd_config /usr/local/sshd/etc/sshd_config /usr/local/ssh/etc/sshd_config"
for file in $ServiceDIR; do
	if [ -f $file ]; then
		if [ `cat $file | grep ^Port | grep -v ^# | wc -l` -gt 0 ]; then
			cat $file | grep ^Port | grep -v ^# | awk '{print "SSH 설정파일('${file}'): " $0 }'		>> ssh.txt
			port1=`cat $file | grep ^Port | grep -v ^# | awk '{print $2}'`
			NewLine port1-search.txt
		else
			echo "SSH 설정파일($file): 포트 설정 X (Default 설정: 22포트 사용)"	>> ssh.txt
		fi
	fi
done

# 서비스 포트 점검
# ③ 서비스 포트 활성화 여부 확인
DividingLine $filepath

if [ -f port1-search.txt ]; then
	if [ `netstat -na | grep ":$port1 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -eq 0 ]; then
		echo "U-26,X,,"	>> $filepath 2>&1
		echo "원격 접속 시 SSH 프로토콜을 사용하지 않음"	>> $filepath 2>&1
	else
		echo "U-26,O,,"	>> $filepath 2>&1
		echo "원격 접속 시 SSH 프로토콜을 사용함"	>> $filepath 2>&1
		NewLine $filepath

		netstat -na | grep ":$port1 " | grep -i "^tcp" | grep -i "LISTEN"	>> $filepath 2>&1
	fi
else
	if [ `netstat -na | grep ":22 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -eq 0 ]; then
		echo "U-26,X,,"	>> $filepath 2>&1
		echo "원격 접속 시 SSH 프로토콜을 사용하지 않음"	>> $filepath 2>&1
	else
		echo "U-26,O,,"	>> $filepath 2>&1
		echo "원격 접속 시 SSH 프로토콜을 사용함"	>> $filepath 2>&1
		NewLine $filepath

		netstat -na | grep ":22 " | grep -i "^tcp" | grep -i "LISTEN"	>> $filepath 2>&1
	fi
fi

rm -f port1-search.txt
rm -f ssh.txt

NewLine $filepath




echo "U-27 Check Start..."
echo "■ U-27. 3. 서비스 관리 > 3.11 ftpusers 파일 설정" >> $filepath 2>&1
echo "■ 기준: ftp 를 사용하지 않거나, ftp 사용시 ftpusers 파일에 root가 있을 경우 양호" >> $filepath 2>&1
echo "  [FTP 종류별 적용되는 파일]" >> $filepath 2>&1
echo "  (1)ftpd: /etc/ftpusers 또는 /etc/ftpd/ftpusers" >> $filepath 2>&1
echo "  (2)proftpd: /etc/ftpusers 또는 /etc/ftpd/ftpusers" >> $filepath 2>&1
echo "  (3)vsftpd: /etc/vsftpd/ftpusers, /etc/vsftpd/user_list (또는 /etc/vsftpd.ftpusers, /etc/vsftpd.user_list)" >> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

U30log=U30log.txt
echo "① /etc/services 파일에서 포트 확인"	>> $U30log 2>&1
DividingLine $U30log

if [ `cat /etc/services | awk -F" " '$1=="ftp" {print "(1)/etc/service파일:" $1 " " $2}' | grep "tcp" | wc -l` -gt 0 ]; then
	cat /etc/services | awk -F" " '$1=="ftp" {print "(1)/etc/service파일:" $1 " " $2}' | grep "tcp" >> $U30log 2>&1
else
	echo "(1)/etc/service파일: 포트 설정 X (Default 21번 포트)"	>> $U30log 2>&1
fi

if [ -s vsftpd.txt ]; then
	if [ `cat $vsfile | grep "listen_port" | grep -v "^#" | awk '{print "(3)VsFTP 포트: " $1 "  " $2}' | wc -l` -gt 0 ]; then
		cat $vsfile | grep "listen_port" | grep -v "^#" | awk '{print "(3)VsFTP 포트: " $1 "  " $2}' >> $U30log 2>&1
	else
		echo "(2)VsFTP 포트: 포트 설정 X (Default 21번 포트 사용중)"	>> $U30log 2>&1
	fi
else
	echo "(2)VsFTP 포트: VsFTP가 설치되어 있지 않음"	>> $U30log 2>&1
fi

if [ -s proftpd.txt ]; then
	if [ `cat $profile | grep "Port" | grep -v "^#" | awk '{print "(2)ProFTP 포트: " $1 "  " $2}' | wc -l` -gt 0 ]; then
		cat $profile | grep "Port" | grep -v "^#" | awk '{print "(2)ProFTP 포트: " $1 "  " $2}'	>> $U30log 2>&1
	else
		echo "(3)ProFTP 포트: 포트 설정 X (/etc/service 파일에 설정된 포트를 사용중)"	>> $U30log 2>&1
	fi
else
	echo "(3)ProFTP 포트: ProFTP가 설치되어 있지 않음"	>> $U30log 2>&1
fi

#NewLine $filepath
echo "② 서비스 포트 활성화 여부 확인"	>> $U30log 2>&1
DividingLine $U30log

################# /etc/services 파일에서 포트 확인 #################
if [ `cat /etc/services | awk -F" " '$1=="ftp" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="ftp" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]; then
		netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN"	>> $U30log 2>&1
		NewLine ftpenable.txt
	fi
else
	netstat -nat | grep ":21 " | grep -i "^tcp" | grep -i "LISTEN"	>> $U30log 2>&1
	NewLine ftpenable.txt
fi

################# vsftpd 에서 포트 확인 ############################
if [ -s vsftpd.txt ]; then
	if [ `cat $vsfile | grep "listen_port" | grep -v "^#" | awk -F"=" '{print $2}' | wc -l` -eq 0 ]; then
		port=21
	else
		port=`cat $vsfile | grep "listen_port" | grep -v "^#" | awk -F"=" '{print $2}'`
	fi

	if [ `netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]; then
		netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN"	>> $U30log 2>&1
		NewLine ftpenable.txt
	fi
fi

################# proftpd 에서 포트 확인 ###########################
if [ -s proftpd.txt ]; then
	port=`cat $profile | grep "Port" | grep -v "^#" | awk '{print $2}'`
	if [ `netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]; then
		netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN"	>> $U30log 2>&1
		NewLine ftpenable.txt
	fi
fi

if [ -f ftpenable.txt ]; then
	echo "③ ftpusers 파일 설정 확인"	>> $U30log 2>&1
	DividingLine $U30log
	NewLine ftpusers.txt

	ServiceDIR="/etc/ftpusers /etc/ftpd/ftpusers /etc/vsftpd/ftpusers /etc/vsftpd.ftpusers /etc/vsftpd/user_list /etc/vsftpd.user_list"

	for file in $ServiceDIR; do
		if [ -f $file ]; then
			if [ `cat $file | grep "root" | grep -v "^#" | wc -l` -gt 0 ]; then
				echo "● $file 파일내용: `cat $file | grep "root" | grep -v "^#"` 계정이 등록되어 있음."  >> ftpusers.txt
				echo "U-27,O,,"	>> $filepath 2>&1
				echo "FTP 서비스가 활성화 되어 있는 경우 root 계정 접속을 차단함"	>> $filepath 2>&1
			else
				echo "● $file 파일내용: root 계정이 등록되어 있지 않음."	>> ftpusers.txt
				echo "U-27,X,,"	>> $filepath 2>&1
				echo "FTP 서비스가 활성화 되어 있는 경우 root 계정 접속을 허용함"	>> $filepath 2>&1
			fi
		fi
	done
else
	echo "U-27,O,,"	>> $filepath 2>&1
	echo "FTP 서비스가 비활성화 되어 있음"	>> $filepath 2>&1
fi

#진단에 필요한 정보를 추가
NewLine $filepath
cat $U30log >> $filepath 2>&1

if [ -f check.txt ]; then
	cat ftpusers.txt | grep -v "^ *$"	>> $filepath 2>&1
else
	echo "ftpusers 파일을 찾을 수 없음 (FTP 서비스 동작 시 취약)"	>> $filepath 2>&1
fi

#파일 정리
rm -f ftpenable.txt
rm -f ftpusers.txt
rm -f check.txt
rm -f $U30log

NewLine $filepath




echo "U-28 Check Start..."
echo "■ U-28. 3. 서비스 관리 > 3.12 SNMP 서비스 구동 점검" >> $filepath 2>&1
echo "■ 기준: SNMP 서비스를 불필요한 용도로 사용하지 않을 경우 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

# SNMP서비스는 동작시 /etc/service 파일의 포트를 사용하지 않음.
if [ `netstat -na | grep ":161 " | grep -i "^udp" | wc -l` -eq 0 ]; then
	echo "U-28,O,,"	>> $filepath 2>&1
	echo "SNMP 서비스를 사용하지 않음"	>> $filepath 2>&1
	DividingLine $filepath

	netstat -na | grep ":161 " | grep -i "^udp"	>> $filepath 2>&1
else
	echo "U-28,X,,"	>> $filepath 2>&1
	echo "SNMP 서비스를 사용함"	>> $filepath 2>&1
	echo "SNMP 서비스 활성화 여부 확인(UDP 161)"	>> $filepath 2>&1
	DividingLine $filepath

	netstat -na | grep ":161 " | grep -i "^udp"	>> $filepath 2>&1
fi

NewLine $filepath



echo "U-29 Check Start..."
echo "■ U-29. 3. 서비스 관리 > 3.13 SNMP 서비스 Community String의 복잡성 설정" >> $filepath 2>&1
echo "■ 기준: SNMP Community 이름이 public, private 이 아닐 경우 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

echo "① SNMP 서비스 활성화 여부 확인(UDP 161)"	>> $filepath 2>&1
DividingLine $filepath

if [ `netstat -na | grep ":161 " | grep -i "^udp" | wc -l` -eq 0 ]; then
	echo "U-29,O,,"	>> $filepath 2>&1
	echo "SNMP 서비스를 사용하지 않음"	>> $filepath 2>&1
else
	echo "U-29,C,,"	>> $filepath 2>&1
	netstat -na | grep ":161 " | grep -i "^udp"	>> $filepath 2>&1

	echo "② SNMP Community String 설정 값"	>> $filepath 2>&1
	DividingLine $filepath

	if [ -f /etc/snmpd.conf ]; then
		echo "● /etc/snmpd.conf 파일 설정:"	>> $filepath 2>&1
		DividingLine $filepath

		cat /etc/snmpd.conf | grep -E -i "public|private|com2sec|community" | grep -v "^#" >> $filepath 2>&1

		NewLine $filepath

		NewLine snmpd.txt
	fi

	if [ -f /etc/snmp/snmpd.conf ]; then
		echo "● /etc/snmp/snmpd.conf 파일 설정:"	>> $filepath 2>&1
		DividingLine $filepath

		cat /etc/snmp/snmpd.conf | grep -E -i "public|private|com2sec|community" | grep -v "^#" >> $filepath 2>&1

		NewLine $filepath

		NewLine snmpd.txt
	fi

	if [ -f /etc/snmp/conf/snmpd.conf ]; then
		echo "● /etc/snmp/conf/snmpd.conf 파일 설정:"	>> $filepath 2>&1
		DividingLine $filepath

		cat /etc/snmp/conf/snmpd.conf | grep -E -i "public|private|com2sec|community" | grep -v "^#" >> $filepath 2>&1

		NewLine $filepath

		NewLine snmpd.txt
	fi

	if [ -f /SI/CM/config/snmp/snmpd.conf ]; then
		echo "● /SI/CM/config/snmp/snmpd.conf 파일 설정:"	>> $filepath 2>&1
		DividingLine $filepath

		cat /SI/CM/config/snmp/snmpd.conf | grep -E -i "public|private|com2sec|community" | grep -v "^#" >> $filepath 2>&1

		NewLine $filepath

		NewLine snmpd.txt
	fi

	if [ -f snmpd.txt ]; then
		rm -f snmpd.txt
	else
		NewLine $filepath
	fi
fi

NewLine $filepath


echo "U-30 Check Start..."
echo "■ U-30. 3. 서비스 관리 > 3.14 ftp 서비스 확인" >> $filepath 2>&1
echo "■ 기준: ftp 서비스가 비활성화 되어 있을 경우 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

if [ `cat /etc/services | awk -F" " '$1=="ftp" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="ftp" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]; then
		echo "U-30,X,," >> $filepath 2>&1
		echo "FTP 서비스가 활성화 되어 있음"	>> $filepath 2>&1
	else
		echo "U-30,O,," >> $filepath 2>&1
		echo "FTP 서비스가 비활성화 되어 있음"	>> $filepath 2>&1
	fi
else
	if [ `netstat -nat | grep ":21 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]; then
		echo "U-30,X,,"	>> $filepath 2>&1
		echo "FTP 서비스가 활성화 되어 있음"	>> $filepath 2>&1
	else
		echo "U-30,O,," >> $filepath 2>&1
		echo "FTP 서비스가 비활성화 되어 있음"	>> $filepath 2>&1
	fi
fi

echo "① /etc/services 파일에서 포트 확인"	>> $filepath 2>&1
DividingLine $filepath

if [ `cat /etc/services | awk -F" " '$1=="ftp" {print "(1)/etc/service파일:" $1 " " $2}' | grep "tcp" | wc -l` -gt 0 ]; then
	cat /etc/services | awk -F" " '$1=="ftp" {print "(1)/etc/service파일:" $1 " " $2}' | grep "tcp" >> $filepath 2>&1
else
	echo "(1)/etc/service파일: 포트 설정 X (Default 21번 포트)"	>> $filepath 2>&1
fi

NewLine $filepath
echo "② 서비스 포트 활성화 여부 확인"	>> $filepath 2>&1
DividingLine $filepath

################# /etc/services 파일에서 포트 확인 #################
if [ `cat /etc/services | awk -F" " '$1=="ftp" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="ftp" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]; then
		netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN"	>> $filepath 2>&1
		NewLine ftpenable.txt
	else
		NewLine ftpenable.txt
	fi
else
	if [ `netstat -nat | grep ":21 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]; then
		netstat -nat | grep ":21 " | grep -i "^tcp" | grep -i "LISTEN"	>> $filepath 2>&1
	else
		NewLine ftpenable.txt
	fi
fi

rm -f ftpenable.txt

NewLine $filepath



echo "U-31 Check Start..."
echo "■ U-31. 3. 서비스 관리 > 3.15 ftpusers 파일 소유자 및 권한 설정" >> $filepath 2>&1
echo "■ 기준: ftpusers 파일의 소유자가 root이고, 권한이 640 미만이면 양호" >> $filepath 2>&1
echo "  [FTP 종류별 적용되는 파일]" >> $filepath 2>&1
echo "  (1)ftpd: /etc/ftpusers 또는 /etc/ftpd/ftpusers"	>> $filepath 2>&1
echo "  (2)proftpd: /etc/ftpusers 또는 /etc/ftpd/ftpusers"	>> $filepath 2>&1
echo "  (3)vsftpd: /etc/vsftpd/ftpusers, /etc/vsftpd/user_list (또는 /etc/vsftpd.ftpusers, /etc/vsftpd.user_list)" >> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

echo "U-31,C,," >> $filepath 2>&1
echo "ftpusers 파일의 소유자와 권한 확인 필요 " >> $filepath 2>&1
NewLine $filepath
echo "① /etc/services 파일에서 포트 확인"	>> $filepath 2>&1
DividingLine $filepath

if [ `cat /etc/services | awk -F" " '$1=="ftp" {print "(1)/etc/service파일:" $1 " " $2}' | grep "tcp" | wc -l` -gt 0 ]; then
	cat /etc/services | awk -F" " '$1=="ftp" {print "(1)/etc/service파일:" $1 " " $2}' | grep "tcp" >> $filepath 2>&1
else
	echo "(1)/etc/service파일: 포트 설정 X (Default 21번 포트)" >> $filepath 2>&1
fi

if [ -s vsftpd.txt ]; then
	if [ `cat $vsfile | grep "listen_port" | grep -v "^#" | awk '{print "(3)VsFTP 포트: " $1 "  " $2}' | wc -l` -gt 0 ]; then
		cat $vsfile | grep "listen_port" | grep -v "^#" | awk '{print "(3)VsFTP 포트: " $1 "  " $2}' >> $filepath 2>&1
	else
		echo "(2)VsFTP 포트: 포트 설정 X (Default 21번 포트 사용중)"	>> $filepath 2>&1
	fi
else
	echo "(2)VsFTP 포트: VsFTP가 설치되어 있지 않음"	>> $filepath 2>&1
fi

if [ -s proftpd.txt ]; then
	if [ `cat $profile | grep "Port" | grep -v "^#" | awk '{print "(2)ProFTP 포트: " $1 "  " $2}' | wc -l` -gt 0 ]; then
		cat $profile | grep "Port" | grep -v "^#" | awk '{print "(2)ProFTP 포트: " $1 "  " $2}'	>> $filepath 2>&1
	else
		echo "(3)ProFTP 포트: 포트 설정 X (/etc/service 파일에 설정된 포트를 사용중)"	>> $filepath 2>&1
	fi
else
	echo "(3)ProFTP 포트: ProFTP가 설치되어 있지 않음"	>> $filepath 2>&1
fi

NewLine $filepath
echo "② 서비스 포트 활성화 여부 확인"	>> $filepath 2>&1
DividingLine $filepath

################# /etc/services 파일에서 포트 확인 #################
if [ `cat /etc/services | awk -F" " '$1=="ftp" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="ftp" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
	if [ `netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]; then
		netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN"	>> $filepath 2>&1
		NewLine ftpenable.txt
	fi
else
	netstat -nat | grep ":21 " | grep -i "^tcp" | grep -i "LISTEN"	>> $filepath 2>&1
	NewLine ftpenable.txt
fi

################# vsftpd 에서 포트 확인 ############################
if [ -s vsftpd.txt ]; then
	if [ `cat $vsfile | grep "listen_port" | grep -v "^#" | awk -F"=" '{print $2}' | wc -l` -eq 0 ]; then
		port=21
	else
		port=`cat $vsfile | grep "listen_port" | grep -v "^#" | awk -F"=" '{print $2}'`
	fi

	if [ `netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]; then
		netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN"	>> $filepath 2>&1
		NewLine ftpenable.txt
	fi
fi

################# proftpd 에서 포트 확인 ###########################
if [ -s proftpd.txt ]; then
	port=`cat $profile | grep "Port" | grep -v "^#" | awk '{print $2}'`

	if [ `netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]; then
		netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN"	>> $filepath 2>&1
		NewLine ftpenable.txt
	fi
fi

if [ -f ftpenable.txt ]; then
	rm -f ftpenable.txt
else
	echo "FTP Service Disable"	>> $filepath 2>&1
fi

NewLine $filepath
echo "③ ftpusers 파일 소유자 및 권한 확인" >> $filepath 2>&1
DividingLine $filepath

NewFile ftpusers.txt

ServiceDIR="/etc/ftpusers /etc/ftpd/ftpusers /etc/vsftpd/ftpusers /etc/vsftpd.ftpusers /etc/vsftpd/user_list /etc/vsftpd.user_list"

for file in $ServiceDIR; do
	if [ -f $file ]; then
		ls -alL $file	>> ftpusers.txt
	fi
done

if [ `cat ftpusers.txt | wc -l` -gt 1 ]; then
	cat ftpusers.txt | grep -v "^ *$"	>> $filepath 2>&1
	NewLine $filepath
else
	NewLine $filepath
fi

rm -f ftpusers.txt

NewLine $filepath



echo "U-32 Check Start..."
echo "■ U-32. 3. 서비스 관리 > 3.16 로그온 시 경고 메시지 제공" >> $filepath 2>&1
echo "■ 기준: /etc/issue.net과 /etc/motd 파일에 로그온 경고 메시지가 설정되어 있을 경우 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

echo "U-32,C,,"	>> $filepath 2>&1
echo "● /etc/services 파일에서 포트 확인"	>> $filepath 2>&1
DividingLine $filepath

cat /etc/services | awk -F" " '$1=="telnet" {print $1 "   " $2}' | grep "tcp"	>> $filepath 2>&1

NewLine $filepath
echo "● 서비스 포트 활성화 여부 확인"	>> $filepath 2>&1
DividingLine $filepath

if [ `cat /etc/services | awk -F" " '$1=="telnet" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]; then
	port=`cat /etc/services | awk -F" " '$1=="telnet" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | wc -l` -gt 0 ]; then
		netstat -na | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN"	>> $filepath 2>&1
	else
		echo "Telnet Service Disable"	>> $filepath 2>&1
	fi
fi

NewLine $filepath
echo "① /etc/motd 파일 설정: "	>> $filepath 2>&1
DividingLine $filepath
if [ -f /etc/motd ]; then
	if [ `cat /etc/motd | grep -v "^ *$" | wc -l` -gt 0 ]; then
		cat /etc/motd | grep -v "^ *$"	>> $filepath 2>&1
	else
		NewLine $filepath
	fi
else
	echo "/etc/motd 파일이 없음"	>> $filepath 2>&1
fi

NewLine $filepath
echo "② /etc/issue.net 파일 설정:"	>> $filepath 2>&1
DividingLine $filepath

if [ -f /etc/issue.net ]; then
	if [ `cat /etc/issue.net | grep -v "^#" | grep -v "^ *$" | wc -l` -gt 0 ]; then
		cat /etc/issue.net | grep -v "^#" | grep -v "^ *$"	>> $filepath 2>&1
	else
		NewLine $filepath
	fi
else
	echo "/etc/issue.net 파일이 없음"	>> $filepath 2>&1
fi

NewLine $filepath




echo "U-33 Check Start..."
echo "■ U-33. 4. 로그 관리 > 4.1 최신 보안패치 및 벤더 권고사항 적용" 			>> $filepath 2>&1
echo "■ 기준: 패치 적용 정책을 수립하여 주기적으로 패치를 관리하고 있을 경우 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

var1=$(cat /etc/*-release | uniq | head -1 | awk '{print $4}')
var1=${var1: 0: 3}
minver=7.5

if [ "$(echo "if (${var1} > ${minver}) 1" | bc)" -eq 1 ]; then
	echo "U-33,O,,"		>> $filepath 2>&1
	echo "지원하는 버전 사용중" >> $filepath 2>&1
else
	echo "U-33,X,,"		>> $filepath 2>&1
	echo "지원하지 않는 버전 사용중" >> $filepath 2>&1
fi

echo "OS Version" >> $filepath 2>&1
cat /etc/*-release | uniq | head -1 >> $filepath 2>&1
NewLine $filepath



echo "U-34 Check Start..."
echo "■ U-34. 5. 보안 관리 > 5.1 정책에 따른 시스템 로깅 설정" >> $filepath 2>&1
echo "■ 기준: rsyslog 에 중요 로그 정보에 대한 설정이 되어 있을 경우 양호"	>> $filepath 2>&1
echo "■ 현황" >> $filepath 2>&1

echo "U-34,C,,"	>> $filepath 2>&1
echo "[수동진단]"	>> $filepath 2>&1
echo "① SYSLOG 데몬 동작 확인"	>> $filepath 2>&1
DividingLine $filepath

if [ `ps -ef | grep 'rsyslog' | grep -v 'grep' | wc -l` -eq 0 ]; then
	echo "U-34,X,,"	>> $filepath 2>&1
	echo "RSYSLOG Service Disable"	>> $filepath 2>&1
else
	if [ -f /etc/rsyslog.conf ]; then
		if [ `cat /etc/rsyslog.conf | grep -v "^#" | grep -v "^ *$" | wc -l` -gt 0 ]; then
			echo "U-34,O,,"	>> $filepath 2>&1
			echo "시스템 로깅 사용중"	>> $filepath 2>&1
			cat /etc/rsyslog.conf | grep -v "^#" | grep -v "^ *$"	>> $filepath 2>&1
		else
			echo "U-34,X,,"	>> $filepath 2>&1
			echo "/etc/rsyslog.conf 파일에 설정 내용이 없음(주석, 빈칸 제외)"	>> $filepath 2>&1
		fi
	else
		echo "U-34,X,,"	>> $filepath 2>&1
		echo "/etc/rsyslog.conf 파일이 없음"	>> $filepath 2>&1
	fi
	ps -ef | grep 'rsyslog' | grep -v 'grep'	>> $filepath 2>&1
fi

NewLine $filepath


rm -f proftpd.txt
rm -f vsftpd.txt

NewLine $filepath


echo "------------------------Basic RAW---------------------------" >> $filepath 2>&1

#HOSTNAME
echo "HOSTNAME : $HOSTNAME" >> $filepath 2>&1

#OS
# CentOS 7 기준으로 /etc/centos-release로 확인 가능
oscheck=$(cat /etc/*-release | uniq | head -1)
echo "OS : $oscheck" >> $filepath 2>&1

#IP
# print $2를 쓰는데 OS에 따라서 $3이 될 수 있으니 보완 필요
CheckVersion
if [ $? -ge 7 ]; then
	ipcheck=$(hostname -i | awk '{print $2}')
	echo "IP : $ipcheck" >> $filepath 2>&1
else
	ipcheck=$(hostname -i | awk '{print $1}')
	echo "IP : $ipcheck" >> $filepath 2>&1
fi

#자산 중요도
echo "자산중요도 : 기밀" >> $filepath 2>&1
NewLine $filepath

echo "------------------------시스템 정보------------------------" >> $filepath 2>&1
NewLine $filepath

echo "--OS Information--"	>> $filepath 2>&1
uname -a	>> $filepath 2>&1
NewLine $filepath

echo "--IP Information--" >> $filepath 2>&1
ifconfig -a	>> $filepath 2>&1
NewLine $filepath

echo "--Network Status(1)--" >> $filepath 2>&1
netstat -an | egrep -i "LISTEN|ESTABLISHED"	>> $filepath 2>&1
NewLine $filepath

echo "--Network Status(2)--" >> $filepath 2>&1
netstat -nap | egrep -i "tcp|udp"	>> $filepath 2>&1
NewLine $filepath

echo "--Routing Information--" >> $filepath 2>&1
netstat -rn	>> $filepath 2>&1
NewLine $filepath

echo "--Process Status--" >> $filepath 2>&1
ps -ef	>> $filepath 2>&1
NewLine $filepath

echo "--User Env--" >> $filepath 2>&1
env	>> $filepath 2>&1
NewLine $filepath

echo ''
echo ''
echo "☞ 진단작업이 완료되었습니다. 수고하셨습니다!"
echo ''

