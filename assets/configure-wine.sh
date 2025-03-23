#!/bin/sh

# 这个脚本用于配置Wine，以便正确显示MetaTrader窗口
# 它只需要在第一次启动时执行一次

# 设置Wine环境变量
export WINEPREFIX=/root/.wine
export WINEARCH=win64
export DISPLAY=:0

# 停止所有Wine进程
wineserver -k || true
sleep 2

# 创建Wine注册表文件
cat > /tmp/wine_config.reg << EOL
REGEDIT4

[HKEY_CURRENT_USER\\Software\\Wine\\Explorer]
"Desktop"="Default"

[HKEY_CURRENT_USER\\Software\\Wine\\Explorer\\Desktops]
"Default"="1600x1200"

[HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver]
"Decorated"="Y"
"Managed"="Y"
"GrabFullscreen"="N"
"DXGrab"="N"
"UseXIM"="Y"
"ClientSideWithRender"="Y"
"UseTakeFocus"="Y"

[HKEY_CURRENT_USER\\Control Panel\\Input Method]
"EnableHexNumpad"="1"

[HKEY_CURRENT_USER\\Control Panel\\Keyboard]
"KeyboardDelay"="1"
"KeyboardSpeed"="0.5"

[HKEY_CURRENT_USER\\Control Panel\\Accessibility\\Keyboard Response]
"AutoRepeatDelay"="1000"
"AutoRepeatRate"="500"
"BounceTime"="0"
"DelayBeforeAcceptance"="1000"

[HKEY_CURRENT_USER\\Software\\Wine\\DirectInput]
"MouseWarpOverride"="disable"
EOL

# 导入注册表配置
wine regedit /tmp/wine_config.reg

# 清理
rm -f /tmp/wine_config.reg

# 确认导入成功
echo "Wine 配置完成"
