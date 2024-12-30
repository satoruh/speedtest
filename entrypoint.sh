#!/bin/bash

set -euo pipefail

: "${SERVER_ID=48463}"
: "${METRIC_PREFIX:=speedtest}"
: "${URL:=http://vminsert-vmcluster.monitoring:8480/insert/0/prometheus/api/v1/import/prometheus/}"

exec_speedtest() {
  declare -ar flags=(
    --accept-license
    -f json
    -s "${SERVER_ID}"
  )
  
  speedtest "${flags[@]}" 2>/dev/null
}

prometheus_exposition_format() {
  declare -r result="$(</dev/stdin)"

  declare -ar queries=(
    '.packetLoss'
    '.ping.jitter'
    '.ping.latency'
    '.ping.high'
    '.ping.low'
    '.download.bandwidth'
    '.upload.bandwidth'
  )

  declare -r timestamp_str="$(<<<"${result}" jq -r '.timestamp')"
  declare -r timestamp="$(date -d "${timestamp_str}" +%s)"
  declare -r timestamp_ms="${timestamp}000"
  declare -r label=$(<<<"${result}" jq -r '@sh "{server_id=\"\(.server.id)\",server_ip=\"\(.server.ip)\",server_name=\"\(.server.name)\",server_location=\"\(.server.location)\",server_country=\"\(.server.country)\"}"')
  
  for q in "${queries[@]}"; do
    echo "${METRIC_PREFIX}${q//./_}${label} $(<<<${result} jq -r "${q}") ${timestamp_ms}"
  done
}

exec_speedtest | 
  prometheus_exposition_format |
  curl -s -X POST "${URL}" --data-binary @-
