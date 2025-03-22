# 第一阶段: 构建pyzmq环境 (替代ejtrader/pyzmq:dev)
FROM alpine:3.20.0 AS pyzmq-builder

# 设置基本环境变量
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LANG=C.UTF-8

# 安装基础依赖
RUN set -eux; \
    apk add --no-cache \
        ca-certificates \
        wget \
        gcc \
        g++ \
        libc-dev \
        make \
        openssl-dev \
        zlib-dev \
        libffi-dev

# 设置Python GPG密钥和版本
ENV GPG_KEY=0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
ENV PYTHON_VERSION=3.7.10

# 下载并安装Python
RUN set -ex && \
    wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz" && \
    mkdir -p /usr/src/python && \
    tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz && \
    rm python.tar.xz && \
    cd /usr/src/python && \
    ./configure \
        --enable-shared \
        --enable-optimizations && \
    make -j$(nproc) && \
    make install && \
    rm -rf /usr/src/python

# 创建必要的链接
RUN cd /usr/local/bin && \
    ln -s python3 python && \
    ln -s pip3 pip

# 设置pip版本和下载URL
ENV PYTHON_PIP_VERSION=21.0.1
ENV PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/29f37dbe6b3842ccd52d61816a3044173962ebeb/public/get-pip.py
ENV PYTHON_GET_PIP_SHA256=e03eb8a33d3b441ff484c56a436ff10680479d4bd14e59268e67977ed40904de

# 下载并安装pip
RUN set -ex; \
    wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
    echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum -c -; \
    python get-pip.py \
        --disable-pip-version-check \
        --no-cache-dir \
        "pip==$PYTHON_PIP_VERSION" ; \
    pip --version; \
    rm -f get-pip.py

# 安装ZeroMQ依赖和pyzmq
RUN apk add --no-cache zeromq zeromq-dev && \
    pip install --no-cache-dir pyzmq

# 第二阶段: 构建st终端
FROM alpine:3.20.0 AS st-builder

RUN apk add --no-cache make gcc git freetype-dev \
            fontconfig-dev musl-dev xproto libx11-dev \
            libxft-dev libxext-dev
RUN git clone https://github.com/DenisKramer/st.git /work
WORKDIR /work
RUN make

# 第三阶段: 构建Xdummy
FROM alpine:3.20.0 AS xdummy-builder

RUN apk add --no-cache make gcc freetype-dev \
            fontconfig-dev musl-dev xproto libx11-dev \
            libxft-dev libxext-dev avahi-libs libcrypto3 libssl3 libvncserver libx11 libxdamage libxext libxfixes libxi libxinerama libxrandr libxtst musl samba-winbind 
RUN apk add --no-cache linux-headers
RUN apk add x11vnc 
RUN Xdummy -install

# 最终阶段: 组装完整环境
FROM alpine:3.20.0

# 复制Python环境
COPY --from=pyzmq-builder /usr/local /usr/local

# 设置环境变量
USER root
ENV WINEPREFIX=/root/.wine
ENV WINEARCH=win64
ENV DISPLAY :0
ENV USER=root
ENV PASSWORD=root
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LANG=C.UTF-8

# 基本初始化和管理工具
RUN apk --no-cache add supervisor sudo wget \
    && echo "$USER:$PASSWORD" | /usr/sbin/chpasswd \
    && rm -rf /apk /tmp/* /var/cache/apk/*

# 安装X11服务器和虚拟设备
RUN apk add --no-cache xorg-server xf86-video-dummy \
    && apk add libressl3.1-libcrypto --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/main/ \
    && apk add libressl3.1-libssl --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/main/ \
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
COPY Metatrader /root/Metatrader

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

COPY assets/x11vnc-session.sh /root/x11vnc-session.sh
COPY assets/start.sh /root/start.sh

# 安装Wine
RUN apk update && apk add samba-winbind wine && ln -s /usr/bin/wine64 /usr/bin/wine

# 添加ZeroMQ运行库依赖 (这些在pyzmq-builder阶段已安装，但最终镜像也需要)
RUN apk add --no-cache zeromq

WORKDIR /root/
EXPOSE 5900 15555 15556 15557 15558
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]