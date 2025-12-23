#!/usr/bin/env bash
set -euo pipefail

SECRETS="$HOME/.env_list"
DOMAINS="$HOME/dotfiles/conf/domains.conf"

for f in "$SECRETS" "$DOMAINS"; do
  [[ -f "$f" ]] || { echo "missing file: $f" >&2; exit 1; }
done

# shellcheck source=/dev/null
source "$SECRETS"
# shellcheck source=/dev/null
source "$DOMAINS"

# validation
: "${CF_API_TOKEN:?}"
: "${CF_ZONE_ID:?}"
: "${CF_RECORD_TYPE:?}"
: "${CF_RECORD_NAMES:?}"

# get current IP
if [[ "$CF_RECORD_TYPE" == "AAAA" ]]; then
  CURRENT_IP=$(curl -fsS https://ipv6.icanhazip.com)
else
  CURRENT_IP=$(curl -fsS https://ipv4.icanhazip.com)
fi
CURRENT_IP=$(echo "$CURRENT_IP" | tr -d '[:space:]')

for NAME in "${CF_RECORD_NAMES[@]}"; do
  RECORD_ID=$(curl -fsS \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records?type=$CF_RECORD_TYPE&name=$NAME" \
    | jq -r '.result[0].id')

  [[ -n "$RECORD_ID" && "$RECORD_ID" != "null" ]] || {
    echo "record not found: $NAME" >&2
    continue
  }

  curl -fsS -X PUT \
    "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$RECORD_ID" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "{
      \"type\": \"$CF_RECORD_TYPE\",
      \"name\": \"$NAME\",
      \"content\": \"$CURRENT_IP\",
      \"ttl\": 1,
      \"proxied\": $CF_PROXIED
    }" >/dev/null

  echo "updated: $NAME -> $CURRENT_IP"
done
