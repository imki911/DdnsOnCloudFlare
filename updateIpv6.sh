#!/bin/sh
#title           :updateIpv6.sh
#description     :
#author          :gf@gfshen.cn
#date            :2022-05-03
#==============================================================================
if [ -n "$BASH_SOURCE" ]; then
  workDir=$(
    cd $(dirname "$BASH_SOURCE")
    pwd
  )
else
  workDir=$(
    cd $(dirname $0)
    pwd
  )
fi
. "$workDir"/base.sh

checkConfValid
if [ $? -eq 1 ]; then
  echo "Missing param, please check config.conf "
  exit
fi

externalIpv6Add=$(getIpv6Address)
echo "Get external ipv6 address: $externalIpv6Add"

currentStat=$(listRecord "$zoneId" "$recordName" "$apiKey" "AAAA")
if [ $? -eq 1 ]; then
  echo "listRecord failed, Exit"
  exit 1
fi
resourceId=$(echo "$currentStat" | sed -n '1p')
currentValue=$(echo "$currentStat" | sed -n '2p')
printf 'Get currentStat:
resourceId=%s
currentValue=%s\n' "$resourceId" "$currentValue"

if [ -z "$resourceId" ]; then
  echo "record not exist, will create first"
  #  createRecord "$zoneId" "$recordName" "$apiKey" "AAAA" "$externalIpv6Add"
  createdRecordResourceId=$(createRecord "$zoneId" "$recordName" "$apiKey" "AAAA" "$externalIpv6Add")
  if [ $? -eq 0 ]; then
    resourceId=$createdRecordResourceId
  else
    echo "Create record failed. Exit"
    exit 1
  fi

fi

if [ "$currentValue" = "$externalIpv6Add" ]; then
  echo "DNS value already same as external address, will not update, exit."
  exit 0
fi

updateRecord "$zoneId" "$recordName" "$apiKey" "$resourceId" "AAAA" "$externalIpv6Add"
if [ $? -eq 0 ]; then
  echo "update success"
else
  echo "update failed"
fi
