#!/bin/bash
# Install/update the tools required for interacting with the NeCTAR Research Cloud APIs 
if [[ -d openstack_scripts ]]; then
  cd openstack_scripts
  git pull
  cd ../
else
  git clone https://gist.github.com/6532344.git openstack_scripts
fi
./openstack_scripts/update_openstack_python_apis.sh

# Source the RC file for the project under which VM's will be launched
source ~/BIG-SA.rc

# See what flavours and images are available
# glance image-list
# nova flavor-list

# Details for launching the VM's
VM_NAME_PREFIX='SWC_Bootcamp'
BASE_IMAGE_NAME='Software Carpentry'
CELL='monash'
# Generate a username and random password for the trainee user account to be associated with these VMs
REMOTE_USERNAME='swc_trainee'
REMOTE_USER_FULL_NAME='Software Carpentry Trainee'
REMOTE_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-30};echo;)
REMOTE_UBUNTU_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-30};echo;)

# Create a directory under which we'll store files associated with the launch of these VMs
#DIR=`mktemp -d --tmpdir=./` && cd ${DIR}
DIR=${VM_NAME_PREFIX}
mkdir ${DIR}; cd ${DIR}

##########
# Put the following script into a file so it can passed to each instantiated VM
##########
VM_CONFIG_SCRIPT=`mktemp --tmpdir=./`
cat > ${VM_CONFIG_SCRIPT} <<SCRIPT
#!/bin/bash
apt-get update
# add the trainee user with SSH password access
useradd --shell /bin/bash --create-home --comment "${REMOTE_USER_FULL_NAME}" ${REMOTE_USERNAME}
echo -e "swc_trainee:${REMOTE_PASSWORD}\nubuntu:${REMOTE_UBUNTU_PASSWORD}" | chpasswd

# Install required packages
#####
apt-get install -y raxml muscle python-biopython python-pip openjdk-7-jdk
pip install sphinx
# Eclipse and plugin installation
wget http://mirror.aarnet.edu.au/pub/eclipse/technology/epp/downloads/release/kepler/R/eclipse-standard-kepler-R-linux-gtk-x86_64.tar.gz
tar xzf eclipse-standard-*-R-linux-gtk-x86_64.tar.gz
mv eclipse /opt/
ln -s /opt/eclipse/eclipse /usr/local/bin/eclipse
eclipse \
-noSplash \
-application org.eclipse.equinox.p2.director \
-repository http://download.eclipse.org/releases/kepler,http://pydev.org/updates,http://download.walware.de/eclipse-4.2,http://e-p-i-c.sf.net/updates/testing \
-installIU org.eclipse.epp.mpc.feature.group,org.eclipse.egit.feature.group,org.eclipse.jgit.feature.group,org.python.pydev.feature.feature.group,de.walware.statet.r.feature.group,org.epic.feature.main.feature.group

# First create the user's Desktop directory if it doesn't already exist
if [[ ! -e "/home/${REMOTE_USERNAME}/Desktop" ]]; then
  mkdir --mode=755 /home/${REMOTE_USERNAME}/Desktop
fi
chown ${REMOTE_USERNAME}:${REMOTE_USERNAME} /home/${REMOTE_USERNAME}/Desktop

# Add a standard Firefox shortcut to the desktop
#####
echo "[Desktop Entry]
Name=Firefox
Type=Application
Encoding=UTF-8
Comment=Firefox Web Browser
Exec=firefox
Icon=/usr/lib/firefox/browser/icons/mozicon128.png
Terminal=FALSE" > /home/${REMOTE_USERNAME}/Desktop/firefox.desktop

# Add a standard gedit shortcut to the desktop
#####
echo "[Desktop Entry]
Name=gedit
GenericName=Text Editor
Comment=Edit text files
Keywords=Plaintext;Write;
Exec=gedit %U
Terminal=false
Type=Application
StartupNotify=true
MimeType=text/plain;
Icon=accessories-text-editor
Categories=GNOME;GTK;Utility;TextEditor;
X-GNOME-DocPath=gedit/gedit.xml
X-GNOME-FullName=Text Editor
X-GNOME-Bugzilla-Bugzilla=GNOME
X-GNOME-Bugzilla-Product=gedit
X-GNOME-Bugzilla-Component=general
X-GNOME-Bugzilla-Version=3.4.1
X-GNOME-Bugzilla-ExtraInfoScript=/usr/share/gedit/gedit-bugreport
Actions=Window;Document;
X-Ubuntu-Gettext-Domain=gedit

[Desktop Action Window]
Name=Open a New Window
Exec=gedit --new-window
OnlyShowIn=Unity;

[Desktop Action Document]
Name=Open a New Document
Exec=gedit --new-window
OnlyShowIn=Unity;" > /home/${REMOTE_USERNAME}/Desktop/gedit.desktop

# Add a terminal shortcut to the desktop
#####
echo "[Desktop Entry]
Name=Terminal
Comment=Use the command line
TryExec=gnome-terminal
Exec=gnome-terminal
Icon=utilities-terminal
Type=Application
X-GNOME-DocPath=gnome-terminal/index.html
X-GNOME-Bugzilla-Bugzilla=GNOME
X-GNOME-Bugzilla-Product=gnome-terminal
X-GNOME-Bugzilla-Component=BugBuddyBugs
X-GNOME-Bugzilla-Version=3.4.1.1
Categories=GNOME;GTK;Utility;TerminalEmulator;
StartupNotify=true
OnlyShowIn=GNOME;Unity;
Keywords=Run;
Actions=New
X-Ubuntu-Gettext-Domain=gnome-terminal

[Desktop Action New]
Name=New Terminal
Exec=gnome-terminal
OnlyShowIn=Unity" > /home/${REMOTE_USERNAME}/Desktop/gnome-terminal.desktop

# Add an Eclipse shortcut to the desktop
#####
echo "[Desktop Entry]
Name=Eclipse IDE
Type=Application
Encoding=UTF-8
Comment=Eclipse Integrated Development Environment
Exec=eclipse
Icon=/opt/eclipse/icon.xpm
Terminal=FALSE" > /home/${REMOTE_USERNAME}/Desktop/eclipse.desktop

######################################
## Adelaide Specific Configurations ##
######################################

# Set the time zone
#####
echo 'Australia/Adelaide' > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# Add the ADL etherpad shortcut to the desktop
#####
echo "[Desktop Entry]
Name=Adelaide SWC Boot Camp Etherpad
Type=Application
Encoding=UTF-8
Comment=Etherpad
Exec=firefox https://etherpad.mozilla.org/swcadelaide
Icon=/usr/lib/firefox/browser/icons/mozicon128.png
Terminal=FALSE" > /home/${REMOTE_USERNAME}/Desktop/adl_etherpad.desktop

# Add the #swcadl hashtag shortcut to the desktop
#####
echo "[Desktop Entry]
Name=Adelaide SWC Boot Camp Tweet
Type=Application
Encoding=UTF-8
Comment=Tweet about this Software Carpentry Bootcamp using our hashtag
Exec=firefox https://twitter.com/intent/tweet?button_hashtag=swcadl
Icon=/usr/lib/firefox/browser/icons/mozicon128.png
Terminal=FALSE" > /home/${REMOTE_USERNAME}/Desktop/adl_tweet.desktop

#######################################
## Melbourne Specific Configurations ##
#######################################

# Set the time zone
#####
echo 'Australia/Melbourne' > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# Add the MEL etherpad shortcut to the desktop
#####
echo "[Desktop Entry]
Name=Melbourne SWC Boot Camp Etherpad
Type=Application
Encoding=UTF-8
Comment=Etherpad
Exec=firefox https://etherpad.mozilla.org/swcmelbourne
Icon=/usr/lib/firefox/browser/icons/mozicon128.png
Terminal=FALSE" > /home/${REMOTE_USERNAME}/Desktop/mel_etherpad.desktop

# Add the #swcmel hashtag shortcut to the desktop
#####
echo "[Desktop Entry]
Name=Melbourne SWC Boot Camp Tweet
Type=Application
Encoding=UTF-8
Comment=Tweet about this Software Carpentry Bootcamp using our hashtag
Exec=firefox https://twitter.com/intent/tweet?button_hashtag=swcmel
Icon=/usr/lib/firefox/browser/icons/mozicon128.png
Terminal=FALSE" > /home/${REMOTE_USERNAME}/Desktop/mel_tweet.desktop

chmod 700 /home/${REMOTE_USERNAME}/Desktop/*.desktop
chown ${REMOTE_USERNAME}:${REMOTE_USERNAME} /home/${REMOTE_USERNAME}/Desktop/*.desktop

apt-get dist-upgrade -y
reboot
SCRIPT
##########
less ${VM_CONFIG_SCRIPT}


../openstack_scripts/VM_Instantiation.sh \
  -i $(nova image-show "${BASE_IMAGE_NAME}" | fgrep -w id | perl -ne 'print "$1" if /\|\s+(\S+)\s+\|$/') \
  -p "${VM_NAME_PREFIX}-" \
  -u "${VM_CONFIG_SCRIPT}" \
  -f 1 \
  -n 40 \
  -x '%03.f' \
  -s 4 \
  -k 'pt-1589' \
  -c "${CELL}"

#parallel-ssh --hosts=<(cut -f 2 hostname2ip.txt) --user=${REMOTE_USERNAME} --askpass -O UserKnownHostsFile=/dev/null -O StrictHostKeyChecking=no --timeout=0 'fgrep 'System restart required' /etc/motd'

# Once the VM's have all become active and have IP addresses, output them to file 
#nova list --name '^'${VM_NAME_PREFIX}'-[0-9]+$'
nova list --name '^'${VM_NAME_PREFIX}'-[0-9]+$' --status ACTIVE | perl -ne 'print "$1\t$2\n" if /('${VM_NAME_PREFIX}'-\d+).+?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/' > hostname2ip.txt

#####
# Generate the NX Client session files and change special characters, not allowed in NX sessions names, into hyphens
#####
xargs -L 1 -a <(tr '=,_' '-' < hostname2ip.txt) ../openstack_scripts/generate_nxclient_session_file.sh template.nxs ${REMOTE_USERNAME} `../openstack_scripts/nomachine_nx_password_scrambler.pl ${REMOTE_PASSWORD}`
tar zcf nx_session_files.tar.gz ./$(echo ${VM_NAME_PREFIX}-*.nxs | tr '=,_' '-') \
&& zip nx_session_files.zip ./$(echo ${VM_NAME_PREFIX}-*.nxs | tr '=,_' '-') \
&& rm ./$(echo ${VM_NAME_PREFIX}-*.nxs | tr '=,_' '-')
