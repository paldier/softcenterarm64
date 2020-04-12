#!/bin/sh
source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
DIR=$(cd $(dirname $0); pwd)
model=`nvram get productid`
# stop aliddns first
enable=`dbus get aliddns_enable`
if [ "$enable" == "1" ];then
	sh /jffs/softcenter/scripts/aliddns_config.sh stop
fi

# delete some files
rm -rf /jffs/softcenter/init.d/*aliddns.sh

# install
cp -rf /tmp/aliddns/scripts/* /jffs/softcenter/scripts/
cp -rf /tmp/aliddns/webs/* /jffs/softcenter/webs/
cp -rf /tmp/aliddns/res/* /jffs/softcenter/res/
cp -rf /tmp/aliddns/uninstall.sh /jffs/softcenter/scripts/uninstall_aliddns.sh
chmod +x /jffs/softcenter/scripts/aliddns*
chmod +x /jffs/softcenter/init.d/*
if [ "$model" == "GT-AC5300" ] || [ "$model" == "GT-AX11000" ] || [ "$model" == "GT-AC2900" ];then
	continue
elif [ "$model" == "TUF-AX3000" ];then
	sed -i 's/3e030d/3e2902/g;s/91071f/92650F/g;s/680516/D0982C/g;s/cf0a2c/c58813/g;s/700618/74500b/g;s/530412/92650F/g' /jffs/softcenter/webs/Module_aliddns.asp >/dev/null 2>&1
else
	sed -i '/rogcss/d' /jffs/softcenter/webs/Module_aliddns.asp >/dev/null 2>&1
fi
[ ! -L "/jffs/softcenter/init.d/S98Aliddns.sh" ] && ln -sf /jffs/softcenter/scripts/aliddns_config.sh /jffs/softcenter/init.d/S98Aliddns.sh

# 离线安装需要向skipd写入安装信息
dbus set aliddns_version="$(cat $DIR/version)"
dbus set softcenter_module_aliddns_version="$(cat $DIR/version)"
dbus set softcenter_module_aliddns_install="1"
dbus set softcenter_module_aliddns_name="aliddns"
dbus set softcenter_module_aliddns_title="阿里DDNS"
dbus set softcenter_module_aliddns_description="aliddns"

# re-enable aliddns
if [ "$enable" == "1" ];then
	sh /jffs/softcenter/scripts/aliddns_config.sh
fi

# 完成
echo_date 阿里ddns插件安装完毕！
rm -rf /tmp/aliddns* >/dev/null 2>&1
exit 0

