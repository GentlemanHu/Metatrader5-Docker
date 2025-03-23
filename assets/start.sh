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

# 使用我们的自定义配置脚本 - 避免winecfg弹出
sh /root/configure-wine.sh

# 不再直接使用winecfg
# winecfg

# 添加Wine键盘输入配置
wine reg add "HKEY_CURRENT_USER\\Control Panel\\Input Method" /v "EnableHexNumpad" /t REG_SZ /d "1" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "GrabFullscreen" /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "UseTakeFocus" /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "UseXIM" /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "Decorated" /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "Managed" /t REG_SZ /d "Y" /f

# 设置X11键盘速率
xset r rate 500 15

# 禁用自动重复键 - 避免键盘重复输入问题
xset -r

# 重置X输入设备
xinput list 2>/dev/null | grep -i keyboard | grep -o 'id=[0-9]*' | cut -d= -f2 | while read id; do
  xinput disable $id 2>/dev/null || true
  sleep 0.2
  xinput enable $id 2>/dev/null || true
done