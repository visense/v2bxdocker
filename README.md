# V2bX Docker

支持环境变量配置的 V2bX Docker 镜像，适用于云端部署。

## 镜像地址

```
ghcr.io/visense/v2bxdocker:latest
```

## 环境变量

### 必需

- `API_HOST` - 面板地址（如：https://box.gorelay.dpdns.org）
- `API_KEY` - 面板 API Key

### 可选

- `NODE_ID` - 节点 ID（默认：1）
- `NODE_TYPE` - 节点类型（默认：hysteria2）
- `CORE_TYPE` - 核心类型（默认：sing）
- `CERT_MODE` - 证书模式（默认：none）
- `CERT_DOMAIN` - 证书域名
- `CERT_FILE` - 证书文件路径
- `KEY_FILE` - 密钥文件路径
- `LISTEN_IP` - 监听 IP（默认：0.0.0.0）

## 使用示例

### Docker Run

```bash
docker run -d \
  --name v2bx \
  --network host \
  --restart always \
  -e API_HOST="https://box.gorelay.dpdns.org" \
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
      - API_HOST=https://box.gorelay.dpdns.org
      - API_KEY=your_api_key
      - NODE_ID=2
      - NODE_TYPE=hysteria2
      - CORE_TYPE=sing
```

## 云平台部署

### AWS ECS

在任务定义中设置环境变量即可。

### Google Cloud Run

```bash
gcloud run deploy v2bx \
  --image ghcr.io/visense/v2bxdocker:latest \
  --set-env-vars API_HOST=https://box.gorelay.dpdns.org,API_KEY=your_key,NODE_ID=2
```

### Kubernetes

```yaml
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
          value: "https://box.gorelay.dpdns.org"
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

镜像会在每次推送到 main 分支时自动构建。

查看构建状态：[Actions](https://github.com/visense/v2bxdocker/actions)