#cloud-config
apt_upgrade: true
ssh_deletekeys: false
preserve_hostname: false
fqdn: ${fqdn}
manage_etc_hosts: true
