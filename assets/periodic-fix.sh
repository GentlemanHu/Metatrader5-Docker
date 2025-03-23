#!/bin/sh

# 该脚本已经被简化，仅保留必要功能

# 说明注释
echo "[$(date)] 简化的日志脚本启动" > /tmp/debug-wine.log

# 避免多个实例运行
if [ -f /tmp/periodic.pid ]; then
  pid=$(cat /tmp/periodic.pid 2>/dev/null)
  if [ -n "$pid" ] && kill -0 $pid 2>/dev/null; then
    echo "[$(date)] 脚本已在运行, 退出" >> /tmp/debug-wine.log
    exit 0
  fi
fi
echo $ > /tmp/periodic.pid

# 仅保持这个脚本运行，不进行其他任何操作
while true; do
  sleep 3600
done
