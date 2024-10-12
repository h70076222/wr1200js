#!/bin/sh

##编写：hong

sz="$@"
/usr/bin/vpn --stop
#关闭vnt的防火墙
iptables -D INPUT -i vnt-tun -j ACCEPT 2>/dev/null
iptables -D FORWARD -i vnt-tun -o vnt-tun -j ACCEPT 2>/dev/null
iptables -D FORWARD -i vnt-tun -j ACCEPT 2>/dev/null
iptables -t nat -D POSTROUTING -o vnt-tun -j MASQUERADE 2>/dev/null
killall vpn
killall -9 vpn
sleep 3
#清除vpn的虚拟网卡
ifconfig vnt-tun down && ip tuntap del vnt-tun mode tun

if [ "${vpn}" == "" ] ; then
vpn="/usr/bin/vpn"

test ! -x "${vpn}" && chmod +x "${vpn}"
##判断文件有无执行权限，无赋予运行权限

 [ ! -d "/tmp/log/" ] &&  mkdir "/tmp/log/"

vpn_dirname=$(dirname "${vpn}") # 返回执行文件所在的目录



###############################


test -n "`pidof vpn`" && killall vpn

if [ -f "/etc/storage/post_wan_script.sh" ] ; then
boot="/etc/storage/post_wan_script.sh"

if [ -z "`cat $boot | grep -o '\-k'`" ] ; then
cat <<'EOF10'>> "$boot"
sleep 20 && /usr/bin/vpn.sh &
:<<'________'
VPN异地组网配置区
#以下改IP参数，虚似IP最后一位也要对应改，和-d要一起改
#如改本地192.168.30.1,-d 就改30 -o改10.26.0.30
#远端改(另一个路由)-i 192.168.30.0/24,10.26.0.30
-k abc   #串码 所有组网相同
#-s        #服务器地址
-d 20     #路由的名字，不能和组网同名 如：-d  1 2 3
-i 192.168.10.0/24,10.26.0.10   # 对端路由IP,对端路由的虚拟IP 例如:-i 192.168.1.0/24,10.26.0.11
#-i 192.168.1.0/24,10.26.0.11  #多个组网可多个-i就是远端有内个就几个-i前面#列示不用
-o 192.168.20.0/24 #   本路由IP 如：-o 192.168.1.0/24
--ip 10.26.0.20 #   本路由的虚拟IP 如：--ip 10.26.0.11

________
EOF10

fi

fi
 [ -n "`cat $boot | grep -o '\-k'`" ] && aswr=$(cat $boot | grep '\-k' | awk -F '#' '{print $1}' )
 [ -n "`cat $boot | grep -o '\-s'`" ] && white=$(cat $boot | grep '\-s' | awk -F '#' '{print $1}' )
 [ -n "`cat $boot | grep -o '\-d'`" ] && white_token=$(cat $boot | grep '\-d' | awk -F '#' '{print $1}' )
 [ -n "`cat $boot | grep -o '\-i'`" ] && gateway=$(cat $boot | grep '\-i' | awk -F '#' '{print $1}' )
 [ -n "`cat $boot | grep -o '\-o'`" ] && netmask=$(cat $boot | grep '\-o' | awk -F '#' '{print $1}' )
 [ -n "`cat $boot | grep -o '\-ip'`" ] && finger=$(cat $boot | grep '\-ip' | awk -F '#' '{print $1}' )

 
echo "./vpn $aswr $white $white_token $gateway $netmask &"

vpn_dirname=$(dirname ${vpn})

cd $vpn_dirname && ./vpn $aswr $white $white_token $gateway $netmask &

sleep 3
if [ ! -z "`pidof vpn`" ] ; then
logger -t "vpn" "启动成功"
#放行vnt防火墙
iptables -I INPUT -i vnt-tun -j ACCEPT
iptables -I FORWARD -i vnt-tun -o vnt-tun -j ACCEPT
iptables -I FORWARD -i vnt-tun -j ACCEPT
iptables -t nat -I POSTROUTING -o vnt-tun -j MASQUERADE
#开启arp
ifconfig vnt-tun arp
else
logger -t "vpn" "启动失败"
fi
