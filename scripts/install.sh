#!/bin/bash

# 图书馆座位管理系统 - 一键安装脚本 (多架构支持)
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
DATA_DIR="${INSTALL_DIR}/data"
SERVICE_NAME="library-app"
VERSION="1.0.0"
REPO_URL="https://github.com/uglyBoy111/library-app-deploy"
TEMP_DIR="/tmp/library-app-install"

# 检测系统架构
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        info "检测到x86_64架构"
        ARCH_DIR="x86_64"
        ;;
    aarch64|arm64)
        info "检测到ARM64架构"
        ARCH_DIR="arm64"
        ;;
    *)
        error "不支持的架构: $ARCH"
        exit 1
        ;;
esac

# 显示标题
echo "=========================================================="
echo "    南京林业大学图书馆座位预约系统 - 一键安装脚本 v${VERSION}"
echo "    架构: ${ARCH_DIR}"
echo "=========================================================="
echo ""

# 步骤1: 准备系统
info "步骤1: 系统准备..."
if [ -x "$(command -v apt)" ]; then
    apt update -qq
    apt install -y curl wget tar &>/dev/null || {
        error "无法使用apt安装依赖"
        exit 1
    }
elif [ -x "$(command -v yum)" ]; then
    yum -y install curl wget tar &>/dev/null || {
        error "无法使用yum安装依赖"
        exit 1
    }
else
    warn "无法识别的包管理器，尝试继续安装..."
fi
info "系统准备完成"

# 步骤2: 下载应用
info "步骤2: 下载应用中..."
rm -rf $TEMP_DIR &>/dev/null
mkdir -p $TEMP_DIR
cd $TEMP_DIR

# 下载对应架构的应用包
DOWNLOAD_URL="${REPO_URL}/releases/download/v${VERSION}/${ARCH_DIR}/app.tar.gz"
info "正在下载: ${DOWNLOAD_URL}"
wget -q "${DOWNLOAD_URL}" -O app.tar.gz || {
    error "无法下载应用包。请检查网络连接或仓库地址。"
    exit 1
}

# 解压应用
tar -xzf app.tar.gz || {
    error "解压应用包失败"
    exit 1
}
info "应用下载完成"

# 步骤3: 创建必要目录
info "步骤3: 创建应用目录..."
mkdir -p $INSTALL_DIR
mkdir -p $DATA_DIR/instance
mkdir -p $DATA_DIR/logs
mkdir -p $DATA_DIR/keys
info "应用目录创建完成"

# 步骤4: 复制文件
info "步骤4: 部署应用文件..."
cp -r 图书馆座位管理/* $INSTALL_DIR/ || {
    error "复制应用文件失败"
    exit 1
}
info "应用文件部署完成"

# 步骤5: 设置权限
info "步骤5: 设置权限..."
chmod +x $INSTALL_DIR/$APP_NAME
chmod -R 755 $DATA_DIR

# 确定运行用户 - 使用当前sudo用户
SUDO_USER_NAME=$(logname 2>/dev/null || echo $SUDO_USER)
if [ -z "$SUDO_USER_NAME" ]; then
    warn "无法确定sudo用户，使用当前用户"
    SUDO_USER_NAME=$(whoami)
fi

chown -R $SUDO_USER_NAME:$SUDO_USER_NAME $INSTALL_DIR
chown -R $SUDO_USER_NAME:$SUDO_USER_NAME $DATA_DIR
info "已设置 $SUDO_USER_NAME 为应用所有者"

# 步骤6: 创建启动脚本
info "步骤6: 创建启动脚本..."
cat > $INSTALL_DIR/start.sh << EOFINNER
#!/bin/bash
cd "\$(dirname "\$0")"
export APP_DATA_DIR="$DATA_DIR"
./"$APP_NAME"
EOFINNER

chmod +x $INSTALL_DIR/start.sh
info "启动脚本创建完成"

# 步骤7: 创建系统服务
info "步骤7: 创建系统服务..."
cat > /etc/systemd/system/$SERVICE_NAME.service << EOFSERVICE
[Unit]
Description=图书馆座位管理系统
After=network.target

[Service]
Type=simple
User=$SUDO_USER_NAME
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/$APP_NAME
Restart=always
Environment="APP_DATA_DIR=$DATA_DIR"

[Install]
WantedBy=multi-user.target
EOFSERVICE

systemctl daemon-reload
info "系统服务创建完成"

# 步骤8: 启用和启动服务
info "步骤8: 启用服务..."
systemctl enable $SERVICE_NAME.service
info "服务已启用"

info "启动服务..."
systemctl start $SERVICE_NAME.service || {
    error "启动服务失败，尝试查看日志以获取更多信息"
    journalctl -u $SERVICE_NAME.service --no-pager -n 20
    exit 1
}

# 显示服务状态
systemctl status $SERVICE_NAME.service --no-pager

# 步骤9: 清理
info "步骤9: 清理临时文件..."
cd /
rm -rf $TEMP_DIR
info "清理完成"

# 获取服务器IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# 完成
echo ""
echo "=========================================================="
echo "          图书馆座位管理系统安装完成！"
echo "=========================================================="
echo ""
echo "应用已安装到: $INSTALL_DIR"
echo "数据目录位置: $DATA_DIR"
echo ""
echo "访问方式: http://${SERVER_IP}:5000"
echo ""
echo "管理命令:"
echo "启动服务: sudo systemctl start $SERVICE_NAME"
echo "停止服务: sudo systemctl stop $SERVICE_NAME"
echo "查看状态: sudo systemctl status $SERVICE_NAME"
echo "查看日志: sudo journalctl -u $SERVICE_NAME -f"
echo "或: tail -f $DATA_DIR/logs/library_reservation.log"
echo ""
