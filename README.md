# V2bX Docker

支持环境变量配置的 V2bX Docker 镜像，适用于云端部署。

## 镜像地址

```
ghcr.io/visense/v2bxdocker:latest
```

## 工作原理

基于官方 V2bX 镜像，通过 entrypoint 脚本从环境变量生成 `config.json`，然后启动 V2bX。

## 环境变量

### 必需

- `API_HOST` - 面板地址
- `API_KEY` - 面板 API Key

### 可选

- `NODE_ID` - 节点 ID（默认：1）
- `NODE_TYPE` - 节点类型（默认：hysteria2）
- `CORE_TYPE` - 核心类型（默认：sing）
- `CERT_MODE` - 证书模式（默认：none）
- `CERT_DOMAIN` - 证书域名
- `CERT_FILE` - 证书文件路径
- `KEY_FILE` - 密钥文件路径
- `CERT_EMAIL` - 证书邮箱
- `CERT_PROVIDER` - 证书提供商（cloudflare/alidns 等）
- `DNS_ENV` - DNS 提供商环境变量（JSON 格式）
- `LISTEN_IP` - 监听 IP（默认：0.0.0.0）
- `SEND_IP` - 发送 IP（默认：0.0.0.0）
- `TIMEOUT` - 超时时间（默认：30）
- `DEVICE_ONLINE_MIN_TRAFFIC` - 设备在线最小流量（默认：100）
- `LOG_LEVEL` - 日志级别（默认：error）
- `ORIGINAL_PATH` - 审计规则文件路径

## 使用示例

### Docker Run

```bash
docker run -d \
  --name v2bx \
  --network host \
  --restart always \
  -e API_HOST="https://your-panel.com" \
  -e API_KEY="your_api_key" \
  -e NODE_ID="2" \
  -e NODE_TYPE="hysteria2" \
  ghcr.io/visense/v2bxdocker:latest
```

### Docker Compose

```yaml
version: '3'
services:
  v2bx:
    image: ghcr.io/visense/v2bxdocker:latest
    container_name: v2bx
    network_mode: host
    restart: always
    environment:
      - API_HOST=https://your-panel.com
      - API_KEY=your_api_key
      - NODE_ID=2
      - NODE_TYPE=hysteria2
      - CORE_TYPE=sing
```

## 高级配置

### 使用审计规则

```yaml
services:
  v2bx:
    image: ghcr.io/visense/v2bxdocker:latest
    network_mode: host
    restart: always
    environment:
      - API_HOST=https://your-panel.com
      - API_KEY=your_key
      - ORIGINAL_PATH=/etc/V2bX/sing_origin.json
    volumes:
      - ./sing_origin.json:/etc/V2bX/sing_origin.json:ro
```

### DNS 证书自动申请

```bash
docker run -d \
  --name v2bx \
  --network host \
  --restart always \
  -e API_HOST="https://your-panel.com" \
  -e API_KEY="your_key" \
  -e CERT_MODE="dns" \
  -e CERT_DOMAIN="node.example.com" \
  -e CERT_PROVIDER="cloudflare" \
  -e CERT_EMAIL="admin@example.com" \
  -e DNS_ENV='{"CLOUDFLARE_EMAIL":"admin@example.com","CLOUDFLARE_API_KEY":"your_cf_key"}' \
  ghcr.io/visense/v2bxdocker:latest
```

### 使用自有证书

```yaml
services:
  v2bx:
    image: ghcr.io/visense/v2bxdocker:latest
    network_mode: host
    restart: always
    environment:
      - API_HOST=https://your-panel.com
      - API_KEY=your_key
      - CERT_MODE=file
      - CERT_FILE=/etc/V2bX/cert/cert.pem
      - KEY_FILE=/etc/V2bX/cert/key.pem
    volumes:
      - ./cert:/etc/V2bX/cert:ro
```

## 云平台部署

### AWS ECS

在任务定义中设置环境变量即可。

### Google Cloud Run

```bash
gcloud run deploy v2bx \
  --image ghcr.io/visense/v2bxdocker:latest \
  --set-env-vars API_HOST=https://your-panel.com,API_KEY=your_key,NODE_ID=2
```

### Kubernetes

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: v2bx-secret
stringData:
  api-key: "your_api_key"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: v2bx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: v2bx
  template:
    metadata:
      labels:
        app: v2bx
    spec:
      hostNetwork: true
      containers:
      - name: v2bx
        image: ghcr.io/visense/v2bxdocker:latest
        env:
        - name: API_HOST
          value: "https://your-panel.com"
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: v2bx-secret
              key: api-key
        - name: NODE_ID
          value: "2"
        - name: NODE_TYPE
          value: "hysteria2"
```

## 构建状态

查看构建状态：[Actions](https://github.com/visense/v2bxdocker/actions)