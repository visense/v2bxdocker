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
    "Level": "error",
    "Output": ""
  },
  "Cores": [
    {
      "Type": "${CORE_TYPE}",
      "Log": {
        "Level": "error",
        "Output": ""
      },
      "NTP": {
        "Enable": false,
        "Server": "time.apple.com",
        "ServerPort": 0
      }
    }
  ],
  "Nodes": [
    {
      "Core": "${CORE_TYPE}",
      "ApiConfig": {
        "ApiHost": "${API_HOST}",
        "ApiKey": "${API_KEY}",
        "NodeID": ${NODE_ID},
        "NodeType": "${NODE_TYPE}",
        "Timeout": 30,
        "RuleListPath": ""
      },
      "ControllerConfig": {
        "ListenIP": "${LISTEN_IP}",
        "UpdatePeriodic": 60,
        "EnableDNS": false,
        "CertConfig": {
          "CertMode": "${CERT_MODE}",
          "CertDomain": "${CERT_DOMAIN}",
          "CertFile": "${CERT_FILE}",
          "KeyFile": "${KEY_FILE}",
          "Email": "",
          "Provider": ""
        }
      }
    }
  ]
}
EOF

echo "Config generated successfully"
cat /etc/V2bX/config.json

# 启动 V2bX
exec V2bX server --config /etc/V2bX/config.json