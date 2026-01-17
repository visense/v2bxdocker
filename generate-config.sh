#!/bin/sh
set -e

# 检查必需的环境变量
if [ -z "$API_HOST" ] || [ -z "$API_KEY" ]; then
    echo "Error: API_HOST and API_KEY are required"
    exit 1
fi

# 创建配置目录
mkdir -p /config

# 生成 config.json
cat > /config/config.json <<EOF
{
  "Log": {
    "Level": "${LOG_LEVEL}",
    "Output": ""
  },
  "Cores": [
    {
      "Type": "${CORE_TYPE}",
      "Log": {
        "Level": "${LOG_LEVEL}",
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
      "Timeout": ${TIMEOUT},
      "ListenIP": "${LISTEN_IP}",
      "SendIP": "${SEND_IP}",
      "DeviceOnlineMinTraffic": ${DEVICE_ONLINE_MIN_TRAFFIC},
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

echo "Config generated at /config/config.json"
cat /config/config.json

echo ""
echo "Mount this config to V2bX container:"
echo "docker run -v /config:/etc/V2bX ghcr.io/wyx2685/v2bx:latest"