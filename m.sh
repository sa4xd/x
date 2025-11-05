#!/bin/bash

set -e

echo "[+] 安装依赖..."
apt update && apt install -y git python3 python3-pip

echo "[+] 克隆项目..."
git clone -b stable https://github.com/alexbers/mtprotoproxy.git
cd mtprotoproxy

echo "[+] 安装 Python 依赖..."
pip3 install -r requirements.txt

echo "[+] 生成连接密钥..."
SECRET=$(head -c 16 /dev/urandom | xxd -ps)

echo "[+] 写入配置文件..."
cat > config.py <<EOF
PORT = 14657
USERS = {
    'tg': '$SECRET'
}
AD_TAG = ''
EOF

echo "[+] 启动代理服务..."
nohup python3 mtprotoproxy.py > proxy.log 2>&1 &

echo "[√] MTProto Proxy 启动成功！"
echo "连接密钥：$SECRET"
