<?xml version="1.0"?>
<installation srtype="ext">
    <primary-disk>sda</primary-disk>
    <keymap>us</keymap>
    <root-password type="hash">$ROOT_PASS_HASH</root-password>
    <source type="local"></source>
    <admin-interface name="eth0" proto="dhcp"/>
    <timezone>utc</timezone>
    <network-backend>vswitch</network-backend>
    <post-installation-script type="url">
        http://$PACKER_HTTP_ADDR/post-install.sh
    </post-installation-script>
</installation>
