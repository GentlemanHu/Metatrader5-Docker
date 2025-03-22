#!/bin/sh

# 创建dbus目录结构
mkdir -p /var/run/dbus
chown -R root:root /var/run/dbus

# 确保machine-id存在
if [ ! -f /etc/machine-id ]; then
  dbus-uuidgen > /etc/machine-id
fi
