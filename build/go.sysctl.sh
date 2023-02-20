sed -i.bak "/^kernel.shmmax/ d" /etc/sysctl.conf
echo "kernel.shmmax=8446744073709551615" >>/etc/sysctl.conf
