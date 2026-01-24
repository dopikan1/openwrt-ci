#!/bin/bash

# 移除要替换的包
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns

# MosDNS
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns
git clone --depth=1 https://github.com/dopikan1/nf_deaf-openwrt.git package/kernel/nf_deaf


./scripts/feeds update -a
./scripts/feeds install -a
