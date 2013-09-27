#!/bin/bash
#ssh ubuntu@115.146.85.98
# ensure the pt-1589.pem RSA private key is on the API VM so we can (parallel-)ssh directly to instantiated VMs 
source ~/BIG-SA.rc
old_image='NGSTrainingV1.2'
new_image='NGSTrainingV1.2.1'
tmp_vm='NGSTraining'


# See what flavours and images are available
# glance image-list
# nova flavor-list

nova boot \
    ${tmp_vm} \
    --image $(nova image-show ${old_image} | fgrep -w id | perl -ne 'print "$1" if /\|\s+(\S+)\s+\|$/') \
    --flavor 4 \
    --security-groups "SSH" \
    --key-name pt-1589 \
    --meta description="${tmp_vm}" \
    --meta creator='Nathan S. Watson-Haigh'

ssh -i ~/pt-1589.pem ubuntu@$(nova list --name '${tmp_vm}' | perl -ne 'print "$2" if /(${tmp_vm}).+?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/')

# Add missing repo keys for NGSTrainingV1.2 image
#sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B1A598E8128B92BD
#sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 2a8e3034d018a4ce

# Add some convieniant desktop launchers
# sudo su
# cd /home/ngstrainee/Desktop
#
#
#echo "[Desktop Entry]
#Name=Firefox
#Type=Application
#Encoding=UTF-8
#Comment=A dropcanvas for NGS workshop materials
#Exec=firefox
#Icon=/usr/lib/firefox/icons/mozicon128.png
#Terminal=FALSE" > firefox.desktop
#
#echo "[Desktop Entry]
#Name=Terminal
#Comment=Use the command line
#TryExec=gnome-terminal
#Exec=gnome-terminal
#Icon=utilities-terminal
#Type=Application
#X-GNOME-DocPath=gnome-terminal/index.html
#X-GNOME-Bugzilla-Bugzilla=GNOME
#X-GNOME-Bugzilla-Product=gnome-terminal
#X-GNOME-Bugzilla-Component=BugBuddyBugs
#X-GNOME-Bugzilla-Version=3.4.1.1
#Categories=GNOME;GTK;Utility;TerminalEmulator;
#StartupNotify=true
#OnlyShowIn=GNOME;Unity;
#Keywords=Run;
#Actions=New
#X-Ubuntu-Gettext-Domain=gnome-terminal
#
#[Desktop Action New]
#Name=New Terminal
#Exec=gnome-terminal
#OnlyShowIn=Unity" > gnome-terminal.desktop
#
#echo "[Desktop Entry]
#Name=gedit
#GenericName=Text Editor
#Comment=Edit text files
#Keywords=Plaintext;Write;
#Exec=gedit %U
#Terminal=false
#Type=Application
#StartupNotify=true
#MimeType=text/plain;
#Icon=accessories-text-editor
#Categories=GNOME;GTK;Utility;TextEditor;
#X-GNOME-DocPath=gedit/gedit.xml
#X-GNOME-FullName=Text Editor
#X-GNOME-Bugzilla-Bugzilla=GNOME
#X-GNOME-Bugzilla-Product=gedit
#X-GNOME-Bugzilla-Component=general
#X-GNOME-Bugzilla-Version=3.4.1
#X-GNOME-Bugzilla-ExtraInfoScript=/usr/share/gedit/gedit-bugreport
#Actions=Window;Document;
#X-Ubuntu-Gettext-Domain=gedit
#
#[Desktop Action Window]
#Name=Open a New Window
#Exec=gedit --new-window
#OnlyShowIn=Unity;
#
#[Desktop Action Document]
#Name=Open a New Document
#Exec=gedit --new-window
#OnlyShowIn=Unity;" > gedit.desktop
#chmod 700 *.desktop
#chown ngstrainee:ngstrainee *.desktop

    
sudo apt-get update \
    && sudo apt-get -y dist-upgrade \
    && sudo reboot

exit

# snapshot the instance and make it publicly available
nova image-create ${tmp_vm} ${new_image}
glance image-update --is-public True ${new_image}
# Check snapshot progress:
#nova image-show ${new_image}

# download the new image onto secondary storage
# How about piping it directly into qemu-img and then into swift upload? Maybe something like:
#swift upload -S 1073741824 VMs <(qemu-img convert -O vdi <(glance image-download ${new_image}))
sudo mkdir --mode 777 /mnt/tmp; cd /mnt/tmp;
glance image-download --file ${new_image}.raw ${new_image}
# convert it to VDI (VirtualBox) format
qemu-img convert -O vdi ${new_image}.raw ${new_image}.vdi
# upload into cloud storage in 1GB segments and make the container readable and listable by everyone
swift upload -S 1073741824 VMs ${new_image}.vdi 
swift post --read-acl='.r:*,.rlistings' VMs
swift post --read-acl='.r:*,.rlistings' VMs_segments
# Public URL for vdi image
echo https://swift.rc.nectar.org.au:8888/v1/AUTH_33065ff5c34a4652aa2fefb292b3195a/VMs/${new_image}.vdi

# Cleanup
rm ${new_image}.{raw,vdi}
