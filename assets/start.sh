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
winecfg
wine reg add "HKEY_CURRENT_USER\\Control Panel\\Input Method" /v "EnableHexNumpad" /t REG_SZ /d "1" /f

# 配置X11输入设置
xset r rate 200 25