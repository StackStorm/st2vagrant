# How to set up lighting demo


1. Configure a bridge network for interface that connects to the switch with R-PIs

    ```
    # Set up bridge to talk to R-Pi.
    st2.vm.network "public_network", ip: "172.16.1.1", bridge: 'en7: Apple USB Ethernet Adapter', :netmask => "255.255.255.0"
    ```

    Big NB: If the network config happen to coniside with R-PI static IP configuration,
    cut out the crap with DHCP and move straight to step 5

2. Set up and configure the DHCP service on Vagrant. The script [scripts/dhcp.sh](scripts/dhcp.sh) capture
    installation steps on Ubuntu 16.

    2.1 Install

    ```
    sudo apt-get update
    sudo apt-get install isc-dhcp-server
    ```

    2.2 Configure DHCP

    ```
    sudo sed -i 's/INTERFACES.*/INTERFACES="enp0s9"/g' /etc/dhcp/dhclient.conf


    sudo tee -a /etc/dhcp/dhcpd.conf cat << EOT
    subnet 172.16.1.0 netmask 255.255.255.0 {
      range 172.16.1.100 172.16.1.200;
    }
    EOT

    ```

    2.3 Restart the service and make sure it runs ok

    ```
    sudo service isc-dhcp-server restart
    sudo service isc-dhcp-server status

    ```

3. Connect your berries, see them in place, run services on them

    ```
    cat /var/lib/dhcp/dhcpd.leases
    ```

    Run the services: there are `./start.sh` on both berries.

4. Install stackstorm if not yet installed.

5. Get the demo packs:

Led pack: https://github.com/StackStorm/led_pack. Configure the `switch` and `led` controller endpoints,
taking the IP addresses from the "Connect your berries" step above. Watch for trailing slashes
in URLs: '/leds/' work but '/leds' don't.

    * Check the led controller:

    ```
    st2 run led_pack.set-leds blue=100 red=100 green=0 is_on=true change=true

    st2 run led_pack.read-leads
    ```

    * Check the switch controller. Don't forget to start the controller on the R-Pi.
    Press the button, ensure that trigger is triggered.

    ```
    st2 run led_pack read-switch

    st2 sensor list --pack=led_pack

    st2 trigger list --pack=led_pack

    # check that the trigger fires
    st2 trigger-instance list --trigger=led_pack.switch_change


Twitter pack: install the pack from stackstorm exchange, https://github.com/StackStorm-Exchange/stackstorm-twitter

Configure credentials per [README.md](https://github.com/StackStorm-Exchange/stackstorm-twitter/blob/master/README.md). For TwitterStreamingSensor which we use here BOTH pairs of consumer key/secret and access token/secret must be configured. Play with the rule in `led_pack` to filter out what you don't wanna see.



