#!/bin/sh
# 这个脚本会在构建时执行，确保所有脚本有执行权限
# 并创建必要的目录结构

chmod +x /root/start.sh
chmod +x /root/x11vnc-session.sh
chmod +x /root/wine-config.sh
chmod +x /root/reset-wine.sh
chmod +x /etc/X11/xinit/xinitrc.d/*.sh

# 创建dbus目录结构
mkdir -p /var/run/dbus
chown -R root:root /var/run/dbus

# 生成machine-id
dbus-uuidgen > /etc/machine-id

# 确保X11目录存在
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix
