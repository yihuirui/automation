#!/bin/bash
#CentOS6.x初始化脚本
echo CentOS6
#更换第三方阿里云拓展源 
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
#安装常用软件
yum install lrzsz ntpdate sysstat -y
#安装gcc基础库文件以及sysstat工具
yum -y install gcc gcc-c++ vim-enhanced unzip unrar sysstat
#配置定时任务每5分钟校时
echo '*/5 * * * * /usr/sbin/ntpdate time.nist.gov >/dev/null 2>&1' >>/var/spool/cron/root
#配置文件的ulimit值
echo '*  -  nofile  65535' >> /etc/security/limits.conf
tail –l /etc/security/limits.conf
#定时清理邮件目录
echo '*/30 * * * * /bin/sh /server/scripts/spool_clean.sh >/dev/nul 2>&1'>>/var/spool/cron/root
#系统内核优化
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time =600
net.ipv4.ip_local_port_range = 4000    65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384
EOF
/sbin/sysctl -p
#禁用control-alt-delete组合键以防止误操作
sed -i 's@ca::ctrlaltdel:/sbin/shutdown -t3 -r now@#ca::ctrlaltdel:/sbin/shutdown -t3 -r now@' /etc/inittab
#关闭SElinux，关闭iptables
sed -i 's@SELINUX=enforcing@SELINUX=disabled@' /etc/selinux/config
/etc/init.d/iptables stop
#ssh服务配置优化
sed -i -e '74 s/^/#/' -i -e '76 s/^/#/' /etc/ssh/sshd_config
sed -i 's@#UseDNS yes@UseDNS no@' /etc/ssh/sshd_config
service sshd restart

#vim基础语法优化
echo "syntax on" >> /root/.vimrc
echo "set nohlsearch" >> /root/.vimrc
#停用系统中不必要的服务
chkconfig bluetooth off
chkconfig sendmail off
chkconfig kudzu off
chkconfig nfslock off
chkconfig portmap off
chkconfig iptables off
chkconfig autofs off
chkconfig yum-updatesd off
#重启服务器
reboot

