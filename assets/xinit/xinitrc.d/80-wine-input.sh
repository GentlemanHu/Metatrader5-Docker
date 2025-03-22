#!/bin/sh

# 配置Wine输入处理
if [ -x /usr/bin/wine ]; then
  # 启用Wine窗口默认焦点
  wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "GrabFullscreen" /t REG_SZ /d "Y" /f

  # 配置输入法支持
  wine reg add "HKEY_CURRENT_USER\\Control Panel\\Input Method" /v "EnableHexNumpad" /t REG_SZ /d "1" /f

  # 启用输入处理
  wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "UseTakeFocus" /t REG_SZ /d "Y" /f
  wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "UseXIM" /t REG_SZ /d "Y" /f
fi
