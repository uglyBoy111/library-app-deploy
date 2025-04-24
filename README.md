```markdown name=README.md
# 南京林业大学图书馆座位管理系统

![版本](https://img.shields.io/badge/版本-1.0.0-blue)
![更新日期](https://img.shields.io/badge/更新日期-2025--04--24-green)
![平台](https://img.shields.io/badge/平台-Linux%20(x86__64/ARM64)-orange)

南京林业大学图书馆座位预约自动化管理系统，支持自动预约、迟到保护、多用户管理。

## 系统特点

- 多架构支持：同时支持 x86_64 和 ARM64 (树莓派等) 平台
- 自动部署：一键安装，无需复杂配置
- 自动预约：按照设定规则自动预约喜爱的座位
- 多用户管理：支持多账号管理和权限控制

## 系统要求

- 操作系统：Ubuntu 20.04+/Debian 10+/CentOS 8+/Raspberry Pi OS
- 内存：最低1GB RAM，推荐2GB以上
- 存储：至少200MB可用空间
- 网络：连接互联网用于自动预约
- 权限：需要sudo权限进行安装

## 一键部署

```bash
curl -fsSL https://raw.githubusercontent.com/uglyBoy111/library-app-deploy/main/scripts/install.sh | sudo bash
```

或使用 wget:

```bash
wget -O - https://raw.githubusercontent.com/uglyBoy111/library-app-deploy/main/scripts/install.sh | sudo bash
```

安装完成后，通过浏览器访问：`http://服务器IP:5000`

## 一键卸载

```bash
curl -fsSL https://raw.githubusercontent.com/uglyBoy111/library-app-deploy/main/scripts/uninstall.sh | sudo bash
```

或使用 wget:

```bash
wget -O - https://raw.githubusercontent.com/uglyBoy111/library-app-deploy/main/scripts/uninstall.sh | sudo bash
```

## 系统管理

系统安装后，可使用以下命令进行管理：

```bash
# 启动服务
sudo systemctl start library-app

# 停止服务
sudo systemctl stop library-app

# 重启服务
sudo systemctl restart library-app

# 查看服务状态
sudo systemctl status library-app

# 查看日志
sudo journalctl -u library-app -f
```

## 基本使用

1. **首次登录**：使用默认管理员账号 (admin/admin) 登录
2. **修改密码**：首次登录后请立即修改默认密码
3. **添加账号**：在"账号管理"中添加图书馆账号
4. **设置规则**：配置座位预约规则和时间段
5. **查看统计**：在"统计分析"页面查看预约情况

## 常见问题

**Q: 安装后无法访问系统？**  
A: 检查防火墙是否开放5000端口：`sudo ufw allow 5000/tcp`

**Q: 预约时出现错误？**  
A: 检查账号信息是否正确，以及网络连接是否正常

**Q: 如何修改系统配置？**  
A: 编辑 `/opt/library-app/data/instance/config.ini` 文件

## 版本更新

### v1.0.0 (2025-04-24)
- 初始版本发布
- 支持x86_64和ARM64架构
- 实现基本预约和管理功能

## 维护与支持

- 项目维护：uglyBoy111
- 问题反馈：请在Github Issues提交问题
- 更新日期：2025-04-24

---

© 2025 南京林业大学图书馆座位管理系统。保留所有权利。
```
