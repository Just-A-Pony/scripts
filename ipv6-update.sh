https_proxy='127.0.0.1:10809'
bearer_auth="flmH9Ies7w7Icj_RMmLlDWxDFZyOn679Bv59NntO"
domain="sakuya-arch.just-a-pony.net"
zone_identifier="af577fa47883f7f5c9a950086904764e"
ipv6_address=$(ip --json -6 address show dynamic|jq -r '.[].addr_info[].local//empty')
records=$(curl -s https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records -H "Content-Type: application/json" -H "Authorization: Bearer $bearer_auth")
dns_identifier=$(echo $records|jq -r ".result|.[]|select(.name==\"$domain\")|.id")
    data_body="{\"name\":\"$domain\",\"type\":\"AAAA\",\"content\":\"$ipv6_address\",\"comment\":\"$(date -R)\"}"
curl -sX PATCH \
	https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$dns_identifier \
	-H "Content-Type: application/json" -H "Authorization: Bearer $bearer_auth" --data "$data_body"|jq
