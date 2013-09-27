#!/bin/bash

usage="USAGE: $(basename $0) [-h] -d -i <image id> -p <prefix> -u <script> -n <number of VMs> -f <int> -s <int> -x <string> -c <cell> -k <ssh key>

where:
-h Show this help text
-d dry run
-i Image ID
-p VM name prefix
-u Post-instantiation script. Can be a local path or HTTP(S)
-n Number of VMs to instantiate
-x Suffix format string [Default: %02.f]
-f First integer for numbering VMs [Default: 1]
-s Instance size/flavour
-c Cell on which to run the VMs [Default: Any]
-k SSH Key name"

# default command line argument values
#####
DRYRUN=0
IMAGE_ID=
VM_NAME_PREFIX=
USER_DATA_FILE=
N_VMs=
SSH_KEY_NAME=
FIRST=1
FLAVOUR=1
FORMAT='%02.f'
CELL=''

# parse any command line options to change default values
while getopts ":hdi:p:u:n:x:k:f:s:c:" opt; do
case $opt in
    h) echo "$usage"
       exit
       ;;
    d) DRYRUN=1
       ;;
    i) IMAGE_ID=$OPTARG
       ;;
    p) VM_NAME_PREFIX=$OPTARG
       ;;
    u) USER_DATA_FILE=$OPTARG
       ;;
    n) N_VMs=$OPTARG
       ;;
    f) FIRST=$OPTARG
       ;;
    s) FLAVOUR=$OPTARG
       ;;
    x) FORMAT=$OPTARG
       ;;
    c) CELL=$OPTARG
       ;;
    k) SSH_KEY_NAME=$OPTARG
       ;;
    ?) printf "Illegal option: '-%s'\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      echo "$usage" >&2
      exit 1
      ;;
  esac
done

if [[ -z $IMAGE_ID ]] || [[ -z $VM_NAME_PREFIX ]] || [[ -z $N_VMs ]] || [[ -z $FIRST ]] || [[ -z $SSH_KEY_NAME ]] || [[ -z $FLAVOUR ]] || [[ -z $FORMAT ]]; then
  echo "$usage" >&2
  exit 1
fi

case ${USER_DATA_FILE%%://*} in
    http) wget --quiet --no-clobber $USER_DATA_FILE -O /tmp/${USER_DATA_FILE##*/}
       USER_DATA_FILE="/tmp/${USER_DATA_FILE##*/}"
       ;;
    https) wget --quiet --no-clobber $USER_DATA_FILE -O /tmp/${USER_DATA_FILE##*/}
       USER_DATA_FILE="/tmp/${USER_DATA_FILE##*/}"
       ;;
    *)
       USER_DATA_FILE=${USER_DATA_FILE}
       ;;
esac

# Start the boot process
#####
echo "Booting VMs ... "
b=0
LAST=$((FIRST+N_VMs-1))
for i in `seq --format="${FORMAT}" $FIRST $LAST`; do
  INSTANCE_NAME="$VM_NAME_PREFIX$i"
  echo -n "  VM: $INSTANCE_NAME ... "
  # Only instantiate a VM if the given name doesn't already exist
  if [[ ! $(nova list --name "^${INSTANCE_NAME}$") ]]; then
    echo "Booting"
    (( b++ ))
    if [[ $DRYRUN == 0 ]]; then
        nova boot --hint cell=$CELL --flavor=$FLAVOUR --image=$IMAGE_ID $INSTANCE_NAME --security-groups="SSH" --key-name=$SSH_KEY_NAME --user-data=$USER_DATA_FILE --meta description="Workshop_VM$i" --meta creator='Nathan S. Watson-Haigh'
    fi
  else
    echo "Already exists"
  fi
  if [[ $DRYRUN == 0 ]]; then
	  if (( $b > 0 )); then
	    if (( $b % 5 == 0 )); then
	      echo "  5 VMs booted, waiting for them to become active before booting more"
	      while [[ $(nova list --name "^${VM_NAME_PREFIX}\d+" --status BUILD) ]]; do
	        # sleep for 30s for every 5 VM's build requests and for
	        # which 1 or more still have a BUILD status
	        echo "    waiting for 30s"
	        sleep 30s
	      done
	    fi
	  fi
  fi
done

echo "nova list --name '^${VM_NAME_PREFIX}[0-9]+$' --status ACTIVE | perl -ne 'print \"\$1\t\$2\n\" if /(${VM_NAME_PREFIX}\d+).+?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/' > hostname2ip.txt"
echo ""
# Use parallel ssh to submit the same command to multiple VMs
echo "parallel-ssh --hosts=<(cut -f 2 hostname2ip.txt) --user=ubuntu --askpass -O UserKnownHostsFile=/dev/null -O StrictHostKeyChecking=no --timeout=0 --inline ls -l | fgrep cloud_init.finished | wc -l"

#echo "parallel-ssh --hosts=VM_ips.txt --user=ngstrainee --askpass -O UserKnownHostsFile=/dev/null -O StrictHostKeyChecking=no --timeout=0 --outdir=${VM_NAME_PREFIX}stdout --errdir=${VM_NAME_PREFIX}stderr ls -l"

