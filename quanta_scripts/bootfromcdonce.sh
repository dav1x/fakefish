#!/bin/bash

#### This script has to set the server's boot to once from cd and return 0 if operation succeeded, 1 otherwise
#### You will get the following vars as environment vars
#### BMC_ENDPOINT - Has the BMC IP
#### BMC_USERNAME - Has the username configured in the BMH/InstallConfig and that is used to access BMC_ENDPOINT
#### BMC_PASSWORD - Has the password configured in the BMH/InstallConfig and that is used to access BMC_ENDPOINT
#### Quanta/AMI BMC requires If-Match (ETag) on PATCH; GET the resource first to obtain it.

RESP=$(curl -s -k -u "${BMC_USERNAME}:${BMC_PASSWORD}" -D - -o /dev/null "https://${BMC_ENDPOINT}/redfish/v1/Systems/System_0")
ETAG=$(echo "$RESP" | grep -i '^ETag:' | tr -d '\r' | sed 's/^[Ee][Tt][Aa][Gg]: //')
if [ -z "$ETAG" ]; then
  echo "Failed to get ETag from Systems/System_0" >&2
  exit 1
fi

curl -H "Content-Type: application/json" -H "If-Match: ${ETAG}" -X PATCH -s -k -u "${BMC_USERNAME}:${BMC_PASSWORD}" "https://${BMC_ENDPOINT}/redfish/v1/Systems/System_0" --data '{ "Boot":{"BootSourceOverrideEnabled":"Once","BootSourceOverrideMode":"UEFI","BootSourceOverrideTarget": "Cd"}}'
if [ $? -eq 0 ]; then
  exit 0
else
  exit 1
fi
