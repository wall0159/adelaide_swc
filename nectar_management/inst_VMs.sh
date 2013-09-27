#!/bin/bash

# glance image-create --name="ubuntu_saucy" --is-public=false --container=bare --disk-format=qcow2 <~/saucy-server-cloudimg-amd64-disk1.img

for i in 1 2
do
nova boot \
--image 3a455ed1-c66e-4e6a-a671-1946201acbb9 \
--key-name angusw_218 \
--security-groups ssh \
--availability-zone monash \
--flavor m1.small \
--user-data ~/adelaide_swc/nectar_management/NXServer_install.sh \
VM_num_${i}
done
