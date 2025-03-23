#!/bin/sh

# 这个脚本确保会话不会意外终止
# 防止SLiM在会话崩溃后立即重启

# 设置SLiM自动登录
if [ -f /etc/slim.conf ]; then
  # 确保自动登录已启用
  sed -i 's/^#auto_login/auto_login/g' /etc/slim.conf
  sed -i 's/^auto_login.*no/auto_login          yes/g' /etc/slim.conf
fi

# 确保Openbox会话保持运行
while true; do
  # 检查Openbox是否在运行
  if ! pgrep -x openbox >/dev/null; then
    # 如果MetaTrader正在运行，不要做任何事
    if pgrep -f "terminal64.exe" >/dev/null; then
      sleep 5
    else
      # 等待3秒，看是否会自动重启
      sleep 3
      if ! pgrep -x openbox >/dev/null; then
        # 如果还是没有运行，启动它
        openbox &
        sleep 2
      fi
    fi
  fi
  sleep 10
done &
