FROM ghcr.io/wyx2685/v2bx:latest

# 安装 jq 用于 JSON 处理
RUN apk add --no-cache jq

# 复制启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

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
    LISTEN_IP="0.0.0.0"

ENTRYPOINT ["/entrypoint.sh"]