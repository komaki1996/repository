#1.インストール**************************************************
#sudo apt-get update
#sudo apt-get install hostapd udhcpd -y
#sudo apt-get install iptables -y
#sudo apt-get install zip unzip -y
#sudo apt-get update

#2.DHCP設定 *********************************************-
x=tem.tem
touch $num
sudo rm -rf /etc/default/udhcpd
sudo mkdir /etc/default
sudo touch /etc/default/udhcpd
echo "start 10.0.0.100 " >>   $num
echo "end 10.0.0.120" >> $num
echo "interface wlan0" >> $num
echo "remaining yes" >> $num
echo "opt dns 8.8.8.8 4.2.2.2" >> $num
echo "opt subnet 255.255.255.0" >> $num
echo "opt router 10.0.0.1" >> $num
echo "opt lease 864000" >> $num
sudo mv  $num /etc/udhcpd.conf
touch $num
echo  "# Comment the following line to enable" >> $num
echo "#DHCPD_ENABLED=\"no\"" >> $num
echo "# Options to pass to busybox' udhcpd." >> $num
echo "# -S    Log to syslog" >> $num
echo "# -f    run in foreground" >> $num
echo "DHCPD_OPTS=\"-S\"" >> $num
sudo mv $num  /etc/default/udhcpd

sudo ifconfig wlan0 10.0.0.1
#************入力インターフェース設定*************************************
touch $num
sudo cp  /etc/network/interfaces /etc/network/interfaces.bk
echo "source-directory /etc/network/interfaces.d" >> $num
echo "auto lo" >> $num
echo "iface lo inet loopback" >> $num
echo "" >> $num
echo "auto eth0" >> $num
echo "iface eth0 inet dhcp" >> $num
echo "" >> $num
echo "allow-hotplug wlan0" >> $num
echo "iface wlan0 inet dhcp" >> $num
echo "    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf" >> $num
echo "    wireless-power off" >> $num
echo "" >> $num
echo "iface default inet dhcp" >> $num
sudo chown --reference=/etc/network/interfaces $num
sudo chmod --reference==/etc/network/interfaces $num
sudo mv $num /etc/network/interfaces
sudo cp /etc/network/interfaces /etc/network/interfaces.sta 
sudo chmod --reference /etc/network/interfaces.bk /etc/network/interfaces.sta
#******************************出力APインターフェース設定******************************-
touch  $num
echo "source-directory /etc/network/interfaces.d" >> $num
echo "auto lo" >> $num
echo "iface lo inet loopback" >> $num
echo "" >> $num
echo "auto eth0" >> $num
echo "iface eth0 inet dhcp" >> $num
echo "" >> $num
echo "iface wlan0 inet static" >> $num
echo "    address 10.0.0.1" >> $num
echo "    netmask 255.255.255.0" >> $num
echo "    wireless-power off" >> $num
echo "" >> $num
echo "iface default inet dhcp" >> $num
echo "up iptables-restore < /etc/iptables.ipv4.nat" >> $num
sudo chmod --reference==/etc/network/interfaces $num
sudo chown --reference=/etc/network/interfaces $num
sudo mv $num  /etc/network/interfaces.ap
sudo chmod --reference /etc/network/interfaces.bk /etc/network/interfaces.ap
#Config /etc/wpa_supplicant/wpa_supplicant.conf
touch $num
sudo rm -rf /etc/wpa_supplicant/wpa_supplicant.conf
sudo mkdir /etc/wpa_supplicant
sudo touch /etc/wpa_supplicant/wpa_supplicant.conf
echo "ctrl_interface=/var/run/wpa_supplicant" >> $num
echo "update_config=1" >> $num
echo "network={" >> $num
echo "        ssid=\"\"" >> $num
echo "        psk=\"\"" >> $num
echo "}" >> $num
sudo mv $num /etc/wpa_supplicant/wpa_supplicant.conf

#3. *****************************HostAPD設定****************************************
# 現在はFreeWifiの設定、パスワード認証をしたい場合は、下記のコメントアウトを削除し、wmm_enabled=0をコメントアウトする
touch $num
echo "interface=wlan0" >> $num
echo "driver=nl80211" >> $num
echo "ssid=My_AP" >> $num
echo "hw_mode=g" >> $num
echo "channel=6" >> $num
echo "macaddr_acl=0" >> $num
echo "auth_algs=1" >> $num
echo "ignore_broadcast_ssid=0" >> $num
echo "#wpa=2" >> $num
echo "#wpa_passphrase=raspberry" >> $num
echo "#wpa_key_mgmt=WPA-PSK" >> $num
echo "#wpa_pairwise=TKIP" >> $num
echo "#rsn_pairwise=CCMP" >> $num
echo "wmm_enabled=0" >> $num
sudo mv  $num  /etc/hostapd/hostapd.conf
#4. ******************************NAT設定*********************************************
touch $num
echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"" >> $num
sudo mv $num /etc/default/hostapd
touch $num
sudo sh -c "echo 1 >> /proc/sys/net/ipv4/ip_forward"
sudo echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
sudo sh -c "iptables-save >> /etc/iptables.ipv4.nat"
#******************************5. サービススタート R****************************************
sudo service hostapd start
sudo service udhcpd start
#******************************6.hotspot スタートonブート********************
sudo update-rc.d hostapd enable
sudo update-rc.d udhcpd enable
#*************************Wifi作成***********************************
sudo apt-get install dnsmasq -y
sudo service dnsmasq start
sudo update-rc.d dnsmasq enable
sudo apt-get install udhcpc -y
sudo cp ap.sh /usr/bin/ap
