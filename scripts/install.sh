#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 仓库信息
REPO_OWNER="uglyBoy111"
REPO_NAME="library-app-deploy"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"
GITHUB_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/raw/${BRANCH}"

# 安装目录
INSTALL_DIR="/opt/library-seat-app"
BIN_DIR="/usr/local/bin"
APP_NAME="图书馆座位管理"
DEPS_ARCHIVE="_internal.tar.gz"
APP_PORT=5000

# 检查是否为 root 用户
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}错误: 此脚本需要 root 权限运行${NC}"
    echo "请使用 sudo 运行此脚本"
    exit 1
fi

# 检测系统架构
detect_arch() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64)
            echo "x86_64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            echo -e "${RED}不支持的架构: $arch${NC}"
            exit 1
            ;;
    esac
}

# 下载文件函数，如果一种方法失败会尝试备用方法
download_file() {
    local url=$1
    local destination=$2
    local description=$3

    echo "下载${description}..."
    
    # 尝试使用curl下载
    if ! curl -L -f -o "${destination}" "${url}"; then
        echo "尝试备用下载方法..."
        # 备用下载URL
        local alt_url="${url/raw.githubusercontent.com/github.com}"
        alt_url="${alt_url/\/main\//\/raw\/main\/}"
        
        if ! curl -L -f -o "${destination}" "${alt_url}"; then
            echo -e "${RED}错误: 无法下载${description}${NC}"
            echo "URL: ${url}"
            echo "备用URL: ${alt_url}"
            return 1
        fi
    fi
    
    return 0
}

ARCH=$(detect_arch)
echo -e "${GREEN}=== 图书馆座位管理系统一键部署工具 ===${NC}"
echo -e "检测到系统架构: ${YELLOW}${ARCH}${NC}"
echo -e "安装日期: $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "当前用户: ${YELLOW}$(whoami)${NC}"

# 创建临时目录和安装目录
TEMP_DIR=$(mktemp -d)
echo "创建安装目录..."
mkdir -p "${INSTALL_DIR}"

# 下载二进制文件
BINARY_URL="${BASE_URL}/releases/${ARCH}/${APP_NAME}"
BINARY_GITHUB_URL="${GITHUB_URL}/releases/${ARCH}/${APP_NAME}"
echo "下载应用程序..."
if ! curl -L -f -o "${INSTALL_DIR}/${APP_NAME}" "${BINARY_URL}"; then
    echo "尝试备用下载地址..."
    if ! curl -L -f -o "${INSTALL_DIR}/${APP_NAME}" "${BINARY_GITHUB_URL}"; then
        echo -e "${RED}错误: 无法下载应用程序${NC}"
        echo "请检查以下网址是否可访问:"
        echo "${BINARY_URL}"
        echo "${BINARY_GITHUB_URL}"
        rm -rf "${TEMP_DIR}"
        exit 1
    fi
fi
chmod +x "${INSTALL_DIR}/${APP_NAME}"

# 下载并解压依赖文件
DEPS_URL="${BASE_URL}/releases/${ARCH}/${DEPS_ARCHIVE}"
DEPS_GITHUB_URL="${GITHUB_URL}/releases/${ARCH}/${DEPS_ARCHIVE}"
echo "下载依赖文件..."
if ! curl -L -f -o "${TEMP_DIR}/${DEPS_ARCHIVE}" "${DEPS_URL}"; then
    echo "尝试备用下载地址..."
    if ! curl -L -f -o "${TEMP_DIR}/${DEPS_ARCHIVE}" "${DEPS_GITHUB_URL}"; then
        echo -e "${RED}错误: 无法下载依赖文件${NC}"
        echo "请检查以下网址是否可访问:"
        echo "${DEPS_URL}"
        echo "${DEPS_GITHUB_URL}"
        rm -rf "${TEMP_DIR}"
        exit 1
    fi
fi

echo "解压依赖文件..."
tar -xzf "${TEMP_DIR}/${DEPS_ARCHIVE}" -C "${INSTALL_DIR}"

# 创建符号链接
echo "创建程序链接..."
ln -sf "${INSTALL_DIR}/${APP_NAME}" "${BIN_DIR}/library-seat-app"

# 下载卸载脚本
UNINSTALL_URL="${BASE_URL}/scripts/uninstall.sh"
UNINSTALL_GITHUB_URL="${GITHUB_URL}/scripts/uninstall.sh"
echo "下载卸载脚本..."
if ! curl -L -f -o "${INSTALL_DIR}/uninstall.sh" "${UNINSTALL_URL}"; then
    echo "尝试备用下载地址..."
    if ! curl -L -f -o "${INSTALL_DIR}/uninstall.sh" "${UNINSTALL_GITHUB_URL}"; then
        echo -e "${RED}错误: 无法下载卸载脚本${NC}"
        echo "请检查以下网址是否可访问:"
        echo "${UNINSTALL_URL}"
        echo "${UNINSTALL_GITHUB_URL}"
        # 继续安装过程，卸载脚本不是必需的
    fi
fi
chmod +x "${INSTALL_DIR}/uninstall.sh"
ln -sf "${INSTALL_DIR}/uninstall.sh" "${BIN_DIR}/uninstall-library-seat-app"

# 清理临时目录
rm -rf "${TEMP_DIR}"

echo -e "${GREEN}安装完成!${NC}"
echo -e "正在启动应用程序..."

# 在后台运行应用程序并将输出重定向到/dev/null
nohup "${INSTALL_DIR}/${APP_NAME}" > /dev/null 2>&1 &

# 等待应用程序启动
sleep 2

# 获取本机内网IP
INTERNAL_IP=$(hostname -I | awk '{print $1}')

# 尝试获取公网IP (如果有网络连接)
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "无法获取公网IP")

echo -e "${GREEN}图书馆座位管理应用已成功启动!${NC}"
echo -e "${YELLOW}应用网站运行在 ${APP_PORT} 端口${NC}"
echo -e ""
echo -e "访问链接:"
echo -e "${BLUE}内网链接: http://${INTERNAL_IP}:${APP_PORT}${NC}"

if [ "${PUBLIC_IP}" != "无法获取公网IP" ]; then
    echo -e "${BLUE}公网链接: http://${PUBLIC_IP}:${APP_PORT}${NC}"
else
    echo -e "${YELLOW}公网链接: 无法获取公网IP，请检查网络连接${NC}"
fi

echo -e ""
echo -e "${GREEN}提示：${NC}如果通过公网访问，您可能需要开放防火墙端口 ${APP_PORT}"
echo -e ""
echo -e "您可以随时使用以下命令再次运行应用: ${YELLOW}library-seat-app${NC}"
echo -e "要卸载应用，请运行: ${YELLOW}sudo uninstall-library-seat-app${NC}"
