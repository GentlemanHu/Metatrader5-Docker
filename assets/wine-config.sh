#!/bin/sh

# 创建Wine配置目录
export WINEPREFIX=/root/.wine
export WINEARCH=win64
export WINEDEBUG=-all

# 基本配置
winecfg -v win10

# 配置DPI设置
wine reg add "HKEY_CURRENT_USER\\Control Panel\\Desktop" /v LogPixels /t REG_DWORD /d 96 /f

# 配置输入设置（添加一些关键注册表设置）
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\Drivers" /v Audio /t REG_SZ /d "alsa" /f
wine reg add "HKEY_CURRENT_USER\\Control Panel\\Input Method" /v "EnableHexNumpad" /t REG_SZ /d "1" /f

# 配置窗口管理
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v Managed /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v Decorated /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v UseXVidMode /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v UseTakeFocus /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v DXGrab /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v UseXIM /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v ClientSideWithRender /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver" /v UseDXGrab /t REG_SZ /d "Y" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\Direct3D" /v DirectDrawRenderer /t REG_SZ /d "opengl" /f

# 禁用自动安装Mono和Gecko（加速启动）
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides" /v mscoree /t REG_SZ /d "" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides" /v mshtml /t REG_SZ /d "" /f

# 配置控制台
wine reg add "HKEY_CURRENT_USER\\Console" /v FaceName /t REG_SZ /d "Lucida Console" /f
wine reg add "HKEY_CURRENT_USER\\Console" /v FontFamily /t REG_DWORD /d 0x00000036 /f
wine reg add "HKEY_CURRENT_USER\\Console" /v FontSize /t REG_DWORD /d 0x000e0000 /f
wine reg add "HKEY_CURRENT_USER\\Console" /v FontWeight /t REG_DWORD /d 0x00000190 /f

# 设置环境变量
wine reg add "HKEY_CURRENT_USER\\Environment" /v PATH /t REG_SZ /d "C:\\windows\\system32;C:\\windows;C:\\windows\\system32\\wbem" /f

# 配置光标闪烁率
wine reg add "HKEY_CURRENT_USER\\Control Panel\\Desktop" /v CursorBlinkRate /t REG_SZ /d "530" /f

# 配置IME支持
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\WineIME" /v "Active" /t REG_SZ /d "Y" /f

# 关闭DirectX测试，避免错误
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\Direct3D" /v DirectDrawRenderer /t REG_SZ /d "gdi" /f
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\Direct3D" /v UseGLSL /t REG_SZ /d "disabled" /f

# 复制DLL和字体
echo "配置完成"
