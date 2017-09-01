#!/bin/bash

REMOTE_PATH=${REMOTE_PATH:-'~'}

#
# Check required environment variables
#

REQUIRED=( HOST USER SYNC_1_SRC SYNC_1_DEST )

for i in "${REQUIRED[@]}"
do
  if [ -z "${!i}" ]; then
      echo -e "Environment variable ${i} is required, exiting..."
      exit 1
  fi
done

#
# Connect to remote filesystem
#

echo -e "sshfs ${USER}@${HOST}:${REMOTE_PATH} /mnt/remote/"
if [ -n "${PASS}" ]; then
    echo ${PASS} | sshfs ${USER}@${HOST}:${REMOTE_PATH} /mnt/remote/ -o password_stdin,StrictHostKeyChecking=no
else
    if [ -z "${IDENTITY_FILE}" ]; then
      echo -e "Environment variable IDENTITY_FILE is required for public key authentication, exiting..."
      exit 1
    fi
    sshfs ${USER}@${HOST}:${REMOTE_PATH} /mnt/remote/ -o IdentityFile=${IDENTITY_FILE},StrictHostKeyChecking=no
fi

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

    mkdir -p /dest/$(get_dest)

    rsync -avP --delete \
        /mnt/remote/$(get_src) \
        /dest/$(get_dest)

    # Setting ownership
    if [ -n "${DEST_USER}" ]; then
        # If both environment variables are set
        if [ -n "${DEST_GROUP}" ]; then
            echo -e "Setting user and group on all files and directories in $(get_dest) to ${DEST_USER}:${DEST_GROUP}"
            chown -R ${DEST_USER}:${DEST_GROUP} /dest/$(get_dest)
        fi

        # If only the user is set
        if [ -z "${DEST_GROUP}" ]; then
            echo -e "Setting user on all files and directories in $(get_dest) to ${DEST_USER}"
            chown -R ${DEST_USER} /dest/$(get_dest)
        fi
    fi

    # Setting file permissions
    if [ -n "${DEST_FILE_PERMS}" ]; then
        echo -e "Setting permissions on all files in $(get_dest) to ${DEST_FILE_PERMS}"
        find /dest/$(get_dest) -type f -exec chmod ${DEST_FILE_PERMS} {} \;
    fi

    # Setting directory permissions
    if [ -n "${DEST_DIR_PERMS}" ]; then
        echo -e "Setting permissions on all directories in $(get_dest) to ${DEST_DIR_PERMS}"
        find /dest/$(get_dest) -type d -exec chmod ${DEST_DIR_PERMS} {} \;
    fi

    (( c++ ))
done

echo -e "Sync completed."
