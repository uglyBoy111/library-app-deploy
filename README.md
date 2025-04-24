# 图书馆座位管理系统部署指南

这是图书馆座位管理系统的部署仓库，支持 x86_64 和 arm64 架构。本系统提供一键部署和卸载功能。

## 系统要求

- Linux 操作系统 (支持 x86_64 或 arm64 架构)
- root 权限
- curl 或 wget 工具
- 开放 5000 端口（应用运行端口）

## 一键部署

### 使用 curl

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/uglyBoy111/library-app-deploy/main/scripts/install.sh)"
```

### 使用 wget

```bash
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/uglyBoy111/library-app-deploy/main/scripts/install.sh)"
```

部署完成后，应用将自动运行，并显示访问链接。

## 卸载方法

### 使用内置卸载命令

```bash
sudo uninstall-library-seat-app
```

### 使用 curl 直接卸载

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/uglyBoy111/library-app-deploy/main/scripts/uninstall.sh)"
```

### 使用 wget 直接卸载

```bash
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/uglyBoy111/library-app-deploy/main/scripts/uninstall.sh)"
```

## 常见问题

### 1. 如果遇到下载问题，可以尝试以下备用安装命令：

使用 GitHub API：
```bash
sudo bash -c "$(curl -fsSL https://github.com/uglyBoy111/library-app-deploy/raw/main/scripts/install.sh)"
```

使用 jsDelivr CDN：
```bash
sudo bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/uglyBoy111/library-app-deploy@main/scripts/install.sh)"
```

### 2. 部署后无法访问网站？

检查以下几点：
- 确保 5000 端口已开放
- 检查防火墙设置
- 确保应用程序正在运行（使用 `ps aux | grep "图书馆座位管理"` 查看）

### 3. 如何重启应用？

```bash
# 停止当前运行的实例
sudo pkill -f "图书馆座位管理"

# 重新启动应用
library-seat-app
```

## 支持的架构

- x86_64 (64位 Intel/AMD 处理器)
- arm64 (64位 ARM 处理器，如树莓派4)

系统会自动检测您的架构并安装相应版本。

## 文件路径说明

- 应用程序安装路径：`/opt/library-seat-app`
- 可执行文件链接：`/usr/local/bin/library-seat-app`
- 卸载脚本链接：`/usr/local/bin/uninstall-library-seat-app`

## 技术支持

如有问题，请提交 Issue 至本仓库。
