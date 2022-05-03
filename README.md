# DdnsOnCloudFlare
A shell script to automatic update cloudFlare dns record whit actual external ip address, leveraging the official CloudFlare api.

# Guide
## Pre-work
- Have a domain and use Cloudflare's nameserver.  
- Find your `ZoneId` from the [overview] page of you domain.  
- Create an `api token`. You can find it from [Here](https://dash.cloudflare.com/profile/api-tokens)
- Clone this project to local, fill in `config.conf`. In which, `zoneId` and `apiKey` refer to the contents you just got in the above steps. `recordName`is the dns record name you'd like to operate.

## Update Ipv4 record
Simply run:
```shell
sh ./updateIpv4.sh
```
This will first get your external ipv4 address, and synchronize to the dns record.  
If no such record exists, will create one.  
If the record is already set as the expected ip, will do nothing.
Or, the record will be updated.
## Update Ipv6 record
Similar to the previous, but just run:
```shell
sh ./updateIpv6.sh
```
The behavior is also the same.

# Note
- You can make it periodically executed using [crontab](https://linuxconfig.org/linux-crontab-reference-guide).  
- DO NOT abuse. According to the term of cloudflare, the api call rate is limited to 1200 requests every 5 minutes. 