#!/bin/sh

# 创建dbus目录并设置权限
mkdir -p /var/run/dbus
chown -R root:root /var/run/dbus

# 确保machine-id存在
if [ ! -f /etc/machine-id ]; then
  dbus-uuidgen > /etc/machine-id
fi

# 设置Wine环境变量
export WINEPREFIX=/root/.wine
export WINEARCH=win64

# 配置Wine键盘输入
echo "正在配置Wine键盘设置..."

# 使用增强的Wine配置脚本
sh /root/wine-config.sh

# 确保Wine使用系统环境变量
export WINEDLLOVERRIDES="mscoree,mshtml="

# 配置X11输入设置
xset r rate 200 25