# openwrt-ddns-go

[ddns-go](https://github.com/jeessy2/ddns-go) 的 OpenWrt 打包 —— **从上游 tag 源码在官方 SDK（25.12）里自行编译**，产出 apk。

## 包内容

| 路径 | 说明 |
| --- | --- |
| `/usr/bin/ddns-go` | ddns-go 主程序（上游源码编译，非官方预编译二进制） |
| `/etc/init.d/ddns-go` | procd 服务脚本 |
| `/etc/config/ddns-go` | UCI 配置：`enabled` / `listen` / `interval` / `dns` |
| `/etc/ddns-go/ddns-go.yaml` | ddns-go 自身配置（首次启动自动生成，Web UI 管理） |
| `/lib/upgrade/keep.d/ddns-go` | sysupgrade 保留 `/etc/ddns-go/` |

## 架构

x86-64 与 R2S（rockchip/armv8，包架构 `aarch64_generic`）。

## 安装

从 [Releases](https://github.com/hahaher123/openwrt-ddns-go/releases/latest) 下载对应架构的 apk（自签包需 `--allow-untrusted`）：

```sh
apk add --allow-untrusted ./ddns-go-<版本>_<架构>.apk
/etc/init.d/ddns-go enable && /etc/init.d/ddns-go start
```

## 配置

- 服务参数：`/etc/config/ddns-go`（改完 `/etc/init.d/ddns-go restart`）
- 域名解析：Web UI `http://<路由器IP>:9876` 里配置

## 自动化

- CI 每周探测上游新版本（非整点 cron），有新版自动 bump 版本与校验和并发布 Release
- Release 只保留最新 5 个（git tag 全部保留）
