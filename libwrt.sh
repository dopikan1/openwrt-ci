rm -rf package/emortal/luci-app-athena-led
git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led
chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led package/luci-app-athena-led/root/usr/sbin/athena-led

# 移除要替换的包
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/luci/applications/luci-app-natmapt
rm -rf feeds/packages/net/openwrt-natmapt

# MosDNS
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns
git clone --depth=1 https://github.com/dopikan1/nf_deaf-openwrt.git package/kernel/nf_deaf
git clone --depth=1 https://github.com/muink/luci-app-natmapt package/luci-app-natmapt
git clone --depth=1 https://github.com/muink/openwrt-natmapt package/openwrt-natmapt
git clone --depth=1 https://github.com/muink/openwrt-stuntman package/openwrt-stuntman
git clone --depth=1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

mkdir -p package/luci-app-diskman && \
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile -O package/luci-app-diskman/Makefile
mkdir -p package/parted && \
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O package/parted/Makefile




./scripts/feeds update -a
./scripts/feeds install -a
