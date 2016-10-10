#!/usr/bin/env bash

##########################################################################################
# Disable SELINUX
setenforce 0
sed -i 's/\(^[^#]*\)SELINUX=enforcing/\1SELINUX=disabled/' /etc/selinux/config
sed -i 's/\(^[^#]*\)SELINUX=permissive/\1SELINUX=disabled/' /etc/selinux/config

##########################################################################################
# Set swappiness to minimum
echo 0 | tee /proc/sys/vm/swappiness

# Set the value in /etc/sysctl.conf so it stays after reboot.
echo '' >> /etc/sysctl.conf
echo '#Set swappiness to 0 to avoid swapping' >> /etc/sysctl.conf
echo 'vm.swappiness = 0' >> /etc/sysctl.conf

##########################################################################################
# Disable some not-required services.
chkconfig cups off
chkconfig postfix off
chkconfig iptables off
chkconfig ip6tables off

service iptables stop
service ip6tables stop

##########################################################################################
# Ensure NTPD is turned on and run update
yum install -y ntp
chkconfig ntpd on
ntpd -q
service ntpd start

##########################################################################################
# Remove OpenJDK
yum clean all
yum -y erase *openjdk*

##########################################################################################
#Disable transparent huge pages
echo never > /sys/kernel/mm/transparent_hugepage/defrag
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo no > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag 

echo '' >> /etc/rc.local
echo '#Disable THP' >> /etc/rc.local
echo 'if test -f /sys/kernel/mm/transparent_hugepage/enabled; then' >> /etc/rc.local
echo '  echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local
echo 'fi' >> /etc/rc.local
echo '' >> /etc/rc.local
echo 'if test -f /sys/kernel/mm/transparent_hugepage/defrag; then' >> /etc/rc.local
echo '   echo never > /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.local
echo 'fi' >> /etc/rc.local
echo '' >> /etc/rc.local
echo 'if test -f /sys/kernel/mm/transparent_hugepage/khugepaged/defrag; then' >> /etc/rc.local
echo '   echo no > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag' >> /etc/rc.local
echo 'fi' >> /etc/rc.local