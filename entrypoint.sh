#!/bin/bash

#
# Check required environment variables
#

REQUIRED=( HOST USER PASS SYNC_1_SRC SYNC_1_DEST )

for i in "${REQUIRED[@]}"
do
  if [ -z "${!i}" ]; then
      echo -e "Environment variable ${i} is required, exiting..."
      exit 1
  fi
done

#
# Connect to remove filesystem
#

echo -e "sshfs ${USER}@${HOST}: /mnt/remote/"
echo ${PASS} | sshfs ${USER}@${HOST}: /mnt/remote/ -o password_stdin -o StrictHostKeyChecking=no

#
# Cycle through syncing SYNC_#_SRC/SYNC_#_DEST pairs
#

get_src() { local tmp; tmp="SYNC_${c}_SRC"; printf %s "${!tmp}"; }
get_dest() { local tmp; tmp="SYNC_${c}_DEST"; printf %s "${!tmp}"; }

c=1
while [ -n "$(get_src)" ]
do
    if [ -z "$(get_dest)" ]; then
        echo -e "Environment variable SYNC_${c}_DEST is required when SYNC_${c}_SRC is provided, exiting..."
        exit 1
    fi

    echo "Syncing $(get_src) to $(get_dest)"

    rsync -avP --delete \
        /mnt/remote/$(get_src) \
        /dest/$(get_dest)

    (( c++ ))
done

echo -e "Sync completed."
