#!/bin/sh
set -e

# 检查必需的环境变量
if [ -z "$API_HOST" ] || [ -z "$API_KEY" ]; then
    echo "Error: API_HOST and API_KEY are required"
    exit 1
fi

# 设置默认证书路径（dns 和 self 模式需要）
if [ "$CERT_MODE" = "dns" ] || [ "$CERT_MODE" = "self" ]; then
    if [ -z "$CERT_FILE" ]; then
        CERT_FILE="/etc/V2bX/cert/${CERT_DOMAIN}.cer"
        KEY_FILE="/etc/V2bX/cert/${CERT_DOMAIN}.key"
    fi
fi

# 生成 Cores 配置
CORES_CONFIG='{"Type":"'${CORE_TYPE}'","Log":{"Level":"'${LOG_LEVEL}'","Timestamp":true},"NTP":{"Enable":false,"Server":"time.apple.com","ServerPort":0}}'

# 如果设置了 OriginalPath，添加到配置中
if [ -n "$ORIGINAL_PATH" ]; then
  CORES_CONFIG=$(echo "$CORES_CONFIG" | jq ". + {\"OriginalPath\": \"$ORIGINAL_PATH\"}")
fi

# 生成 CertConfig
CERT_CONFIG='{"CertMode":"'${CERT_MODE}'","CertDomain":"'${CERT_DOMAIN}'","CertFile":"'${CERT_FILE}'","KeyFile":"'${KEY_FILE}'","Email":"'${CERT_EMAIL}'","Provider":"'${CERT_PROVIDER}'"}'

# 如果设置了 DNS_ENV，添加到 CertConfig
if [ -n "$DNS_ENV" ]; then
  CERT_CONFIG=$(echo "$CERT_CONFIG" | jq ". + {\"DNSEnv\": $DNS_ENV}")
fi

# 生成完整的 config.json
cat > /etc/V2bX/config.json <<EOF
{
  "Log": {
    "Level": "${LOG_LEVEL}",
    "Output": ""
  },
  "Cores": [
    $CORES_CONFIG
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
      "CertConfig": $CERT_CONFIG
    }
  ]
}
EOF

echo "Config generated successfully:"
cat /etc/V2bX/config.json

# 启动 V2bX
exec V2bX server --config /etc/V2bX/config.json
