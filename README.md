# V2bX Docker

支持环境变量配置的 V2bX 配置生成器，适用于云端部署。

## 工作原理

1. **配置生成器**：从环境变量生成 `config.json`
2. **挂载配置**：将生成的配置挂载到官方 V2bX 镜像
3. **V2bX 运行**：官方镜像加载配置文件运行

```
环境变量 → 生成 config.json → 挂载到 /etc/V2bX → V2bX 加载
```

## 镜像说明

- **配置生成器镜像**：`ghcr.io/visense/v2bxdocker:latest`
- **V2bX 官方镜像**：`ghcr.io/wyx2685/v2bx:latest`

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

## 使用方式

### 方式一：Docker Compose（推荐）

```yaml
version: '3'
services:
  config-generator:
    image: ghcr.io/visense/v2bxdocker:latest
    environment:
      - API_HOST=https://your-panel.com
      - API_KEY=your_api_key
      - NODE_ID=1
    volumes:
      - ./config:/config
    restart: "no"

  v2bx:
    image: ghcr.io/wyx2685/v2bx:latest
    network_mode: host
    restart: always
    volumes:
      - ./config:/etc/V2bX
    depends_on:
      - config-generator
```

### 方式二：两步运行

**步骤 1：生成配置**
```bash
docker run --rm \
  -e API_HOST="https://your-panel.com" \
  -e API_KEY="your_api_key" \
  -e NODE_ID="1" \
  -v $(pwd)/config:/config \
  ghcr.io/visense/v2bxdocker:latest
```

**步骤 2：运行 V2bX**
```bash
docker run -d \
  --name v2bx \
  --network host \
  --restart always \
  -v $(pwd)/config:/etc/V2bX \
  ghcr.io/wyx2685/v2bx:latest
```

## 云平台部署

### AWS ECS

使用 Init Container 生成配置：

```json
{
  "initContainers": [
    {
      "name": "config-generator",
      "image": "ghcr.io/visense/v2bxdocker:latest",
      "environment": [
        {"name": "API_HOST", "value": "https://your-panel.com"},
        {"name": "API_KEY", "value": "your_key"}
      ],
      "mountPoints": [
        {"sourceVolume": "config", "containerPath": "/config"}
      ]
    }
  ],
  "containers": [
    {
      "name": "v2bx",
      "image": "ghcr.io/wyx2685/v2bx:latest",
      "mountPoints": [
        {"sourceVolume": "config", "containerPath": "/etc/V2bX"}
      ]
    }
  ]
}
```

### Kubernetes

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: v2bx-env
data:
  API_HOST: "https://your-panel.com"
  NODE_ID: "1"
---
apiVersion: v1
kind: Secret
metadata:
  name: v2bx-secret
stringData:
  API_KEY: "your_api_key"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: v2bx
spec:
  replicas: 1
  template:
    spec:
      hostNetwork: true
      initContainers:
      - name: config-generator
        image: ghcr.io/visense/v2bxdocker:latest
        envFrom:
        - configMapRef:
            name: v2bx-env
        - secretRef:
            name: v2bx-secret
        volumeMounts:
        - name: config
          mountPath: /config
      containers:
      - name: v2bx
        image: ghcr.io/wyx2685/v2bx:latest
        volumeMounts:
        - name: config
          mountPath: /etc/V2bX
      volumes:
      - name: config
        emptyDir: {}
```

## 高级配置

### 使用审计规则

1. 准备 `sing_origin.json` 文件
2. 设置环境变量：`ORIGINAL_PATH=/etc/V2bX/sing_origin.json`
3. 挂载审计规则文件到容器

### DNS 证书自动申请

```bash
docker run --rm \
  -e API_HOST="https://your-panel.com" \
  -e API_KEY="your_key" \
  -e CERT_MODE="dns" \
  -e CERT_DOMAIN="node.example.com" \
  -e CERT_PROVIDER="cloudflare" \
  -e CERT_EMAIL="admin@example.com" \
  -e DNS_ENV='{"CLOUDFLARE_EMAIL":"admin@example.com","CLOUDFLARE_API_KEY":"your_cf_key"}' \
  -v $(pwd)/config:/config \
  ghcr.io/visense/v2bxdocker:latest
```

## 构建状态

查看构建状态：[Actions](https://github.com/visense/v2bxdocker/actions)