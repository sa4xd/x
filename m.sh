#!/bin/bash

set -e

echo "[+] 安装依赖..."
apt update && apt install -y git python3 python3-pip vim-common

echo "[+] 克隆项目..."
git clone -b stable https://github.com/alexbers/mtprotoproxy.git
cd mtprotoproxy

echo "[+] 写入 requirements.txt..."
cat > requirements.txt <<EOF
aiohttp>=3.8.1
uvloop>=0.17.0
EOF

echo "[+] 安装 Python 依赖..."
pip3 install -r requirements.txt

echo "[+] 生成连接密钥..."
SECRET=$(python3 -c "import os; print(os.urandom(16).hex())")

echo "[+] 写入配置文件..."
cat > config.py <<EOF
PORT = 14657

# name -> secret (32 hex chars)
USERS = {
    "tg": "$SECRET"
}

MODES = {
    "classic": False,
    "secure": False,
    "tls": True
}

TLS_DOMAIN = "www.bing.com"
AD_TAG = ""

# Prometheus Web 监控接口
METRICS_PORT = 14657
METRICS_LISTEN_ADDR_IPV4 = "0.0.0.0"
METRICS_WHITELIST = ["127.0.0.1", "::1", "0.0.0.0"]
METRICS_EXPORT_LINKS = True
EOF

echo "[+] 启动代理服务..."
nohup python3 mtprotoproxy.py > proxy.log 2>&1 &

echo "[√] MTProto Proxy 启动成功！"
echo "连接密钥：$SECRET"
echo "连接 URI：tg://proxy?server=<你的域名或IP>&port=14657&secret=ee$SECRET"
echo "监控接口：http://<你的域名或IP>:14657/metrics"
