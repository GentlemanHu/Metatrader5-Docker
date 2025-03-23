#!/bin/sh

# 禁用X11自动重复(关键修复)
xset -r

# 设置合理的按键重复率
# 第一个参数是延迟(ms)，第二个是重复率(次/秒)
xset r rate 500 10

# 重置输入设备
xinput list | grep -i keyboard | grep -o 'id=[0-9]*' | cut -d= -f2 | while read id; do
  xinput disable $id
  sleep 0.1
  xinput enable $id
done

# 禁用Wine键盘自动重复和快速输入处理
if [ -d "$WINEPREFIX" ]; then
  # 设置键盘输入延迟以避免重复输入
  wine reg add "HKEY_CURRENT_USER\\Control Panel\\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "1" /f
  wine reg add "HKEY_CURRENT_USER\\Control Panel\\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "0.2" /f
  
  # 配置输入处理
  wine reg add "HKEY_CURRENT_USER\\Control Panel\\Accessibility\\Keyboard Response" /v "AutoRepeatDelay" /t REG_SZ /d "1000" /f
  wine reg add "HKEY_CURRENT_USER\\Control Panel\\Accessibility\\Keyboard Response" /v "AutoRepeatRate" /t REG_SZ /d "500" /f
  wine reg add "HKEY_CURRENT_USER\\Control Panel\\Accessibility\\Keyboard Response" /v "BounceTime" /t REG_SZ /d "0" /f
  wine reg add "HKEY_CURRENT_USER\\Control Panel\\Accessibility\\Keyboard Response" /v "DelayBeforeAcceptance" /t REG_SZ /d "1000" /f
  
  # 配置Wine输入法
  wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "InputStyle" /t REG_SZ /d "root" /f
fi
