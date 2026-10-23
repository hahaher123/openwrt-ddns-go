#
# Copyright (C) 2026 hahaher123
#
# SPDX-License-Identifier: MIT
#
# ddns-go —— 上游 https://github.com/jeessy2/ddns-go 的 OpenWrt 打包。
# 从上游 tag 源码自行编译（golang/host 工具链由 SDK 的 packages feed 提供）。
# PKG_VERSION 跟随上游版本；PKG_RELEASE 只在本包安装产物变化时递增，
# 升上游版本时复位为 1（upstream-check.yml 自动维护）。

include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-go
PKG_VERSION:=6.17.7
PKG_RELEASE:=3

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/jeessy2/ddns-go/archive/refs/tags/
PKG_HASH:=f7001004e092d9641aad5a94158e0b4cae4a53a7f5c7d96d5c6af3d246c56fcc

PKG_MAINTAINER:=hahaher123
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

# GO_PKG 系列变量必须先于 include golang-package.mk 定义：
# 它的 Build/Compile 接线在 include 时按 ifneq ($(GO_PKG),) 求值，
# 后定义会让接线整块跳过（构建会退化成 make 上游自带 Makefile）。

# module 路径带 /v6 主版本后缀；go install 产出二进制时会剥掉它，
# 产物名是 ddns-go（Go >= 1.18 的行为）。
GO_PKG:=github.com/jeessy2/ddns-go/v6
GO_PKG_BUILD_PKG:=github.com/jeessy2/ddns-go/v6
GO_PKG_LDFLAGS_X:=main.version=v$(PKG_VERSION)

include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/ddns-go
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Dynamic DNS client with web UI (ddns-go)
  URL:=https://github.com/jeessy2/ddns-go
  DEPENDS:=+ca-bundle
endef

define Package/ddns-go/description
  ddns-go is a dynamic DNS client supporting a wide range of DNS providers,
  with a built-in web UI for configuration. Compiled from upstream source
  during the SDK build; binary is arch-specific (x86_64 / aarch64_generic).
endef

define Package/ddns-go/conffiles
/etc/config/ddns-go
endef

define Package/ddns-go/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ddns-go $(1)/usr/bin/ddns-go
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config $(1)/etc/ddns-go $(1)/etc/uci-defaults $(1)/lib/upgrade/keep.d
	$(INSTALL_BIN) $(CURDIR)/root/etc/init.d/ddns-go $(1)/etc/init.d/ddns-go
	$(INSTALL_CONF) $(CURDIR)/root/etc/config/ddns-go $(1)/etc/config/ddns-go
	$(INSTALL_BIN) $(CURDIR)/root/etc/uci-defaults/ddns-go-user $(1)/etc/uci-defaults/ddns-go-user
	$(INSTALL_DATA) $(CURDIR)/files/ddns-go.keep $(1)/lib/upgrade/keep.d/ddns-go
endef

$(eval $(call BuildPackage,ddns-go))
