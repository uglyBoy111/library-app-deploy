#!/bin/bash

# 南京林业大学图书馆座位管理系统 - 卸载脚本
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
  echo "尝试: sudo bash uninstall.sh"
  exit 1
fi

# 变量定义
APP_NAME="图书馆座位管理"
INSTALL_DIR="/opt/library-app"
SERVICE_NAME="library-app"
DESKTOP_FILE="/usr/share/applications/library-app.desktop"

# 显示标题
echo "=========================================================="
echo "       南京林业大学图书馆座位预约系统 - 卸载脚本"
echo "=========================================================="
echo ""

# 步骤1: 停止服务
info "步骤1: 停止服务..."
systemctl stop $SERVICE_NAME 2>/dev/null || {
    warn "服务停止失败或不存在，继续卸载"
}

# 步骤2: 禁用服务
info "步骤2: 禁用服务..."
systemctl disable $SERVICE_NAME 2>/dev/null || {
    warn "服务禁用失败或不存在，继续卸载"
}

# 步骤3: 删除服务文件
info "步骤3: 删除服务文件..."
if [ -f "/etc/systemd/system/$SERVICE_NAME.service" ]; then
    rm -f /etc/systemd/system/$SERVICE_NAME.service
    systemctl daemon-reload
    info "服务文件已删除"
else
    warn "服务文件不存在，跳过"
fi

# 步骤4: 删除桌面快捷方式
info "步骤4: 删除桌面快捷方式..."
if [ -f "$DESKTOP_FILE" ]; then
    rm -f "$DESKTOP_FILE"
    info "桌面快捷方式已删除"
else
    warn "桌面快捷方式不存在，跳过"
fi

# 步骤5: 删除应用数据
info "步骤5: 删除应用数据..."
if [ -d "$INSTALL_DIR" ]; then
    # 询问是否保留数据
    read -p "是否保留用户数据? (y/n): " KEEP_DATA
    if [[ "$KEEP_DATA" == "y" || "$KEEP_DATA" == "Y" ]]; then
        # 如果保留数据，备份到用户目录
        BACKUP_DIR="$HOME/library-app-backup-$(date +%Y%m%d%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        cp -r "$INSTALL_DIR/data" "$BACKUP_DIR/" 2>/dev/null
        info "用户数据已备份至: $BACKUP_DIR"
    fi
    
    # 删除安装目录
    rm -rf "$INSTALL_DIR"
    info "应用文件已删除"
else
    warn "安装目录不存在，跳过"
fi

# 完成
echo ""
echo "=========================================================="
echo "          图书馆座位管理系统卸载完成！"
echo "=========================================================="
if [[ "$KEEP_DATA" == "y" || "$KEEP_DATA" == "Y" ]]; then
    echo "用户数据已备份至: $BACKUP_DIR"
fi
echo ""
echo "感谢您使用图书馆座位管理系统！"
echo ""
