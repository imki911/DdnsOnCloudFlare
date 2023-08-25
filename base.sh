#!/bin/sh
#title           :base.sh
#description     :
#author          :gf@gfshen.cn
#date            :2022-05-03
#==============================================================================
zoneId=''
recordName=''
apiKey=''

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
echo "workDir: $workDir"
cd $workDir

. "$workDir/config.conf"

checkConfValid() {
  local isValid=true
  if [ -z "$zoneId" ]; then
    echo "zoneId invalid"
    return 1
  fi
  if [ -z "$recordName" ]; then
    echo "recordName invalid"
    return 1
  fi
  if [ -z "$apiKey" ]; then
    echo "apiKey invalid"
    return 1
  fi
}

getIpv4Address() {
  # try and choose one that works on your machine
  # curl -k -s "http://members.3322.org/dyndns/getip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
  curl -s https://api.ipify.org
}

getIpv6Address() {
  # try and choose one that works on your machine
  curl -s -6 https://ifconfig.co/ip
  # curl https://api64.ipify.org
}

listRecord() {
  local zoneId=$1
  local recordName=$2
  local apiKey=$3
  local type=$4
  local result=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records?name=$recordName" \
    -H "Content-Type:application/json" \
    -H "Authorization: Bearer $apiKey")

  local resourceId=$(echo "$result" | jq -r ".result[] | select(.type == \"$type\") | .id")
  local currentValue=$(echo "$result" | jq -r ".result[] | select(.type == \"$type\") | .content")
  local successStat=$(echo "$result" | jq ".success")
  if [ "$successStat" != "true" ]; then
    return 1
  fi

  printf '%s\n%s' "$resourceId" "$currentValue"
}

updateRecord() {
  local zoneId=$1
  local recordName=$2
  local apiKey=$3
  local resourceId=$4
  local type=$5
  local value=$6

  local result=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/$resourceId" \
    -H "Authorization: Bearer $apiKey" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"$type\",\"name\":\"$recordName\",\"content\":\"$value\",\"ttl\":600,\"proxied\":false}")

  local successStat=$(echo "$result" | grep -Po '(?<="success":)[^,]+')
  [ "$successStat" = "true" ]
  return $?
}

createRecord() {
  local zoneId=$1
  local recordName=$2
  local apiKey=$3
  local type=$4
  local value=$5

  local result=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records" \
    -H "Authorization: Bearer $apiKey" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"$type\",\"name\":\"$recordName\",\"content\":\"$value\",\"ttl\":600,\"proxied\":false}")
  local successStat=$(echo "$result" | grep -Po '(?<="success":)[^,]+')
  if [ "$successStat" != "true" ]; then
    return 1
  fi
  local recordId=$(echo "$result" | grep -Po '(?<="id":")[^"]+')
  echo "$recordId"
}
