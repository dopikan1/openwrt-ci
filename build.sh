#!/bin/sh
# shellcheck disable=SC2086,SC3043,SC2164,SC2103,SC2046,SC2155

set -e

# === CONFIG ===
KERNEL_VER="6.12"                # Major.minor kernel version
TARGET_DIR="qualcommax"          # OpenWrt target name
PATCH_NAME="999-bbrv3.patch"     # Patch filename

get_sources() {
  git config --global user.name "OpenWrt Builder"
  git config --global user.email "buster-openwrt@ovvo.uk"

  echo "[CLONE] Fetching OpenWrt source..."
  git clone $BUILD_REPO --single-branch -b $GITHUB_REF_NAME openwrt

  cd openwrt
  ./scripts/feeds update -a
  ./scripts/feeds install -a
  cd -

  echo "[PATCH] Fetching BBRv3 kernel patch..."
  # Create patch directory inside OpenWrt tree
  PATCH_DIR="openwrt/target/linux/${TARGET_DIR}/patches-${KERNEL_VER}"
  mkdir -p "$PATCH_DIR"

  # Fetch BBRv3 patch from Google repo (adjust commit/tag if needed)
  TMPDIR=$(mktemp -d)
  git clone -b v3 https://github.com/google/bbr.git "$TMPDIR/bbr"
  cd "$TMPDIR/bbr"

  # Generate patch for tcp_bbr.c and related changes
  # NOTE: You may need to adjust commit range if upstream changes
  git format-patch -1 --stdout > "${PATCH_DIR}/${PATCH_NAME}"

  cd -
  rm -rf "$TMPDIR"

  echo "[PATCH] BBRv3 patch saved to ${PATCH_DIR}/${PATCH_NAME}"
}

echo_version() {
  echo "[=============== openwrt version ===============]"
  cd openwrt && git log -1 && cd -
  echo
  echo "[=============== configs version ===============]"
  cd configs && git log -1 && cd -
}

enable_bbrv3_config() {
  echo "[CONFIG] Enabling BBRv3 in kernel config"
  cat >> "configs/${BUILD_PROFILE}" <<EOF

CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BBR=y
CONFIG_DEFAULT_BBR=y
CONFIG_DEFAULT_TCP_CONG="bbr"
EOF
}

build_firmware() {
  cd openwrt
  cp ${GITHUB_WORKSPACE}/configs/${BUILD_PROFILE} .config
  make defconfig
  make -j$(($(nproc) + 1)) V=s || make -j1 V=sc || exit 1
  cd -
}

package_binaries() {
  local bin_dir="openwrt/bin"
  local tarball="${BUILD_PROFILE}.tar.gz"
  tar -zcvf $tarball -C $bin_dir $(ls $bin_dir -1)
}

package_dl_src() {
  [ -n "$BACKUP_DL_SRC" ] || return 0
  [ $BACKUP_DL_SRC = 1 ] || return 0

  local dl_dir="openwrt/dl"
  local tarball="${BUILD_PROFILE}_dl-src.tar.gz"
  tar -zcvf $tarball -C $dl_dir $(ls $dl_dir -1)
}

# === MAIN ===
get_sources
echo_version
enable_bbrv3_config
build_firmware
package_binaries
package_dl_src
