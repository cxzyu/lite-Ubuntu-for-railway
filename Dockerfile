# Railway 部署：Ubuntu 24.04 轻量基础系统 + 公网网页终端
# 特点：无桌面环境、无 SSH、最小化安装
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV LANG=C.UTF-8

# 最小化安装常用工具 + ttyd（网页版终端，浏览器里直接敲命令）
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        git \
        vim-tiny \
        unzip \
        zip \
        htop \
        procps \
        tzdata \
        ttyd \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

# ttyd 就是那个常驻进程，替掉原来的 sleep，容器不会退出
# -W  允许写入（能敲命令）
# -c  基础认证账号:密码，公网暴露 shell 必须设
# Railway 会自动注入 $PORT，本地跑时默认 7681
CMD ["sh", "-c", "exec ttyd -W -p ${PORT:-7681} -c ${TTYD_USER:-admin}:${TTYD_PASS:-changeme} bash"]
