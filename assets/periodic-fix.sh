#!/bin/sh

# 这个脚本每分钟运行一次，修复可能出现的输入和窗口问题
while true; do
  # 重置X11输入设置
  xset -r
  xset r rate 500 10

  # 重置X11输入设备
  xinput list 2>/dev/null | grep -i keyboard | grep -o 'id=[0-9]*' | cut -d= -f2 | while read id; do
    xinput disable $id 2>/dev/null
    sleep 0.2
    xinput enable $id 2>/dev/null
  done
  
  # 检查Wine窗口是否有问题(无法点击)
  if [ -n "$(pgrep -f terminal64.exe)" ]; then
    # 激活Wine窗口焦点
    WINEDEBUG=-all wine winedbg --command "info win" | grep -i terminal | head -1 | 
      awk '{print $1}' | xargs -I{} wine user32.dll SetForegroundWindow {} >/dev/null 2>&1 || true
      
    # 尝试解锁鼠标
    wine explorer /desktop=shell,1024x768 >/dev/null 2>&1 || true
    sleep 0.1
    wine explorer /desktop= >/dev/null 2>&1 || true
  fi
  
  # 修复OpenBox窗口管理
  if pidof openbox >/dev/null; then
    # 重新配置OpenBox
    openbox --reconfigure >/dev/null 2>&1 || true
  fi
  
  # 每60秒运行一次
  sleep 60
done
