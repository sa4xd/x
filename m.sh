#!/bin/bash

set -e

echo "[+] 安装依赖..."
apt update && apt install -y git python3 python3-pip && apt install -y vim-common

echo "[+] 克隆项目..."
git clone -b stable https://github.com/alexbers/mtprotoproxy.git
cd mtprotoproxy
# 写入 requirements.txt
cat > requirements.txt <<EOF
aiohttp>=3.8.1
uvloop>=0.17.0
EOF

# 安装依赖
pip3 install -r requirements.txt

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
    # Classic mode, easy to detect
    "classic": False,

    # Makes the proxy harder to detect
    # Can be incompatible with very old clients
    "secure": False,

    # Makes the proxy even more hard to detect
    # Can be incompatible with old clients
    "tls": True
}

# The domain for TLS mode, bad clients are proxied there
TLS_DOMAIN = "www.bing.com"

# Tag for advertising, obtainable from @MTProxybot
AD_TAG = ""
EOF


echo "[+] 启动代理服务..."
nohup python3 mtprotoproxy.py > proxy.log 2>&1 &

echo "[√] MTProto Proxy 启动成功！"
echo "连接 URI：tg://proxy?server=<你的域名或IP>&port=14657&secret=ee$SECRET"

