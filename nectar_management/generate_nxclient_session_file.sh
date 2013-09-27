#!/bin/bash
# Usage: generate_nxclient_session_file.sh <template.nxs> <hostname> <ipaddress>
# Notes: Output filename is used for the name of the session.
#        The resulting session file can be executed on the command line in Windows using something like:
#          "C:\Program Files (x86)\NX Client for Windows\nxclient.exe" --session "session.nxs"
#
# This could be run using xargs and supplying a list of IP addresses
#   xargs -L 1 -a ./VM_hostnames.txt ../generate_nxclient_session_file.sh ../template.nxs && \
#     tar zcf nx_sessions.tar.gz ./*.nxs
#      where VM_hostnames.txt contains the hostname to IP address mappings in two columns
#echo -e "$1\t$2\t$3\t$4\t$5"
NXS_TEMPLATE_FILE="$1"
USER_NAME="$2"
USER_PASSWORD=$(echo $3 | sed -e 's/[\@&]/\\&/g' )

OUTPUT_SESSION_FILE="$4.nxs"
HOST_IP="$5"

sed -e "s@<option key=\"Server host\" value=\"\" />@<option key=\"Server host\" value=\"${HOST_IP}\" />@; s@<option key=\"User\" value=\"\"@<option key=\"User\" value=\"${USER_NAME}\"@; s@<option key=\"Auth\" value=\"EMPTY_PASSWORD\"@<option key=\"Auth\" value=\""${USER_PASSWORD}"\"@" < ${NXS_TEMPLATE_FILE} > ${OUTPUT_SESSION_FILE}
