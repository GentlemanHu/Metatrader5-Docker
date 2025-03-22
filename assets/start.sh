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

# 添加Wine键盘输入配置
wine reg add "HKEY_CURRENT_USER\\Control Panel\\Input Method" /v "EnableHexNumpad" /t REG_SZ /d "1" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "GrabFullscreen" /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "UseTakeFocus" /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "UseXIM" /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "Decorated" /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "Managed" /t REG_SZ /d "Y" /f

# 配置X11输入设置
xset r rate 200 25