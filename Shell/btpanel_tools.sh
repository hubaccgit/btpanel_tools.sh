#!/bin/bash
#全局变量
down_url=https://down.gacjie.cn/BTPanel
panel_path=/www/server/panel
#检测新版本
new_version(){
    new_version=$(curl -Ss --connect-timeout 100 -m 300 ${down_url}/Api/BTPanel_Tools_version.json)
    if [ "$new_version" = '' ];then
	    new_version='0.6'
    fi
    if [ "$new_version" != "0.6" ];then
        echo -e "检测到新版本正在更新......"
	    wget -O btpanel_tools.sh ${down_url}/Shell/btpanel_tools.sh && bash btpanel_tools.sh
	    exit 0
    fi
    main
}
#清理垃圾
cleaning_garbage(){
    echo -e "正在清理面板缓存......"
    rm -f ${panel_path}/*.pyc
    rm -f ${panel_path}/class/*.pyc
    echo -e "已完成清理面板缓存......"
    echo -e "正在清理PHP_SESSION......"
    rm -rf /tmp/sess_*
    echo -e "已完成清理PHP_SESSION......"
    echo -e "正在清理网站日志......"
    rm -rf /www/wwwlogs/*.log
    rm -rf /www/wwwlogs/*.gz
    echo -e "已完成清理网站日志......"
    echo -e "正在清理面板日志......"
    rm -rf ${panel_path}/logs/*.log
    rm -rf ${panel_path}/logs/*.gz
    rm -rf ${panel_path}/logs/request/*
    echo -e "已完成清理面板日志......"
    echo -e "正在清理邮件日志......"
    rm -rf /var/spool/plymouth/*
    rm -rf /var/spool/postfix/*
    rm -rf /var/spool/lpd/*
    echo -e "已完成清理邮件日志......"
    echo -e "正在清理系统使用痕迹..."
    cat /dev/null > /var/log/boot.log
    cat /dev/null > /var/log/btmp
    cat /dev/null > /var/log/cron
    cat /dev/null > /var/log/dmesg
    cat /dev/null > /var/log/firewalld
    cat /dev/null > /var/log/grubby
    cat /dev/null > /var/log/lastlog
    cat /dev/null > /var/log/mail.info
    cat /dev/null > /var/log/maillog
    cat /dev/null > /var/log/messages
    cat /dev/null > /var/log/secure
    cat /dev/null > /var/log/spooler
    cat /dev/null > /var/log/syslog
    cat /dev/null > /var/log/tallylog
    cat /dev/null > /var/log/wpa_supplicant.log
    cat /dev/null > /var/log/wtmp
    cat /dev/null > /var/log/yum.log
    history -c
    echo -e "已完成清理系统使用痕迹..."
    echo -e "垃圾文件清理完毕！您的服务器身轻如燕！"
    back_home
}
#去除强制登陆
mandatory_landing(){
    rm -f ${panel_path}/data/bind.pl
    back_home
}
#修复环境
repair_environment(){
    yum -y install make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel patch wget libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel tar bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel libcurl libcurl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal gettext gettext-devel ncurses-devel gmp-devel pspell-devel libcap diffutils ca-certificates net-tools libc-client-devel psmisc libXpm-devel git-core c-ares-devel libicu-devel libxslt libxslt-devel zip unzip glibc.i686 libstdc++.so.6 cairo-devel bison-devel ncurses-devel libaio-devel perl perl-devel perl-Data-Dumper lsof pcre pcre-devel vixie-cron crontabs expat-devel readline-devel libsodium-dev automake perl-ExtUtils-Embed GeoIP GeoIP-devel GeoIP-data freetype freetype-devel libffi-devel libmcrypt-devel epel-release libsodium-devel sqlite-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel
    back_home
}
#修复面板
update_panel(){
    sed -i 's/[0-9\.]\+[ ]\+www.bt.cn//g' /etc/hosts
    chattr -i ${panel_path}/class/panelAuth.py
    chattr -i ${panel_path}/class/panelPlugin.py
    chattr -i /etc/init.d/bt
    rm -f /etc/init.d/bt
    wget -O /etc/init.d/bt ${down_url}/Shell/bt6.init -T 10
    chmod +x /etc/init.d/bt
    chattr -i ${panel_path}/data/plugin.json
    rm -f ${panel_path}/data/plugin.json
    wget -O ${panel_path}/data/plugin.json http://bt.cn/api/panel/get_soft_list_test -T 10
    chattr -i ${panel_path}/install/check.sh
    rm -f ${panel_path}/install/check.sh
    wget -O ${panel_path}/install/check.sh ${down_url}/Shell/check.sh -T 10
    chattr -i ${panel_path}/install/public.sh
    rm -f ${panel_path}/install/public.sh
    wget -O ${panel_path}/install/public.sh ${down_url}/Shell/public.sh -T 10
    rm -rf ${panel_path}/plugin/shoki_cdn
    rm -f ${panel_path}/data/home_host.pl
    rm -rf ${panel_path}/adminer
    rm -rf /www/server/adminer
    rm -rf /www/server/phpmyadmin/pma
    rm -f ${panel_path}/*.pyc
    rm -f ${panel_path}/class/*.pyc
    rm -f /dev/shm/session.db
    curl ${down_url}/Shell/update_panel.sh|bash
    back_home
}
#自动换源
yum_source(){
    clear
    wget -O yumRepo.sh ${down_url}/Shell/yumRepo.sh && sh yumRepo.sh
    back_home
}
#留存备份
keep_backup(){
    clear
    is_backup=${panel_path}/data/is_save_local_backup.pl
    if [ ! -f "${is_backup}" ];
    then
        echo '' >${is_backup}
        echo "开启备份留存功能"
    else
        rm -f ${is_backup}
        echo "关闭备份留存功能"
    fi
    back_home
}
#停止服务
stop_btpanel(){
    /etc/init.d/bt stop
    /etc/init.d/nginx stop
    /etc/init.d/httpd stop
    /etc/init.d/mysqld stop
    /etc/init.d/pure-ftpd stop
    /etc/init.d/php-fpm-52 stop
    /etc/init.d/php-fpm-53 stop
    /etc/init.d/php-fpm-54 stop
    /etc/init.d/php-fpm-55 stop
    /etc/init.d/php-fpm-56 stop
    /etc/init.d/php-fpm-70 stop
    /etc/init.d/php-fpm-71 stop
    /etc/init.d/php-fpm-72 stop
    /etc/init.d/php-fpm-73 stop
    /etc/init.d/php-fpm-74 stop
    /etc/init.d/redis stop
    /etc/init.d/memcached stop
}
#卸载面板
uninstall_btpanel(){
    wget -O bt-uninstall.sh ${down_url}/Shell/bt-uninstall.sh && bash bt-uninstall.sh
    rm -rf bt-uninstall.sh
    rm -rf /tmp/*.sh
    rm -rf /tmp/*.sock
}
#亚当面板
cp ${panel_path}/config/config.json /root/config.json
idc='dbc5d37b'
IDC_CODE=$idc
python_bin=${panel_path}/pyenv/bin/python
Setup_Count(){
	curl -sS --connect-timeout 10 -m 60 https://www.bt.cn/Api/SetupCount?type=Linux\&o=$idc > /dev/null 2>&1
	if [ "$idc" != "" ];then
		echo $idc > ${panel_path}/data/o.pl
		cd ${panel_path}
		$python_bin tools.py o
		python tools.py o
	fi
	echo /www > /var/bt_setupPath.conf
}
Setup_Count ${IDC_CODE}
cp /root/config.json ${panel_path}/config/config.json 
rm -f /root/config.json
#宝塔磁盘挂载
mount_disk(){
	echo -e "注意：本工具会将数据盘挂载到www目录。15秒后跳转到挂载脚本。"
    sleep 15s
	wget -O auto_disk.sh ${down_url}/Shell/auto_disk.sh && bash auto_disk.sh
	rm -rf /auto_disk.sh
    rm -rf auto_disk.sh
    back_home
}
#永久企业版
permanent_ltd(){
    wget -O ${panel_path}/BTPanel/templates/default/index.html ${down_url}/Template/btpanel_index.html
    /etc/init.d/bt restart
    back_home
}
#企业加速
speed_ltd(){
    wget -O ${panel_path}/plugin/site_speed/index.html ${down_url}/Template/site_speed_index.html
    /etc/init.d/bt restart
    back_home
}
panel_record(){
    wget -O ${panel_path}/BTPanel/templates/default/firewall.html ${down_url}/Template/firewall.html
    /etc/init.d/bt restart
    back_home
}
#封装工具
package_btpanel(){
    clear
    python ${panel_path}/tools.py package
    back_home
}
#降级版本
degrade_btpanel(){
    if [ ! -d ${panel_path}/BTPanel ];then
    	echo "============================================="
    	echo "错误, 5.x不可以使用此命令升级!"
    	echo "5.9平滑升级到6.0的命令：curl http://download.bt.cn/install/update_to_6.sh|bash"
    	exit 0;
    fi
    wget -T 5 -O panel.zip ${down_url}/Update/LinuxPanel-${version}.zip
    unzip -o panel.zip -d /www/server/ > /dev/null
    rm -f panel.zip
    rm -f ${panel_path}/*.pyc
    rm -f ${panel_path}/class/*.pyc
    sleep 1 && service bt restart > /dev/null 2>&1 &
    echo "====================================="
    echo "你已降级为${version}版";
    back_home
}
#免费nginx防火墙
free_nginx_waf(){
    clear
    wget -O ${panel_path}/plugin/free_waf/index.html ${down_url}/Plugins-Dev/free_waf_r/index.html
    wget -O ${panel_path}/plugin/free_waf/rule.json ${down_url}/Plugins-Dev/free_waf_r/rule.json
    back_home
}
#nginx防火墙
nginx_waf(){
    clear
    wget -O ${panel_path}/plugin/btwaf/rule.json ${down_url}/Plugins-Dev/free_waf_r/rule.json
    back_home
}
#apache防火墙
apache_waf(){
    clear
    wget -O ${panel_path}/plugin/btwaf_httpd/rule.json ${down_url}/Plugins-Dev/free_waf_r/rule.json
    back_home
}
#河马shell查杀
hema_shell(){
    clear
    wget -O ${panel_path}/plugin/hm_shell_san/rule.json ${down_url}/Plugins-Dev/free_waf_r/rule.json
    back_home
}
#简易木马扫描
muma_waf(){
    clear
    wget -O ${panel_path}/plugin/webshell/rule.json ${down_url}/Plugins-Dev/free_waf_r/rule.json
    back_home
}
#开启完全离线服务
open_offline(){
    rm -f ${panel_path}/data/home_host.pl
    echo 'True' >${panel_path}/data/not_network.pl
    echo '[ "127.0.0.1" ]' >${panel_path}/config/hosts.json
    sed -i 's/[0-9\.]\+[ ]\+www.bt.cn//g' /etc/hosts
    sed -i 's/[0-9\.]\+[ ]\+bt.cn//g' /etc/hosts
    sed -i 's/[0-9\.]\+[ ]\+download.bt.cn//g' /etc/hosts
    echo '192.168.88.127 www.bt.cn' >>/etc/hosts
    echo '192.168.88.127 bt.cn' >>/etc/hosts
    echo '192.168.88.127 download.bt.cn' >>/etc/hosts
    back_home
}
#关闭完全离线服务
close_offline(){
    rm -f ${panel_path}/data/home_host.pl
    rm -f ${panel_path}/data/not_network.pl
    wget -O ${panel_path}/config/hosts.json ${down_url}/Api/hosts.json
    sed -i 's/[0-9\.]\+[ ]\+www.bt.cn//g' /etc/hosts
    sed -i 's/[0-9\.]\+[ ]\+bt.cn//g' /etc/hosts
    sed -i 's/[0-9\.]\+[ ]\+download.bt.cn//g' /etc/hosts
    back_home
}
#格式化数据盘
format_disk(){
    stop_btpanel
    umount /dev/vdb
    mkfs.ext4 /dev/vdb
}
#宝塔工具箱
btpanel_tools(){
    wget -O btpanel_tools.sh ${down_url}/Shell/btpanel_tools.sh && bash btpanel_tools.sh
}
#LINUX工具箱
linux_tools(){
    echo -e "没啥卵用的垃圾脚本，不用也罢."
    # wget -O linux_tools.sh https://down.gacjie.cn/Linux/Shell/linux_tools.sh && bash linux_tools.sh
}
#新功能开发中
development(){
    clear
    echo -e "新功能开发中"
    back_home
}
#返回首页
back_home(){
	read -p "请输入0返回首页:" function
	if [[ "${function}" == "0" ]]; then
	    clear
		main
	else
		clear
		exit 0
	fi
	
}
# 退出脚本
delete(){
    clear
    echo -e "感谢使用筱杰宝塔工具箱"
    rm -rf /btpanel_tools.sh
    rm -rf btpanel_tools.sh
}
main(){
    clear
	echo -e "
#===================================================#
#  脚本名称:    BTPanel_tools Test Version 0.6      #
#  官方网站:    https://www.btpanel.cm/index/tools  #
#  交流方式：   Q群365208828 论坛bbs.gacjie.cn      #
#--------------------[实用工具]---------------------#
#(1)清理垃圾[清理系统面板网站产生的缓存日志文件慎用]#
#(2)登陆限制[去除宝塔linux面板强制登陆的限制]       #
#(3)停止服务[停止面板LNMP,Redis,Memcached服务]      #
#(4)修复环境[安装升级宝塔lnmp的环境只支持centos7]   #
#(5)修复面板[清理破解版修复面板环境并更新到官方最新]#
#(6)挂载磁盘[官方的一键自动挂载工具]                #
#(7)自动换源[目前只支持更换centos7的yum源]          #
#(8)卸载面板[本功能会清空所有数据卸载网站环境]      #
#(9)封装工具[高级功能不懂的不要执行以免数据丢失]    #
#(z)留存备份[计划任务备份到七牛等OSS在本地留存文件] #
#--------------------[降级版本]---------------------#
#(10)7.5.1 (11)7.4.8 (12)7.4.7 (13)7.4.6 (14)7.4.5  #
#-------------------[升级查杀库]--------------------#
#(15)免费Nginx防火墙      (16)收费Nginx防火墙       #
#(17)apache防火墙         (18)河马shell查杀         #
#(19)简易木马扫描         (20)简易木马扫描          #
#--------------------[离线宝塔]---------------------#
#(21)开启完全离线服务     (22)关闭完全离线服务      #
#注意:离线功能会完全断开与宝塔的通讯部分功能无法使用#
#--------------------[模版美化]---------------------#
#(23)永久企业[可将面板首页显示为永久企业版授权]     #
#(24)企业加速[网站加速插件显示企业版百分之百加速]   #
#(25)面板日志[恢复宝塔测试版日志清理功能(官方未删)] #
#--------------------[赞助广告]---------------------#
# 宝塔小栈(btpanel.cm),专业版授权10元起，欢迎购买。 #
# 亚当云(adamyun.com),安全专业的IDC服务商。         #
# FUNCDN(funcdn.com),高防高速高性价比CDN加速服务。  #
#--------------------[其他功能]---------------------#
#(a)BTPanel_tools   (b)Linux_tools    (0)退出脚本   #
#===================================================#
	"
	read -p "请输入需要输入的选项:" function
	case $function in
    1)  cleaning_garbage
    ;;
    2)  mandatory_landing
    ;;
    3)  stop_btpanel
    ;;
    4)  repair_environment
    ;;
    5)  update_panel
    ;;
    6)  mount_disk
    ;;
    7)  yum_source
    ;;
    8)  uninstall_btpanel
    ;;
    9)  package_btpanel
    ;;
    z)  keep_backup
    ;;
    10) version=7.5.1
        degrade_btpanel
    ;;
    11) version=7.4.8
        degrade_btpanel
    ;;
    12) version=7.4.7
        degrade_btpanel
    ;;
    13) version=7.4.6
        degrade_btpanel
    ;;
    14) version=7.4.5
        degrade_btpanel
    ;;
    15) free_nginx_waf
    ;;
    16) nginx_waf
    ;;
    17) apache_waf
    ;;
    18) hema_shell
    ;;
    19) muma_waf
    ;;
    20) muma_waf
    ;;    
    21) open_offline
    ;;
    22) close_offline
    ;;
    23) permanent_ltd
    ;;
    24) speed_ltd
    ;;
    25) panel_record
    ;;
    30) format_disk
    ;;
    a)  btpanel_tools
    ;;
    b)  linux_tools
    ;;
    *)  delete
    ;;
    esac
}
new_version