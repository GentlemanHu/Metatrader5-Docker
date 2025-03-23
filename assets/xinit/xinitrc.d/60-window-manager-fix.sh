#!/bin/sh

# 确保窗口管理器正确处理Wine窗口
if [ -d "$WINEPREFIX" ]; then
  # 修复窗口管理冲突 - 关键修复
  wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "Managed" /t REG_SZ /d "Y" /f
  wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "Decorated" /t REG_SZ /d "Y" /f
  wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "DXGrab" /t REG_SZ /d "N" /f
  wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "GrabFullscreen" /t REG_SZ /d "N" /f
  wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v "UseTakeFocus" /t REG_SZ /d "Y" /f
  
  # 禁用捕获鼠标 - 解决鼠标被锁定的问题
  wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\DirectInput" /v "MouseWarpOverride" /t REG_SZ /d "disable" /f
  
  # 使用窗口模式，而不是全屏模式
  wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\Explorer" /v "DesktopMode" /t REG_SZ /d "N" /f
  wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\Explorer\\Desktops" /v "Default" /t REG_SZ /d "" /f
fi

# 确保OpenBox不会挂起或锁定
if pidof openbox >/dev/null; then
  # 重置OpenBox
  openbox --reconfigure &
fi
