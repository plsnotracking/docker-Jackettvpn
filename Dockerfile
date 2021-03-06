# Jackett and OpenVPN, JackettVPN

FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

WORKDIR /opt

RUN usermod -u 99 nobody

# Make directories
RUN mkdir -p /blackhole /config/Jackett /etc/jackett

# Update, upgrade and install required packages
RUN apt update \
    && apt -y upgrade \
    && apt -y install --no-install-recommends \
    iproute2 \
    openresolv \
    apt-transport-https \
    wireguard-tools \
    openvpn \
    ca-certificates \
    wget \
    curl \
    gnupg \
    sed \
    curl \
    moreutils \
    net-tools \
    dos2unix \
    kmod \
    iptables \
    ipcalc \
    grep \
    libcurl4 \
    liblttng-ust0 \
    libkrb5-3 \
    zlib1g \
    iputils-ping \
    jq \
    libicu60 \
    grepcidr \
    && apt-get clean \
    && apt -y autoremove \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

# Install Jackett
RUN jackett_latest=$(curl --silent "https://api.github.com/repos/Jackett/Jackett/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
    && curl -o /opt/Jackett.Binaries.LinuxAMDx64.tar.gz -L https://github.com/Jackett/Jackett/releases/download/$jackett_latest/Jackett.Binaries.LinuxAMDx64.tar.gz \
    && tar -xzf /opt/Jackett.Binaries.LinuxAMDx64.tar.gz \
    && rm /opt/Jackett.Binaries.LinuxAMDx64.tar.gz

VOLUME /blackhole /config

ADD openvpn/ /etc/openvpn/
ADD jackett/ /etc/jackett/

RUN chmod +x /etc/jackett/*.sh /etc/jackett/*.init /etc/openvpn/*.sh /opt/Jackett/jackett

EXPOSE 9117
CMD ["/bin/bash", "/etc/openvpn/start.sh"]
