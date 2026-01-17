FROM alpine:latest

# 安装 jq 用于 JSON 处理
RUN apk add --no-cache jq

# 复制配置生成脚本
COPY generate-config.sh /generate-config.sh
RUN chmod +x /generate-config.sh

# 环境变量默认值
ENV API_HOST="" \
    API_KEY="" \
    NODE_ID="1" \
    NODE_TYPE="hysteria2" \
    CORE_TYPE="sing" \
    CERT_MODE="none" \
    CERT_DOMAIN="" \
    CERT_FILE="" \
    KEY_FILE="" \
    CERT_EMAIL="" \
    CERT_PROVIDER="" \
    LISTEN_IP="0.0.0.0" \
    SEND_IP="0.0.0.0" \
    TIMEOUT="30" \
    DEVICE_ONLINE_MIN_TRAFFIC="100" \
    LOG_LEVEL="error" \
    ORIGINAL_PATH="" \
    DNS_ENV=""

ENTRYPOINT ["/generate-config.sh"]