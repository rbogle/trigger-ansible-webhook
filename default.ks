install
lang en_US.UTF-8
keyboard us
timezone America/NewYork
text
skipx

auth --useshadow --enablemd5
rootpw --iscrypted $1$oR.AO2.H$lbgM5Gl5FgYqrj7d51Cxs/

selinux --disabled
network --onboot yes --bootproto dhcp
firewall --disabled

bootloader --location=mbr
zerombr
clearpart --all --initlabel
autopart

url --url="http://mirror.centos.org/centos-7/7/os/x86_64/"
repo --name=base --baseurl=http://mirror.centos.org/centos-7/7/os/x86_64/
repo --name=EPEL7 --baseurl=http://dl.fedoraproject.org/pub/epel/7/x86_64/ 

reboot
firstboot --disable

%packages 
@^compute-node-environment
@base
@core
@debugging
@development
@scientific
kexec-tools
%end

%post
# ============= setup up root key for ssh =====================

# root auth_keys
/bin/mkdir /root/.ssh
/bin/chmod 700 /root/.ssh
cat >> /root/.ssh/authorized_keys << "PUBLIC_KEY"
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGspyT/eNhr+KqsiFdu0qXiTL2b4WDcMd/hgaySl4MrzGvQ7GBWofzg1VtK3ZWTqf15HmazXvdydy4eceNq47osApXb9cK6lsQ3BJPRg6qvR28jz2Dbc4NISSkcSzOryf9kmay3o8s9Fm6CheppUPUfRRqvWr6yD2iAfQCLZDhT/sYxjKkzjyl0FL7M+sJnlCg97KJ7F4ft5qOd3mL6UuXlpr72Qv0cS2KFAiylRa5cPHeinivO2H9JBXAz8Q4uCZOBsWMCuXt+aIXq4h/+ser6TNxfoNzjYHxUYPanJ5oGoLjF5bh5edqFUy3gLJzBBAavMcZ+Cc7KRZNXtHW/Uzt root@desktop
PUBLIC_KEY
/bin/chmod 600 /root/.ssh/authorized_keys

# =============== END Root Key setup =========================

# =============== Call Ansible script on reboot ===============


#setup firstboot callback to kickoff ansible configuration

/bin/chmod a+x /etc/rc.d/rc.local
echo "/root/run_ansible.sh" >> /etc/rc.d/rc.local

# write firstboot.sh script to be run onetime 
cat >> /root/run_ansible.sh << "EOF"
#!/bin/bash

#Trigger ansible run with web callback to desktop
curl -o /dev/null http://192.168.1.1:9000/hooks/trigger-ansible?playbook=install\&host=$(hostname) &

#Remove this script's call from rc.local so it doesn't happen every boot
sed -i "/run_ansible.sh/d" /etc/rc.d/rc.local
#rm /root/run_ansible.sh
EOF

/bin/chmod a+x /root/run_ansible.sh
# =============== End Call Ansible ============================

%end
