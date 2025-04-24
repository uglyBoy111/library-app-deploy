# 南京林业大学图书馆座位管理系统

![版本](https://img.shields.io/badge/版本-1.0.0-blue)
![更新日期](https://img.shields.io/badge/更新日期-2025--04--24-green)

## 系统要求

- 操作系统：Ubuntu 20.04+/Debian 10+/CentOS 8+/Raspberry Pi OS
- 架构：x86_64 或 ARM64 (树莓派)
- 内存：最低1GB RAM
- 存储：最低200MB空间
- 权限：需要sudo权限

## 一键部署

```bash
curl -fsSL https://raw.githubusercontent.com/uglyBoy111/library-app-deploy/main/scripts/install.sh | sudo bash
```

安装完成后访问：`http://服务器IP:5000`，默认管理员账号:admin/admin

## 一键卸载

```bash
sudo bash /opt/library-app/uninstall.sh
```

## 系统管理

```bash
# 启动/停止/重启
sudo systemctl start library-app
sudo systemctl stop library-app
sudo systemctl restart library-app

# 状态和日志
sudo systemctl status library-app
sudo journalctl -u library-app -f
```

## 常见问题

- 无法访问：检查防火墙 `sudo ufw allow 5000/tcp`
- 服务不启动：检查日志 `sudo journalctl -u library-app -n 50`
- 配置修改：编辑 `/opt/library-app/data/instance/config.ini`

---
© 2025 uglyBoy111
