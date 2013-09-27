#!/bin/bash
apt-get update
apt-get -y dist-upgrade
apt-get -y install ubuntu-desktop gnome-session-fallback python-software-properties
add-apt-repository -y ppa:freenx-team
apt-get update
apt-get -y install freenx
cd /tmp
wget https://bugs.launchpad.net/freenx-server/+bug/576359/+attachment/1378450/+files/nxsetup.tar.gz
tar xzf nxsetup.tar.gz
cp nxsetup /usr/lib/nx/nxsetup
/usr/lib/nx/nxsetup --auto --install
ssh-keygen -f "/var/lib/nxserver/home/.ssh/known_hosts" -R 127.0.0.1
sed -i -e 's/^.\(NX_LOG_LEVEL\)=.$/\1=6/' /etc/nxserver/node.conf
sed -i -e 's/^#\(NX_LOGFILE\)/\1/' /etc/nxserver/node.conf
sed -i -e 's/^.\(ENABLE_SSH_AUTHENTICATION\)="."$/\1="1"/' /etc/nxserver/node.conf
sed -i -e 's/^#\(SSHD_PORT\)/\1/' /etc/nxserver/node.conf
# enable ssh login with passwords
sudo sed -i -e 's@PasswordAuthentication no@PasswordAuthentication yes@' /etc/ssh/sshd_config
# restart SSH service and NX Server
sudo service ssh reload
sudo nxserver --restart

# add default users
useradd --shell /bin/bash --create-home --coment "Trainee user" trainee
echo -e "ubuntu:ubuntu_password\ntrainee:trainee_password" | chpassword
sync
#reboot
