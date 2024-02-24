#!/bin/bash
if [ -n "$DEBUG" ];then
    set -v;set -x
fi
bearer_auth="flmH9Ies7w7Icj_RMmLlDWxDFZyOn679Bv59NntO"
domain="sakuya-arch.just-a-pony.net"
zone_identifier="af577fa47883f7f5c9a950086904764e"
get_ipv6_address(){
    ip --json -6 address show dynamic|jq -r '.[].addr_info[]|select(.preferred_life_time>0).local//empty'
}
get_records(){
    curl -s https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records -H "Content-Type: application/json" -H "Authorization: Bearer $bearer_auth"
}
get_dns_identifier(){
    get_records|jq -r ".result|.[]|select(.name==\"$domain\")|.id"
}
data_body="{\"name\":\"$domain\",\"type\":\"AAAA\",\"content\":\"$(get_ipv6_address)\",\"comment\":\"$(date -R)\"}"
perform(){
    curl -sX PATCH https://api.cloudflare.com/client/v4/zones/"$1"/dns_records/"$(get_dns_identifier)" -H "Content-Type: application/json" -H "Authorization: Bearer $2" --data "$3"
}
result=$(perform $zone_identifier $bearer_auth $data_body)
echo "$result"|jq
