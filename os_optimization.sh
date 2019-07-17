#!/bin/bash
#author Linsir
#this script is only for CentOS 7.x

osCheck(){
  os_version=`uname -r|awk -F '.' '{print $6}'`
  if [ ${os_version} != "el7" ];then 
    echo "this script is only for Centos-7 Operating System !"
    exit 1
  fi


  cat << EOF
  +---------------------------------------+
  |   your system is CentOS 7 x86_64      |
  |      start optimizing.......          |
  +---------------------------------------+
EOF
}


osOptimization() {
  #安装wget 
  yum install -y wget > /dev/null 2>&1 
  
  
  #yum源更换为国内阿里源
  mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup 
  wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 
  wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo 
  yum clean all 
  yum makecache  
  
  
  #安装基础软件包
  yum install -y  net-tools vim tree htop iotop ntpdate \
  lrzsz sl wget unzip telnet nmap nc psmisc  lsof \
  bash-completion iftop sysstat  > /dev/null 2>&1
  
  
  #更改时区,同步时间
  mv /etc/localtime /etc/localtime.bak
  
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  
  /usr/sbin/ntpdate time.aliyun.com
  echo "*/5 * * * * /usr/sbin/ntpdate time.aliyun.com > /dev/null 2>&1" >> /var/spool/cron/root
  
  
  
  #设置最大打开文件描述符数
  ulimit -SHn 655350
  cat >> /etc/security/limits.conf << EOF
  *           soft   nofile       655350
  *           hard   nofile       655350
EOF
  
  
  #禁用selinux
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
  setenforce 0
  iptables -F && iptables -F -t nat 
  iptables-save
  
  
  #关闭防火墙和postfix、NetworkManager
  systemctl disable firewalld.service  postfix.service NetworkManager
  systemctl stop firewalld.service postfix.service NetworkManager
  
  
  #优化sshd
  /bin/cp /etc/ssh/sshd_config /etc/ssh/sshd_config.ori
  sed -i 's#Port 22#Port 51234#g' /etc/ssh/sshd_config
  sed -i 's#\#UseDNS yes#UseDNS no#g' /etc/ssh/sshd_config
  sed -i 's#GSSAPIAuthentication yes#GSSAPIAuthentication no#g' /etc/ssh/sshd_config
  sed -i 's#\#AddressFamily any#AddressFamily inet#g' /etc/ssh/sshd_config
  
  #内核参数优化
  cat >> /etc/sysctl.conf << EOF
  vm.overcommit_memory = 1
  vm.swappiness = 0
  net.ipv4.tcp_fin_timeout = 1
  net.ipv4.tcp_keepalive_time = 1200
  net.ipv4.tcp_tw_reuse = 1
  net.ipv4.tcp_tw_recycle = 1
  net.ipv4.tcp_timestamps = 0
  net.ipv4.tcp_synack_retries = 1
  net.ipv4.tcp_syn_retries = 1
  net.ipv4.tcp_max_syn_backlog = 262144
  net.ipv4.tcp_max_orphans = 3276800
  
  net.core.rmem_max = 16777216
  net.core.wmem_max = 16777216
  net.core.wmem_default = 8388608
  net.core.rmem_default = 8388608
  
  net.core.netdev_max_backlog = 262144
  net.core.somaxconn = 65535
  
  net.nf_conntrack_max = 25000000
  net.netfilter.nf_conntrack_max = 25000000
  net.netfilter.nf_conntrack_tcp_timeout_established = 180
  net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
  net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
  net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
  
EOF
  /sbin/sysctl -p
  
  cat <<EOF
    +-------------------------------------------------+
    |               optimizer is done                 |
    |   it's recommond to restart this server !       |
    +-------------------------------------------------+
EOF
  
}
  
  
  
  
main() {
   echo "In system optimization, please wait a moment."
   osCheck
   osOptimization
}

main
