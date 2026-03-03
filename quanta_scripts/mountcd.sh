#!/bin/bash

#### This script has to mount the iso in the server's virtualmedia and return 0 if operation succeeded, 1 otherwise
#### Note: Iso image to mount will be received as the first argument ($1)
#### You will get the following vars as environment vars
#### BMC_ENDPOINT - Has the BMC IP
#### BMC_USERNAME - Has the username configured in the BMH/InstallConfig and that is used to access BMC_ENDPOINT
#### BMC_PASSWORD - Has the password configured in the BMH/InstallConfig and that is used to access BMC_ENDPOINT
#### Note: Quanta virtual media does not accept '-' in ISO filenames. This script rewrites '-' to '_'.

ISO=${1}
ISO_URL=$(echo $ISO | cut -d '/' -f-3)
ISO_PATH_RAW='/'$(echo $ISO | cut -d '/' -f4-)
ISO_PATH=${ISO_PATH_RAW//-/_}

# UnMount image just in case
curl -X POST -H 'Content-Type: application/json' -H "Accept: application/json" -s -k -u ''"${BMC_USERNAME}"'':''"${BMC_PASSWORD}"'' -d "{}" https://${BMC_ENDPOINT}/redfish/v1/Managers/BMC_0/VirtualMedia/CD1/Actions/VirtualMedia.EjectMedia 


# Configure image
sleep 2
echo
# '{"Image": "'http://192.168.13.11/agent.aarch64.iso'","TransferProtocolType": "HTTPS", "UserName": "none", "Password": "none", "TransferMethod": "Stream", "Inserted": true, "WriteProtected": true}'
curl -H "Content-Type: application/json" -X POST -sk -u ''"${BMC_USERNAME}"'':''"${BMC_PASSWORD}"'' --data '{"Image": "'${ISO}'","TransferProtocolType": "HTTPS", "UserName": "none", "Password": "none", "TransferMethod": "Stream", "Inserted": true, "WriteProtected": true}' https://${BMC_ENDPOINT}/redfish/v1/Managers/BMC_0/VirtualMedia/CD1/Actions/VirtualMedia.InsertMedia
if [ $? -eq 0 ]; then
  # Mount image
  sleep 3
  echo
  #curl -X POST -s -k -u ''"${BMC_USERNAME}"'':''"${BMC_PASSWORD}"'' https://${BMC_ENDPOINT}/redfish/v1/Managers/BMC_0/VirtualMedia/CD1/Actions/VirtualMedia.InsertMedia -d ""
  if [ $? -eq 0 ]; then
    # Check image is mounted
    IMAGE=$(curl -s -k -u ''"${BMC_USERNAME}"'':''"${BMC_PASSWORD}"'' https://${BMC_ENDPOINT}/redfish/v1/Managers/BMC_0/VirtualMedia/CD1)
    echo
    echo $IMAGE
    if `echo $IMAGE | grep -E -q ${ISO_PATH}`; then
      exit 0
    else
      exit 1
    fi
  else
    exit 1
  fi
else
  exit 1
fi
