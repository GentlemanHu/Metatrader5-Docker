# 第一阶段: 构建st终端
FROM alpine:3.20.0 AS st-builder

RUN apk add --no-cache make gcc git freetype-dev \
            fontconfig-dev musl-dev xproto libx11-dev \
            libxft-dev libxext-dev
RUN git clone https://github.com/DenisKramer/st.git /work
WORKDIR /work
RUN make

# 第二阶段: 构建Xdummy
FROM alpine:3.20.0 AS xdummy-builder

RUN apk add --no-cache make gcc freetype-dev \
            fontconfig-dev musl-dev xproto libx11-dev \
            libxft-dev libxext-dev avahi-libs libcrypto3 libssl3 libvncserver libx11 libxdamage libxext libxfixes libxi libxinerama libxrandr libxtst musl samba-winbind 
RUN apk add --no-cache linux-headers
RUN apk add x11vnc 
RUN Xdummy -install


# 下载并准备MetaTrader文件
FROM alpine:3.20.0 AS mt5-downloader
RUN apk add --no-cache wget tar
WORKDIR /tmp
# 从GitHub Release下载MetaTrader压缩包
RUN wget -O mt5.tar.gz https://github.com/GentlemanHu/Metatrader5-Docker/releases/download/mt5_portable/mt5.tar.gz && \
    mkdir -p /mt5 && \
    tar -xvf mt5.tar.gz -C /mt5 && \
    rm mt5.tar.gz

# 最终阶段: 组装完整环境 - 使用预构建的PyZMQ镜像
FROM gentlemanhu/pyzmq:latest

# 设置环境变量
USER root
ENV WINEPREFIX="/root/.wine"
ENV WINEARCH="win64"
ENV DISPLAY=":0"
ENV USER="root"
# 注意：在生产环境中应使用Docker secrets或环境变量注入而不是硬编码密码
ENV PASSWORD="root"

# 基本初始化和管理工具
RUN apk --no-cache add supervisor sudo wget \
    && echo "$USER:$PASSWORD" | /usr/sbin/chpasswd \
    && rm -rf /apk /tmp/* /var/cache/apk/*

# 安装X11服务器和虚拟设备
RUN apk add --no-cache xorg-server xf86-video-dummy \
    && apk add libcrypto3 libssl3 --no-cache \
    && apk add x11vnc --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ \
    && rm -rf /apk /tmp/* /var/cache/apk/*
COPY --from=xdummy-builder /usr/bin/Xdummy.so /usr/bin/Xdummy.so
COPY assets/xorg.conf /etc/X11/xorg.conf
COPY assets/xorg.conf.d /etc/X11/xorg.conf.d

# 配置初始化
COPY assets/supervisord.conf /etc/supervisord.conf

# Openbox窗口管理器
RUN apk --no-cache add openbox \
    && rm -rf /apk /tmp/* /var/cache/apk/*
COPY assets/openbox/mayday/mayday-arc /usr/share/themes/mayday-arc
COPY assets/openbox/mayday/mayday-arc-dark /usr/share/themes/mayday-arc-dark
COPY assets/openbox/mayday/mayday-grey /usr/share/themes/mayday-grey
COPY assets/openbox/mayday/mayday-plane /usr/share/themes/mayday-plane
COPY assets/openbox/mayday/thesis /usr/share/themes/thesis
COPY assets/openbox/rc.xml /etc/xdg/openbox/rc.xml
COPY assets/openbox/menu.xml /etc/xdg/openbox/menu.xml
COPY assets/openbox/autostart /etc/xdg/openbox/autostart
RUN chmod +x /etc/xdg/openbox/autostart

# 复制Metatrader基本目录结构
COPY Metatrader /root/Metatrader

# 仅替换Metatrader中的EXE文件
COPY --from=mt5-downloader /mt5/terminal64.exe /root/Metatrader/
COPY --from=mt5-downloader /mt5/MetaEditor64.exe /root/Metatrader/
COPY --from=mt5-downloader /mt5/metatester64.exe /root/Metatrader/
COPY --from=mt5-downloader /mt5/uninstall.exe /root/Metatrader/
# 登录管理器
RUN apk --no-cache add slim consolekit \
    && rm -rf /apk /tmp/* /var/cache/apk/*
RUN /usr/bin/dbus-uuidgen --ensure=/etc/machine-id
COPY assets/slim/slim.conf /etc/slim.conf
COPY assets/slim/alpinelinux /usr/share/slim/themes/alpinelinux

# 安装系统字体
RUN apk add --no-cache font-noto \
    && rm -rf /apk /tmp/* /var/cache/apk/*
COPY assets/fonts.conf /etc/fonts/fonts.conf

# 安装st终端
RUN apk add --no-cache freetype fontconfig xproto libx11 libxft libxext ncurses \
    && rm -rf /apk /tmp/* /var/cache/apk/*
COPY --from=st-builder /work/st /usr/bin/st
COPY --from=st-builder /work/st.info /etc/st/st.info
RUN tic -sx /etc/st/st.info

# 其他资源
RUN apk add --no-cache xset \
    && rm -rf /apk /tmp/* /var/cache/apk/*
COPY assets/xinit/Xresources /etc/X11/Xresources
COPY assets/xinit/xinitrc.d /etc/X11/xinit/xinitrc.d
COPY assets/xinit/Xsession /etc/X11/xinit/Xsession
RUN chmod +x /etc/X11/xinit/Xsession /etc/X11/xinit/xinitrc.d/*.sh

COPY assets/x11vnc-session.sh /root/x11vnc-session.sh
COPY assets/start.sh /root/start.sh
COPY assets/dbus-setup.sh /root/dbus-setup.sh

# 设置脚本权限
RUN chmod +x /root/*.sh

# 安装Wine和X11输入相关包
RUN apk update && apk add --no-cache \
    samba-winbind \
    wine \
    xset \
    setxkbmap \
    libxkbcommon \
    xkeyboard-config \
    dbus-x11 \
    mesa-gl \
    mesa-dri-gallium \
    libinput \
    xf86-input-evdev \
    xf86-input-libinput

WORKDIR /root/
EXPOSE 5900 15555 15556 15557 15558
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]