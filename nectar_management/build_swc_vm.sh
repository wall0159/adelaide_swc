#!/bin/bash
# This script builds a base Software Carpentry image and snapshots it for future use.
#####

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

# Create a directory under which we'll store files associated with the launch of these VMs
DIR=`mktemp -d --tmpdir=./` && cd ${DIR}

##########
# Use a "here document" to put the following script into a file so it can passed to each instantiated VM
##########
VM_CONFIG_SCRIPT=`mktemp --tmpdir=./`
cat > ${VM_CONFIG_SCRIPT} <<SCRIPT
#!/bin/bash
apt-get update
# Install required packages
#####
#   required for building the image:
apt-get install -y git
#   additional packages for this base image
#apt-get install -y ...

# setup an NX server for remote desktop-like connection
git clone https://gist.github.com/4007406.git nx_server_setup
source nx_server_setup/NXServer.sh

reboot
SCRIPT
##########

# Build the image using the above "here document" script
../openstack_scripts/VM_Instantiation.sh \
  -i $(nova image-show "${BASE_IMAGE_NAME}" | fgrep -w id | perl -ne 'print "$1" if /\|\s+(\S+)\s+\|$/') \
  -p "${VM_NAME_PREFIX}-" \
  -u "${VM_CONFIG_SCRIPT}" \
  -f 1 \
  -n 1 \
  -x '%03.f' \
  -s 2 \
  -k 'pt-1589' \
  -c "${CELL}"

# Once the VM is active and has an IP address, output it to file 
#nova list --name '^'${VM_NAME_PREFIX}'-[0-9]+$'
nova list --name '^'${VM_NAME_PREFIX}'-[0-9]+$' --status ACTIVE | perl -ne 'print "$1\t$2\n" if /('${VM_NAME_PREFIX}'-\d+).+?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/' > hostname2ip.txt

# Create an image of the VM
nova image-create "${VM_NAME_PREFIX}-001" "${BASE_IMAGE_NAME}"
# Make the image public
glance image-update --is-public True $(glance image-list --name "${BASE_IMAGE_NAME}" | perl -ne 'print $1 if /^\|\s+(\S+)/')
