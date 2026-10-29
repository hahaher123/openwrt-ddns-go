# openwrt-ddns-go

[ddns-go](https://github.com/jeessy2/ddns-go) 的 OpenWrt 打包 —— **从上游 tag 源码在官方 SDK（25.12.6）里自行编译**，产出 apk。

## 适配的 LuCI 与链接

本包是 [sirpdboy/luci-app-ddns-go](https://github.com/sirpdboy/luci-app-ddns-go) 的**内核替换包**：该 LuCI 应用的 `LUCI_DEPENDS:=+ddns-go`，而本包的包名就是 `ddns-go`，所以装好本包后它的依赖即被满足，不会再拉它自带的旧内核。UCI 契约（段类型 `basic`）与它完全一致，LuCI 写入的配置原样生效。

配套 LuCI 前端使用自建 fork [hahaher123/luci-app-ddns-go](https://github.com/hahaher123/luci-app-ddns-go)（基于 sirpdboy 版的**自用修改**，声明见该仓库 README）：https 环境下 LuCI 内嵌面板改为同源反代 `/ddns-go/`（包内自带 nginx locations，装上即生效，http/https 自适应），并出 noarch 单份 apk。内核仍由本仓库提供。

| 组件 | 适配范围 | 链接 |
| --- | --- | --- |
| LuCI 应用 `luci-app-ddns-go` | 1.6.8-r20261030 及以后（依赖名 `ddns-go` 一致即可） | [自建 fork](https://github.com/hahaher123/luci-app-ddns-go) · [Releases](https://github.com/hahaher123/luci-app-ddns-go/releases/latest) ·（上游 [sirpdboy](https://github.com/sirpdboy/luci-app-ddns-go)） |
| 上游程序 ddns-go | 跟随上游 tag，本包编译 6.17.7 | [jeessy2/ddns-go](https://github.com/jeessy2/ddns-go/releases) |
| 本包 | 见本仓库 Release | [Releases](https://github.com/hahaher123/openwrt-ddns-go/releases/latest) |
| 构建环境 | 官方 SDK 25.12.6（apk-tools 3） | [openwrt/openwrt](https://github.com/openwrt/openwrt) |

未验证：其它 fork 的 `luci-app-ddns-go`（例如各分支固件里自带的那份）。它们的 UCI 段名一旦不是 `basic`，本包的 init 就取不到配置。

内核升级跟随本仓库 Release。LuCI 页面上的 `Check Update` 是给该应用自带内核用的，它在本包上的行为未验证。

**安装顺序**：先装本包，再装 LuCI 应用 —— 反过来 apk 会先去找它依赖的 `ddns-go` 而失败（命令见下方「安装」）。

## 包内容

| 路径 | 说明 |
| --- | --- |
| `/usr/bin/ddns-go` | ddns-go 主程序（上游源码编译，非官方预编译二进制） |
| `/etc/init.d/ddns-go` | procd 服务脚本 |
| `/etc/config/ddns-go` | UCI 配置，段 `basic` |
| `/etc/uci-defaults/ddns-go-user` | 首次启动创建 `ddns-go` 运行用户 |
| `/etc/ddns-go/ddns-go-config.yaml` | ddns-go 自身配置（首次启动自动生成，Web UI 管理） |
| `/lib/upgrade/keep.d/ddns-go` | sysupgrade 保留 `/etc/ddns-go/` |

## 架构

x86-64 与 R2S（rockchip/armv8，包架构 `aarch64_generic`）。

## 安装

从 [Releases](https://github.com/hahaher123/openwrt-ddns-go/releases/latest) 下载对应架构的 apk（自签包需 `--allow-untrusted`）：

```sh
apk add --allow-untrusted ./ddns-go-<版本>_<架构>.apk
apk add --allow-untrusted ./luci-app-ddns-go-<版本>.apk   # 需 25.12 的 apk 版本，不是 ipk
/etc/init.d/ddns-go enable && /etc/init.d/ddns-go start
```

只出 apk（25.12 及以后）。24.10 及更早的 `opkg` / `ipk` 系统不在支持范围。

## 配置

服务参数在 `/etc/config/ddns-go`（段 `basic`），与 LuCI 应用一一对应：

| 选项 | 默认 | 作用 |
| --- | --- | --- |
| `enabled` | `1` | 是否随服务启动 |
| `port` | `9876` | Web UI 监听端口 |
| `time` | `300` | 同步间隔（秒） |
| `ctimes` | `5` | 每 N 次检查才与域名服务商比对一次（`-cacheTimes`） |
| `dns` | `223.5.5.5` | 自定义 DNS 服务器 |
| `skipverify` | `0` | 跳过 HTTPS 证书校验 |
| `noweb` | `0` | 关闭 Web UI |
| `delay` | `20` | 开机后延迟启动（仅在开机 120 秒内生效） |

改完 `/etc/init.d/ddns-go restart`。域名解析在 Web UI `http://<路由器IP>:9876` 里配置。

## 自动化

- CI 每周探测上游新版本（非整点 cron），有新版自动 bump 版本与校验和并发布 Release
- Release 只保留最新 5 个（git tag 全部保留）
