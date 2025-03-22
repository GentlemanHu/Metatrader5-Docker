#!/bin/sh

# 在用户会话开始时自动启动MetaTrader
# 此脚本由X会话启动时自动执行

echo "准备启动MetaTrader..."

# 等待Openbox完全启动
sleep 3

# 设置Wine环境变量
export WINEPREFIX=/root/.wine
export WINEARCH=win64
export WINEDEBUG=-all
export WINEDLLOVERRIDES="mscoree,mshtml="
export DISPLAY=:0

# 在后台启动MetaTrader
( cd /root/Metatrader && wine terminal64.exe /portable ) &

echo "MetaTrader已启动"
