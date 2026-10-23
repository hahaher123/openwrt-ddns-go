#!/usr/bin/env bash
# 在 OpenWrt SDK 容器里编译本 feed 的包。
#
# 移植自 openwrt-mihomo/.ci/build-in-sdk.sh（已实测闭环），改动仅注释：
# 不用 openwrt/gh-action-sdk composite action（--env 白名单传不进 FIXUP，
# entrypoint 会 grep 日志把 "HASH uses deprecated hash" 当硬失败），改为自己
# docker run 官方镜像 + 钉 SHA 的官方 entrypoint。
#
# 本包 PKG_HASH 是真实 sha256（upstream-check 每次升版重新计算），正常构建
# 不会触发 FIXUP；带上它只是防御性兜底（只改容器内 /feed 副本，不回写仓库）。
#
# 需要的环境变量（与 action 同名同义）：
#   ARCH          镜像 tag 后缀，如 x86_64-25.12.6
#   FEEDNAME      feed 名，即 /feed 的挂载源名
#   PACKAGES      空格分隔的包名
#   FEED_DIR      feed 根目录（挂到 /feed）
#   ARTIFACTS_DIR 产物目录（挂到 /artifacts）
#   V / INDEX / BUILD_LOG / KEY_BUILD  透传给 entrypoint
set -e

: "${ARCH:?ARCH 未设置}"
: "${FEEDNAME:?FEEDNAME 未设置}"
: "${PACKAGES:?PACKAGES 未设置}"
FEED_DIR="${FEED_DIR:-${GITHUB_WORKSPACE:-$PWD}}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-${FEED_DIR}/artifacts}"
ENTRYPOINT="${RUNNER_TEMP:-/tmp}/sdk-entrypoint.sh"

if [ ! -x "${ENTRYPOINT}" ]; then
	echo "找不到 SDK entrypoint: ${ENTRYPOINT}" >&2
	exit 1
fi

# 容器内是 uid 1000，宿主目录先交出去，否则 entrypoint 写不了 dl/ 与 bin/。
sudo chown -R 1000:1000 "${FEED_DIR}" "${ARTIFACTS_DIR}"

docker run --rm \
	--env ARCH \
	--env BUILD_LOG \
	--env FEEDNAME \
	--env PACKAGES \
	--env V \
	--env INDEX \
	--env KEY_BUILD \
	--env FIXUP=1 \
	-v "${FEED_DIR}:/feed" \
	-v "${ARTIFACTS_DIR}:/artifacts" \
	-v "${ENTRYPOINT}:/entrypoint.sh:ro" \
	--entrypoint /entrypoint.sh \
	"ghcr.io/openwrt/sdk:${ARCH}"

# 产物归还原主：容器内以 root 编译，产物属主是 root；后面的 git 操作会报
# dubious ownership，upload-artifact 也可能读不到。失败只告警不中断。
if ! sudo chown -R --reference="${FEED_DIR}/.." "${FEED_DIR}" "${ARTIFACTS_DIR}" 2>/dev/null; then
	echo "::warning::产物归还原主失败；若后续 upload-artifact 报读不到文件，请检查属主"
fi
