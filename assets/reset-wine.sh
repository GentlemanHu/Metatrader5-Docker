#!/bin/sh

# 此脚本用于完全重置Wine设置
# 在键盘问题持续存在时运行

echo "正在重置Wine配置..."

# 停止相关进程
supervisorctl stop metatrader || true
killall -9 wine wineserver || true
sleep 2

# 删除现有Wine配置
rm -rf /root/.wine
rm -rf /tmp/.wine-*

# 重新创建环境
export WINEPREFIX=/root/.wine
export WINEARCH=win64
export WINEDEBUG=-all
export DISPLAY=:0

# 创建新的Wine配置
winecfg -v win10

# 允许Windows控制键盘
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v GrabKeyboard /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v GrabFullscreen /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v DXGrab /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v UseXRandR /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v UseTakeFocus /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v Managed /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v Decorated /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v UseXIM /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Control Panel\\Input Method" /v "EnableHexNumpad" /t REG_SZ /d "1" /f

# 配置其他选项
wine regedit /E /tmp/tmp_usb.reg "HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\WUSB\\Parameters"
wine reg add "HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\WUSB\\Parameters" /v "RestrictDTM" /t REG_DWORD /d 0 /f

sleep 3
echo "Wine配置重置完成"
echo "请运行 'supervisorctl restart metatrader' 以重启MT5"
