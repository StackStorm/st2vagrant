set -e

sudo apt-get update
sudo apt-get install -y isc-dhcp-server

sudo sed -i 's/INTERFACES.*/INTERFACES="enp0s9"/g' /etc/dhcp/dhclient.conf

sudo tee -a /etc/dhcp/dhcpd.conf cat << EOT
subnet 172.16.1.0 netmask 255.255.255.0 {
  range 172.16.1.100 172.16.1.200;
}
EOT

sudo service isc-dhcp-server restart

echo `sudo service isc-dhcp-server status`
echo `cat /var/lib/dhcp/dhcpd.leases`