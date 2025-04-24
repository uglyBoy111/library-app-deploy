#!/bin/bash

# 南京林业大学图书馆座位管理系统安装脚本
# 作者: uglyBoy111
# 日期: 2025-04-24

# 颜色设置
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# 函数定义
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
  error "请使用root权限运行此脚本"
  echo "尝试: sudo bash install.sh"
  exit 1
fi

# 变量定义
APP_NAME="图书馆座位管理"
INSTALL_DIR="/opt/library-app"
SERVICE_NAME="library-app"
APP_REPO="https://raw.githubusercontent.com/uglyBoy111/library-app-deploy/main"

# 显示标题
echo "=========================================================="
echo "       南京林业大学图书馆座位预约系统 - 安装脚本"
echo "=========================================================="
echo ""

# 步骤1: 检测系统架构
info "步骤1: 检测系统架构..."
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    APP_URL="${APP_REPO}/releases/x86_64/app-x86_64.tar.gz"
    info "检测到x86_64架构"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    APP_URL="${APP_REPO}/releases/arm64/app-arm64.tar.gz"
    info "检测到ARM64架构"
else
    error "不支持的系统架构: $ARCH"
    exit 1
fi

# 步骤2: 创建安装目录
info "步骤2: 创建安装目录..."
mkdir -p $INSTALL_DIR
mkdir -p $INSTALL_DIR/data/instance
mkdir -p $INSTALL_DIR/data/logs
mkdir -p $INSTALL_DIR/data/keys

# 步骤3: 下载应用包
info "步骤3: 下载应用包..."
TMP_FILE="/tmp/library-app.tar.gz"
if command -v curl &>/dev/null; then
    curl -L -o $TMP_FILE $APP_URL || {
        error "应用下载失败，请检查网络连接或链接是否有效。"
        exit 1
    }
elif command -v wget &>/dev/null; then
    wget -O $TMP_FILE $APP_URL || {
        error "应用下载失败，请检查网络连接或链接是否有效。"
        exit 1
    }
else
    error "未找到curl或wget命令，请先安装其中一个工具。"
    exit 1
fi

# 步骤4: 解压应用包
info "步骤4: 解压应用包..."
tar -xzf $TMP_FILE -C $INSTALL_DIR || {
    error "解压应用包失败。"
    exit 1
}
rm -f $TMP_FILE

# 步骤5: 安装uninstall脚本
info "步骤5: 安装卸载脚本..."
curl -s -o $INSTALL_DIR/uninstall.sh $APP_REPO/scripts/uninstall.sh || {
    warn "卸载脚本下载失败，将创建简单卸载脚本。"
    cat > $INSTALL_DIR/uninstall.sh << 'EOF'
#!/bin/bash
systemctl stop library-app
systemctl disable library-app
rm -f /etc/systemd/system/library-app.service
rm -rf /opt/library-app
systemctl daemon-reload
echo "图书馆座位管理系统已卸载"
EOF
}
chmod +x $INSTALL_DIR/uninstall.sh

# 步骤6: 设置权限
info "步骤6: 设置应用权限..."
chmod +x $INSTALL_DIR/图书馆座位管理
chown -R root:root $INSTALL_DIR

# 步骤7: 创建系统服务
info "步骤7: 创建系统服务..."
cat > /etc/systemd/system/$SERVICE_NAME.service << EOF
[Unit]
Description=图书馆座位管理系统
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/图书馆座位管理
WorkingDirectory=$INSTALL_DIR
Restart=always
Environment="APP_DATA_DIR=$INSTALL_DIR/data"

[Install]
WantedBy=multi-user.target
EOF

# 步骤8: 启动服务
info "步骤8: 启动服务..."
systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME

# 获取IP地址
IP_ADDR=$(hostname -I | awk '{print $1}')
if [ -z "$IP_ADDR" ]; then
    IP_ADDR="localhost"
fi

# 完成
echo ""
echo "=========================================================="
echo "          图书馆座位管理系统安装完成！"
echo "=========================================================="
echo ""
echo "访问地址: http://$IP_ADDR:5000"
echo "默认管理员账号: admin"
echo "默认密码: admin"
echo ""
echo "请立即修改默认密码以确保系统安全！"
echo ""
echo "卸载命令: sudo bash $INSTALL_DIR/uninstall.sh"
echo ""
