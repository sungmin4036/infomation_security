#!/bin/sh

#################################################################################
#                                                                               #
#   Program Name : Security Check for LINUX                                     #
#   Version : V1.03                                                             #
#   Description : 이 프로램은 LINUX 서버 시스템 보안패치 파일및 스크립트 입니다.    #
#                                                                               #
#-------------------------------------------------------------------------------#
#                                                                               #
#                                                                               #
# 																				#
#                                                                               #
#################################################################################
if [ -f /root/count1.txt ]
then
 echo "이미 보안조치 스크립트를 실행 했습니다."
 exit 1

else 
echo "취약점 조치를 시작합니다."
echo "U.1-1) 원격 접속시 ROOT계정으로 접속 할 수 없도록 설정 (serviec sshd restart 필요)"

sed -i 's/PermitRootLogin yes/PermitRootLogin no/g'  /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin no/PermitRootLogin no/g'  /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g'  /etc/ssh/sshd_config
#  sed -i '19s/^/PermitRootLogin no/g' /etc/ssh/sshd_config

# a는 뒤에 , i는 앞에 추가됨

cat /etc/ssh/sshd_config | grep PermitRootLogin

echo "U.1-2) 패스워드 복잡성 설정 cat / /etc/security/pwquality.conf 확인" 
#sed -i 's/# dcredit = 1/dcredit = -1/g' /etc/security/pwquality.conf
#sed -i 's/# ucredit = 1/ucredit = -1/g' /etc/security/pwquality.conf
#sed -i 's/# ocredit = 1/ocredit = -1/g' /etc/security/pwquality.conf
#sed -i 's/# lcredit = 1/lcredit = -1/g' /etc/security/pwquality.conf
if [ -f /etc/security/pwquality.conf ]
  then
  	sed -i 's/^.*minlen.*/minlen = 9/g' /etc/security/pwquality.conf
	sed -i 's/^.*dcredit.*/dcredit = -1/g' /etc/security/pwquality.conf
	sed -i 's/^.*ucredit.*/ucredit = -1/g' /etc/security/pwquality.conf
	sed -i 's/^.*lcredit.*/lcredit = -1/g' /etc/security/pwquality.conf
	sed -i 's/^.*ocredit.*/ocredit = -1/g' /etc/security/pwquality.conf
	if [ `cat /etc/security/pwquality.conf | grep -E "minlen" | wc -l` -lt 1 ]
    then
    	echo "minlen = 9" >> /etc/security/pwquality.conf
	fi
	if [ `cat /etc/security/pwquality.conf | grep -E "dcredit" | wc -l` -lt 1 ]
    then
		echo "dcredit = -1" >> /etc/security/pwquality.conf
	fi
	if [ `cat /etc/security/pwquality.conf | grep -E "ucredit" | wc -l` -lt 1 ]
    then
		echo "ucredit = -1" >> /etc/security/pwquality.conf
	fi
	if [ `cat /etc/security/pwquality.conf | grep -E "lcredit" | wc -l` -lt 1 ]
    then
		echo "lcredit = -1" >> /etc/security/pwquality.conf
	fi
	if [ `cat /etc/security/pwquality.conf | grep -E "ocredit" | wc -l` -lt 1 ]
    then
		echo "ocredit = -1" >> /etc/security/pwquality.conf
	fi
fi
sed -n '11,25p' /etc/security/pwquality.conf

echo "U.1-3) 계정잠금 임계값 설정 cat /etc/pam.d/password-auth-ac system-auth-ac 수정"
#perl -p -i -e '$.==9 and print "auth required pam_tally2.so deny=5 unlock_time=120\n"' /etc/pam.d/password-auth-ac
#perl -p -i -e '$.==16 and print "account required pam_tally2.so\n"' /etc/pam.d/password-auth-ac
#perl -p -i -e '$.==9 and print "auth required pam_tally2.so deny=5 unlock_time=120\n"' /etc/pam.d/system-auth-ac
#perl -p -i -e '$.==16 and print "account required pam_tally2.so\n"' /etc/pam.d/system-auth-ac
if [ -f /etc/pam.d/system-auth ]
	then
	if [ `cat /etc/*-release | uniq | grep -E 'release 5|release 6' | wc -l` -gt 0 ]
		then
		echo "CentOS 5 또는 6 버젼 쉘 실행"
		 sed -i 's/auth.*required.*\/lib\/security\/pam_tally.so.*/auth 	required 	\/lib\/security\/pam_tally.so deny=5 unlock_time=120 no_magic_root/g' /etc/pam.d/system-auth
		 sed -i 's/account.*required.*\/lib\/security\/pam_tally.so.*/account 	required 	\/lib\/security\/pam_tally.so no_magic_root reset/g' /etc/pam.d/system-auth
		if [ `cat /etc/pam.d/system-auth | grep -E "pam_tally" | wc -l` -lt 1 ]
		  then
		   echo "auth		required 	/lib/security/pam_tally.so deny=5 unlock_time=120 no_magic_root" >> /etc/pam.d/system-auth
		   echo "account 	required 	/lib/security/pam_tally.so no_magic_root reset" >> /etc/pam.d/system-auth
		fi 
	else
		echo "CentOS 7 이상 버젼 쉘 실행"
		 sed -i 's/auth.*required.*pam_tally2.so.*/auth 	required 	pam_tally2.so deny=5 unlock_time=120 no_magic_root/g' /etc/pam.d/system-auth
		 sed -i 's/account.*required.*pam_tally2.so.*/account 	required 	pam_tally2.so no_magic_root reset/g' /etc/pam.d/system-auth
		if [ `cat /etc/pam.d/system-auth | grep -E "pam_tally" | wc -l` -lt 1 ]
		  then
		   echo "auth 	required 	pam_tally2.so deny=5 unlock_time=120 no_magic_root" >> /etc/pam.d/system-auth
		   echo "account 	required 	pam_tally2.so no_magic_root reset" >> /etc/pam.d/system-auth
		fi 
	fi
fi
if [ -f /etc/pam.d/password-auth ]
  then
        sed -i 's/auth.*required.*pam_tally2.so.*/auth 	required 	pam_tally2.so deny=5 unlock_time=120 no_magic_root/g' /etc/pam.d/password-auth
		sed -i 's/account.*required.*pam_tally2.so.*/account 	required 	pam_tally2.so no_magic_root reset/g' /etc/pam.d/password-auth
	    if [ `cat /etc/pam.d/password-auth | grep -E "pam_tally" | wc -l` -lt 1 ]
		  then
  		 echo "auth 	required 	pam_tally2.so deny=5 unlock_time=120 no_magic_root" >> /etc/pam.d/password-auth
		 echo "account 	required 	pam_tally2.so no_magic_root reset" >> /etc/pam.d/password-auth
		fi
fi
cat /etc/pam.d/password-auth-ac | grep pam_tally2.so
cat /etc/pam.d/system-auth-ac | grep pam_tally2.so

echo "U.1-4) 패스워드 파일 보호 (기존 조치되어있음) cat /etc/shadow"
pwconv
echo "U1-5) root이외 UID '0' 금지 (기존 조치되어있음) /etc/passwd"
USRDET=`cat /etc/passwd | grep -E ":x:0:" | grep -v "^root:"`
UIDSET=`cat /etc/passwd | cut -d: -f3`
MAXNUM=0
for TT in $UIDSET
do
  if [ $TT -gt $MAXNUM ]
   then
   MAXNUM=$TT
  fi
done
MAXNUM=$((MAXNUM+1))
for USDT in $USRDET
do
 TOKDT=`cut -d: -f1 <<< $USDT`
 sed -i "s/^$TOKDT:x:0:/$TOKDT:x:$MAXNUM:/" /etc/passwd
 MAXNUM=$((MAXNUM+1))
done
unset USRDET
unset UIDSET
unset MAXNUM
unset TT
unset USDT
unset TOKDT

echo "U.1-6) wheel 그룹내 구성원 존재 여부 확인 cat /etc/group | grep wheel"
sed -i 's/wheel:x:10:/wheel:x:10:root,hestia/g' /etc/group
chgrp wheel /bin/su
chmod 4750 /bin/su
cat /etc/group | grep wheel
ls -al /bin/su

echo "U.1-7) 패스워드 최소길이 설정 cat /etc/login.defs"
echo "U.1-8) 패스워드 최대 사용기간 설정 90일"
echo "U.1-9 ) 패스워드 최소 사용기간 1일"
#sed -i 's/PASS_MAX_DAYS	99999/PASS_MAX_DAYS 90/g' /etc/login.defs
#sed -i 's/PASS_MIN_DAYS	0/PASS_MIN_DAYS 1/g' /etc/login.defs
sed -i 's/PASS_MIN_LEN	5/PASS_MIN_LEN 9/g' /etc/login.defs
sed -i 's/PASS_WARN_AGE	7/PASS_WARN_AGE 7/g' /etc/login.defs
sed -n '25,28p' /etc/login.defs

echo "U.1-10) 불필요한 계정 제거(기존 로그인계정은 처리되어있으며 나머지 모두 nologin 처리"
echo "U.1-11) 관리자 그룹에 최소한의 계정포함(root, hestia 기본 등록처리 cat /etc/group | grep root"
echo "U.1-12) 계정이 존재하지 않는 GID 금지 (기존 조치됨 cat /etc/group)"
echo "U.1-13) 동일한 UID 금지 cat /etc/passwd (기존 조치됨)"
UIDSET=`cat /etc/passwd | sort -k 3 -n -t: | cut -d: -f3`
MAXNUM=`echo $UIDSET | rev | cut -d" " -f1 | rev`
COMP=-1
for TT in $UIDSET
do
  if [ $TT -eq $COMP ]
   then
    USRID=`cat /etc/passwd | grep -E ":x:$TT:" | cut -d: -f1 | tail -1`
MAXNUM=$((MAXNUM+1))
    sed -i "s/^$USRID:x:$TT/$USRID:x:$MAXNUM/" /etc/passwd
	MAXNUM=$((MAXNUM+1))
  fi
  COMP=$TT
done
unset UIDSET
unset MAXNUM
unset COMP
unset TT
unset USRID

echo "U.1-14) 로그인이 필요하지 않는 계정에 대해 /sbin/nologin 부여 (기존조치됨 /etc/passwd)"
echo "U.1-15) 세션 타입 아웃 설정 600초 설정완료"
if [ -f /etc/profile ]
  then
	sed -i 's/^TMOUT.*/TMOUT=600/g' /etc/profile
	if [ `cat /etc/profile | grep -E "TMOUT" | wc -l` -lt 1 ]
	then
		echo "TMOUT=600" >> /etc/profile
		echo "export TMOUT" >> /etc/profile
	fi
fi
if [ -f /etc/.profile ]
  then
  	sed -i 's/^TMOUT.*/TMOUT=600/g' /etc/.profile
	if [ `cat /etc/.profile | grep -E "TMOUT" | wc -l` -lt 1 ]
	then
		echo "TMOUT=600" >> /etc/.profile
		echo "export TMOUT" >> /etc/.profile
	fi
fi
if [ -f /etc/csh.login ]
  then
    sed -i 's/^set autologout.*/set autologout=10/g' /etc/csh.login
	if [ `cat /etc/csh.login | grep -E "autologout" | wc -l` -lt 1 ]
	then
		echo "set autologout=10" >> /etc/csh.login
	fi
fi
#sed -i 's/# will prevent the need for merging in future updates./export TMOUT=300/g'  /etc/profile
cat /etc/profile | grep TMOUT

echo "U.2-1) root홈, 패스 디렉터리 권한 및 패스 설정 (기존 조치되어있음 echo $PATH)"
echo "$PATH"

echo "U.2-2) 파일 및 디렉터리 소유자 설정 (기존 조치 완료 cat /.bash_profile .bashrc | grep PATH"
cat /.bash_profile .bashrc | grep PATH

echo "U.2-3) /etc/passwd 파일 소유자 및 권한 설정 ls -al /etc/passwd"
chown root:root /etc/passwd
chmod 644 /etc/passwd
ls -al /etc/passwd

echo "U.2-4) /etc/shadow 파일 소유자 및 권한 설정 ls -al /etc/shadow"
chown root:root /etc/shadow
chmod 400 /etc/shadow
ls -al /etc/shadow

echo "U.2-5) /etc/hosts 파일 소유자 및 권한 설정"
chmod 600 /etc/hosts.allow
chmod 600 /etc/hosts.deny
ls -al /etc/hosts.*

echo "U.2-6) /etc/(x)inetd.conf 파일 소유자 및 권한 설정 (서비스가 없어 해당없음)"

echo "U.2-7) /etc/syslog.conf 파일 소유자 및 권한 설정 ls -al /etc/rsyslog.conf"
chown root:root /etc/rsyslog.conf
chmod 644 /etc/rsyslog.conf
ls -al /etc/rsyslog.conf

echo "U.2-8) /etc/services 파일 소유자 및 권한 설정 la -al /etc/services"
chown root:root /etc/services
chmod 644 /etc/services
ls -al /etc/services

echo "U.2-9) SUID, SGID, Sticky bit 설정 및 권한 설정"
chmod -s /sbin/unix_chkpwd
chmod -s /usr/bin/at
chmod -s /usr/bin/lpq
chmod -s /usr/bin/lpr
chmod -s /usr/bin/lprm
chmod -s /usr/bin/newgrp
chmod -s /usr/sbin/lpc
chmod -s /usr/bin/traceroute

echo "U.2-10) 사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정(bashrc bash_profile 설정완료)"
chown root:root /etc/profile
chown root:root /etc/bashrc
chown root:root /root/.bashrc
chown root:root /root/.bash_profile
chown root:root /home/hestia/.bashrc
chmod 644 /etc/profile
chmod 644 /etc/bashrc
chmod 644 /root/.bashrc
chmod 644 /root/.bash_profile
chmod 644 /home/hestia/.bashrc

echo "U.2-11) world writable 파일 점검 (조치되어있음.점검시 표기되는 부분은 dev부분으로 조치불가,아래명령으로확인)"
echo "find / -perm -2 -type d -exec ls -aldL {} \;"

echo "U.2-12) dev에 존재하지 않는 device 파일 점검(아래명령 수동 확인 필요)"
echo "find /dev -type f -exec ls -l {} \;"

echo "U.2-13) $HOME/.rhosts, hosts.equiv 사용 금지 (이미 조치되어있음 파일 없음)"
echo "U.2-14) 접속 IP 및 포트 제한 (/etc/hosts.allow hosts.deny 파일 수동 조치 필요)"
echo "U.2-15) hosts.lpd 파일 소유자 및 권한 설정 (해당없음 파일 없음)"
echo "U.2-16) NIS 서비스 비활성화 (서비스 없음)"
echo "U.2-17) UMASK 설정 관리 umask"
if [ `umask` -ne 0022 ]
 then
  sed -i 's/umask [^a-z]../umask 002/' /etc/profile
  sed -i 's/umask [^a-z]../umask 022/' /etc/profile
fi
source /etc/profile

echo "U.2-18) 홈디렉터리 소유자 및 권한 설정 (조치되어있음)"
echo "U.2-19) 홈디렉터리로 지정한 디렉토리의 존재 관리 (사용자 계정과 홈 디렉터리의 일치 여부를 점검 조치완료)"
echo "U-2.20) 숨겨진 파일 및 디렉토리 점검 및 제거 (수동확인필요) find / -name '.*'"
echo "U.3-1)  finger 서비스 비활성화"
systemctl stop finger
systemctl disable finger
ps -ef | grep finger

echo "U.3-2) Anonymous FTP 비활성화"
if [ -f /etc/vsftpd/vsftpd.conf ]
  then
    if [ `cat /etc/vsftpd/vsftpd.conf | grep -E "anonymous_enable" | wc -l` -lt 1 ]
     then
       echo "anonymous_enable=NO" >> /etc/vsftpd/vsftpd.conf
    else
       sed -i 's/.*anonymous_enable=.*/anonymous_enable=NO/g' /etc/vsftpd/vsftpd.conf
	fi
fi
if [ -f /etc/vsftpd.conf ]
  then
    if [ `cat /etc/vsftpd.conf | grep -E "anonymous_enable" | wc -l` -lt 1 ]
     then
       echo "anonymous_enable=NO" >> /etc/vsftpd.conf
    else
       sed -i 's/.*anonymous_enable=.*/anonymous_enable=NO/g' /etc/vsftpd.conf
	fi
fi
cat /etc/vsftpd/vsftpd.conf | grep anonymous_enable

echo "U.3-3) r 계열 서비스 비활성화(모두 기본 비활성화)"
echo "U.3-4) cron 파일 소유자 및 권한 설정"
touch /etc/cron.allow
chown root:root /etc/cron.allow
chown root:root /etc/cron.deny
chmod 640 /etc/cron.allow
chmod 640/etc/cron.deny
ls -al /etc/cron.*

echo "U.3-5) Dos 공격에 취약한 서비스 비활성화 (xinet.d 해당없음)"
echo "U.3-6) NFS 서비스 비활성화"
systemctl stop nfs-server.service
systemctl disable nfs-server.service
echo "U.3-7) NFS접근 통제 (3-6에서 처리)"
echo "U.3-8) automountd 제거"
systemctl stop automountd.service
systemctl disable automountd.service

echo "U.3-9)  서비스 확인"
systemctl stop rpc-gssd.service
systemctl stop rpc-statd-notify.service
systemctl stop rpc_pipefs.target
systemctl stop rpcbind.socket
systemctl stop rpc-rquotad.service
systemctl stop rpc-statd.service
systemctl stop rpcbind.service

systemctl disable rpc-gssd.service
systemctl disable rpc-statd-notify.service
systemctl disable rpc_pipefs.target
systemctl disable rpcbind.socket
systemctl disable rpc-rquotad.service
systemctl disable rpc-statd.service
systemctl disable rpcbind.service

echo "U.3-10) NIS, NIS+ 서비스 점검(비활성화)"
systemctl stop NIS.service
systemctl stop NIS+.service
systemctl disable NIS.service
systemctl disable NIS+.service

echo "U.3-11) tftp, talk 서비스 비활성화 (조치되어있음)"
echo "U.3-12)  sendmail 점검 (미사용)"
echo "U.3-13) 스팸 메일 릴에이 제한(미사용)"
echo "U.3-14) 일반 사용자의 sendmail 실행 방지 (미사용)"
echo "U.3-15) DNS 보안버젼 패치 (미사용) name -V"
echo "U.3-16) DNS Zone Transfer 설정 (미사용) find / -name named.conf"

echo "U.3-17) Apache 디렉토리 리스닝 제거"
sed -i 's/Options Indexes FollowSymLinks/Options Indexes/g' /hestia/data/app/apache2.4/conf/httpd.conf

echo "U.3-18) Apache 웹 프로세스 권한 제한(daedmon 으로 변경됨)"

echo "U.3.19) Apache 상위 디렉토리 접근 금지"
# sed -i 's/AllowOverride none/AllowOverride AuthConfig/g' /hestia/data/app/apache2.4/conf/original/httpd.conf
# sed -i 's/AllowOverride None/AllowOverride AuthConfig/g' /hestia/data/app/apache2.4/conf/original/httpd.conf

sed -i 's/AllowOverride none/AllowOverride AuthConfig/g' /hestia/data/app/apache2.4/conf/httpd.conf
sed -i 's/AllowOverride None/AllowOverride AuthConfig/g' /hestia/data/app/apache2.4/conf/httpd.conf

sed -i '1s/^/AccessFileName .auth/g' /hestia/data/app/apache2.4/conf/httpd.conf
 #  sed -i '19s/^/PermitRootLogin no/g' /etc/ssh/sshd_config

# touch /hestia/data/app/apache2.4/.auth
# echo  "AuthName \"디렉터리 사용자 인증\"" > /hestia/data/app/apache2.4/.htaccess
# echo  "AuthType Basic" >> /hestia/data/app/apache2.4/.auth
# echo  "AuthUserFile /hestia/data/app/apache2.4/.auth" >> /hestia/data/app/apache2.4/.auth
# echo  "Require hanssak" >> /hestia/data/app/apache2.4/.auth


# AuthName "디렉터리 사용자 인증"
# AuthType Basic
# AuthUserFile /hestia/data/app/apache2.4/.htaccess



# echo "/hestia/data/app/apache2.4/bin/htpasswd -c /hestia/data/app/apache2.4/.auth hanssak" > /home/hestia/htpasswd.sh
# /hestia/data/app/apache2.4/bin/htpasswd -bcm /hestia/data/app/apache2.4/.auth root hsck@2301
# 78p step3, step4 확인

echo "U.3.20) Apache 불필요한 파일 제거"
echo "U.3.21) Apache 링크 사용 금지(미사용)"
# sed -i 's/Options Indexes FollowSymLinks/Options Indexes/g' /hestia/data/app/apache2.4/conf/original/httpd.conf


echo "U.3.22) Apache 파일 업로드 및 다운로드 제한(보류)"
echo "U.3.23) Apache 웹 서비스 영역의 분리(되있음)"


echo "U.3-24 ) ssh 원격 접속 허용 (사용중)"
echo "U.3-25) ftp 서비스 확인 vsftpd (미사용)"
echo "U.3-26) ftp 계정 shell 제한 (미사용 없음)"
echo "U.3-27) ftpuser 파일 소유자 및 권한 설정"
chown root:root /etc/vsftpd/ftpusers
chmod 640 /etc/vsftpd/ftpusers
ls -al /etc/vsftpd/ftpusers

echo "U.3-28) ftpusers 파일 설정 ftpuses 파일 root 계정 포함 여부 (없음)"
echo "U.3-29) at 파일 소유자 및 권한 설정"
touch /etc/at.allow
chown root /etc/cron.d/at.allow /etc/cron.d/at.deny /etc/at.allow /etc/at.deny /var/adm/cron/at.allow /var/adm/cron/at.deny
chmod 640 /etc/cron.d/at.allow /etc/cron.d/at.deny /etc/at.allow /etc/at.deny /var/adm/cron/at.allow /var/adm/cron/at.deny
ls -al /etc/at.*

echo "U.3-30) SNMP 서비스 구동 점검(미사용)"
echo "U.3-31 SNMP 서비스 Community string의 복잡성 설정(미사용)"
if [ -f /etc/snmp/snmpd.conf ]
  then
	if [ `cat /etc/snmp/snmpd.conf | grep -E 'com2sec.*public|com2sec.*private' | wc -l` -gt 0 ]
	then
		sed -i 's/com2sec.*/com2sec notConfigUser  default    SEC_LOTTE/g' /etc/snmp/snmpd.conf
		if [ `cat /etc/*-release | uniq | grep -E 'release 5|release 6' | wc -l` -gt 0 ]
			then
			  service snmpd restart && service snmpd stop
		else
			  systemctl restart snmpd && systemctl stop snmpd
		fi
	fi
fi

echo "U.3-32 로그온 시 경고 메시지 제공(아래 두개파일 수동 설정필요)"
if [ -f /etc/motd ]
  then
    echo "********************* W  A  R  N  I  N  G  ! *********************" > /etc/motd
    echo "           All connections are monitored and recorded.            " >> /etc/motd
	echo "    Disconnect IMMEDIATELY if you are not an authorized user!     " >> /etc/motd
    echo "******************************************************************" >> /etc/motd
fi
if [ -f /etc/issue.net ]
    then
      echo "********************* W  A  R  N  I  N  G  ! *********************" > /etc/issue.net
	  echo "           All connections are monitored and recorded.            " >> /etc/issue.net
      echo "    Disconnect IMMEDIATELY if you are not an authorized user!     " >> /etc/issue.net
      echo "******************************************************************" >> /etc/issue.net
fi
if [ -f /etc/vsftpd/vsftpd.conf ]
    then
      sed -i 's/.*ftpd_banner=.*/ftpd_banner=*** WARNING! *** All connections are monitored and recorded. Disconnect IMMEDIATELY if you are not an authorized user!/g' /etc/vsftpd/vsftpd.conf
fi
if [ -f /etc/named.conf ]
	then
      echo "********************* W  A  R  N  I  N  G  ! *********************" >> /etc/named.conf
	  echo "           All connections are monitored and recorded.            " >> /etc/named.conf
      echo "    Disconnect IMMEDIATELY if you are not an authorized user!     " >> /etc/named.conf
      echo "******************************************************************" >> /etc/named.conf
fi
echo "cat /etc/issue.net"
echo "cat /etc/motd"
echo "cat /etc/named.conf"
echo "/etc/vsftpd/vsftpd.conf"

echo "U.3-33) NFS 설정파일 접근권한"
chown root /etc/dfs/dfstab /etc/dfs/sharetab /etc/exports
chmod 644 /etc/dfs/dfstab /etc/dfs/sharetab /etc/exports
ls -al /etc/exports

echo "U.3-34) expn, vrfy 명령어 제한 snmp미사용"
if [ `ps -ef | grep sendmail | grep -v grep |wc -l` -ne 0 ]
  then 
    sed -i 's/.*O PrivacyOptions.*/O PrivacyOptions=authwarnings,novrfy,noexpn,restrictqrun/g' /etc/mail/sendmail.cf
    if [ `cat /etc/*-release | uniq | grep -E 'release 5|release 6' | wc -l` -gt 0 ]
      then
        service sendmail restart && service sendmail stop
      else
        systemctl restart sendmail && systemctl stop sendmail
    fi
fi
ps -ef | grep snmp
userdel adm
userdel lp
userdel news
userdel games
userdel gopher
groupdel adm
groupdel lp
groupdel news

echo "U.3-35) Apache Directory Listing check"
sed -i 's/Options Indexes.*/Options none/g' /etc/httpd/conf/httpd.conf

echo "U.3-36) Apache needless file check"
rm -rf /etc/httpd/htdocs/manual
rm -rf /etc/httpd/manual

echo "U.3-37) System logging configuration check"
if [ -f /etc/rsyslog.conf ]
  then
    if [ `cat /etc/rsyslog.conf | grep "/var/log/messages" | wc -l` -gt 0 ]
	  then
	   sed -i 's/.*\/var\/log\/messages/\*\.info\;mail\.none\;authpriv\.none\;cron\.none                                                  	\/var\/log\/messages/g' /etc/rsyslog.conf
	else
	   echo "*.info;mail.none\;authpriv.none;cron.none                                                  	/var/log/messages" >> /etc/rsyslog.conf
	fi
    if [ `cat /etc/rsyslog.conf | grep "/var/log/secure" | wc -l` -gt 0 ]
	  then
	   sed -i 's/.*\/var\/log\/secure/authpriv\.\*                                                  	\/var\/log\/secure/g' /etc/rsyslog.conf
	else
	   echo "authpriv.*                                                  	/var/log/secure" >> /etc/rsyslog.conf
	fi
    if [ `cat /etc/rsyslog.conf | grep "/var/log/maillog" | wc -l` -gt 0 ]
	  then
	   sed -i 's/.*\/var\/log\/maillog/mail\.\*                                                  	\/var\/log\/maillog/g' /etc/rsyslog.conf
	else
	   echo "mail.*                                                  	/var/log/maillog" >> /etc/rsyslog.conf
	fi
    if [ `cat /etc/rsyslog.conf | grep "/var/log/cron" | wc -l` -gt 0 ]
	  then
	   sed -i 's/.*\/var\/log\/cron/cron\.\*                                                  	\/var\/log\/cron/g' /etc/rsyslog.conf
	else
	   echo "cron.*                                                  	/var/log/cron" >> /etc/rsyslog.conf
	fi
    if [ `cat /etc/rsyslog.conf | grep "/dev/console" | wc -l` -gt 0 ]
	  then
	   sed -i 's/.*\/dev\/console/\*\.alert                                                  	\/dev\/console/g' /etc/rsyslog.conf
	else
	   echo "*.alert                                                  	/dev/console" >> /etc/rsyslog.conf
	fi
    if [ `cat /etc/rsyslog.conf | grep "*$" | wc -l` -gt 0 ]
	  then
	   sed -i 's/.*\*$/\*\.emerg                                                  	\*/g' /etc/rsyslog.conf
	else
	   echo "*.emerg                                                  	*" >> /etc/rsyslog.conf
	fi
fi

touch /root/count1.txt
chattr +i /root/count1.txt
echo "취약점 조치가 완료 되었습니다. 실행 경로에 생성된 result.txt 파일을 복사 또는 이동하여 주십시오."
echo "스크립트 재 실행 시 조치 값이 사라지며 [이미 보안조치 스크립트를 실행 했습니다.] 라는 값으로 대체 됩니다."
fi






sed -e 's,\(\[computer]\),\1\insert_test,g' /home/hestia/testfile.txt
sed -i'' -r -e "/Please Put it here/i\Some More Text is appended/" /home/hestia/testfile.txt