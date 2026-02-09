#!/bin/bash

#### This script has to poweroff the server and return 0 if operation succeeded, 1 otherwise
#### You will get the following vars as environment vars
#### BMC_ENDPOINT - Has the BMC IP
#### BMC_USERNAME - Has the username configured in the BMH/InstallConfig and that is used to access BMC_ENDPOINT
#### BMC_PASSWORD - Has the password configured in the BMH/InstallConfig and that is used to access BMC_ENDPOINT
### /redfish/v1/Systems/System_0/Actions/ComputerSystem.Reset 

RESPONSE=$(curl -X POST -s -k -u ''"${BMC_USERNAME}"'':''"${BMC_PASSWORD}"'' \
  https://${BMC_ENDPOINT}/redfish/v1/Systems/System_0/Actions/ComputerSystem.Reset \
  -H "Content-Type: application/json" \
  -d '{"ResetType":"ForceOff"}')

if echo "$RESPONSE" | grep -E -q "ActionParameterValueFormatError"; then
  RESPONSE=$(curl -X POST -s -k -u ''"${BMC_USERNAME}"'':''"${BMC_PASSWORD}"'' \
    https://${BMC_ENDPOINT}/redfish/v1/Systems/System_0/Actions/ComputerSystem.Reset \
    -H "Content-Type: application/json" \
    -d '{"ResetType":"Off"}')
fi

if [ $? -eq 0 ] && ! echo "$RESPONSE" | grep -E -q '"error"'; then
  exit 0
else
  exit 1
fi
