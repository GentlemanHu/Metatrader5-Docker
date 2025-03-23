#!/bin/sh

# 这个脚本每分钟运行一次，修复可能出现的输入和窗口问题

# 打印日志标记
echo "[$(date)] 定期修复脚本启动" > /tmp/periodic-fix.log

# 检查是否已经运行 - 避免多个实例
if [ -f /tmp/periodic-fix.pid ]; then
  pid=$(cat /tmp/periodic-fix.pid)
  if kill -0 $pid 2>/dev/null; then
    echo "[$(date)] 定期修复脚本已在运行，pid: $pid" >> /tmp/periodic-fix.log
    exit 0
  fi
fi
echo $$ > /tmp/periodic-fix.pid

# 远离太频繁监控
SLEEP_TIME=300

while true; do
  # 重置X11输入设置
  xset -r
  xset r rate 500 10

  # 检查MetaTrader是否在运行
  if [ -n "$(pgrep -f terminal64.exe)" ]; then
    # 先删除winecfg或wine的多余进程
    pkill -f winecfg || true
    pkill -f 'wine explorer' || true
  fi
  
  # 当前状态日志
  echo "[$(date)] 定期修复运行正常" >> /tmp/periodic-fix.log
  
  # 不要过于频繁运行
  sleep $SLEEP_TIME
done
