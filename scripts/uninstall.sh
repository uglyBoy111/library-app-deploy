#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

# 安装目录
INSTALL_DIR="/opt/library-seat-app"
BIN_DIR="/usr/local/bin"
APP_NAME="图书馆座位管理"

# 检查是否为 root 用户
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}错误: 此脚本需要 root 权限运行${NC}"
    echo "请使用 sudo 运行此脚本"
    exit 1
fi

echo -e "${YELLOW}正在卸载图书馆座位管理系统...${NC}"

# 终止运行的应用程序实例
APP_PID=$(pgrep -f "${APP_NAME}" || echo "")
if [ -n "${APP_PID}" ]; then
    echo "正在停止运行中的应用实例..."
    kill ${APP_PID}
    sleep 1
fi

# 删除符号链接
if [ -L "${BIN_DIR}/library-seat-app" ]; then
    echo "删除应用链接..."
    rm -f "${BIN_DIR}/library-seat-app"
fi

if [ -L "${BIN_DIR}/uninstall-library-seat-app" ]; then
    echo "删除卸载链接..."
    rm -f "${BIN_DIR}/uninstall-library-seat-app"
fi

# 删除安装目录
if [ -d "${INSTALL_DIR}" ]; then
    echo "删除安装目录..."
    rm -rf "${INSTALL_DIR}"
fi

echo -e "${GREEN}图书馆座位管理系统已成功卸载${NC}"
