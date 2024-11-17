#!/bin/bash
    sudo apt-get update
    sudo apt-get install -y cifs-utils
    sudo mkdir -p ${mount_point}
    echo "//${storage_account_name}.file.core.windows.net/${file_share_name} ${mount_point} cifs vers=3.0,username=${storage_account_name},password=${storage_account_key},dir_mode=0777,file_mode=0777,serverino" >> /etc/fstab
    mount -a