#!/bin/sh
set -e

# 检查必需的环境变量
if [ -z "$API_HOST" ] || [ -z "$API_KEY" ]; then
    echo "Error: API_HOST and API_KEY are required"
    exit 1
fi

# 生成 config.json
cat > /etc/V2bX/config.json <<EOF
{
  "Log": {
    "Level": "${LOG_LEVEL:-error}",
    "Output": ""
  },
  "Cores": [
    {
      "Type": "${CORE_TYPE}",
      "Log": {
        "Level": "${LOG_LEVEL:-error}",
        "Timestamp": true
      },
      "NTP": {
        "Enable": false,
        "Server": "time.apple.com",
        "ServerPort": 0
      }$([ -n "$ORIGINAL_PATH" ] && echo ",\n      \"OriginalPath\": \"$ORIGINAL_PATH\"" || echo "")
    }
  ],
  "Nodes": [
    {
      "Core": "${CORE_TYPE}",
      "ApiHost": "${API_HOST}",
      "ApiKey": "${API_KEY}",
      "NodeID": ${NODE_ID},
      "NodeType": "${NODE_TYPE}",
      "Timeout": ${TIMEOUT:-30},
      "ListenIP": "${LISTEN_IP}",
      "SendIP": "${SEND_IP:-0.0.0.0}",
      "DeviceOnlineMinTraffic": ${DEVICE_ONLINE_MIN_TRAFFIC:-100},
      "CertConfig": {
        "CertMode": "${CERT_MODE}",
        "CertDomain": "${CERT_DOMAIN}",
        "CertFile": "${CERT_FILE}",
        "KeyFile": "${KEY_FILE}",
        "Email": "${CERT_EMAIL}",
        "Provider": "${CERT_PROVIDER}"$([ -n "$DNS_ENV" ] && echo ",\n        \"DNSEnv\": $DNS_ENV" || echo "")
      }
    }
  ]
}
EOF

echo "Config generated successfully"
cat /etc/V2bX/config.json

# 启动 V2bX
exec V2bX server --config /etc/V2bX/config.json