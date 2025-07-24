# syntax = docker/dockerfile:1
# escape=`

FROM opencloud-eu/woodpecker-windows-git:latest

# Woodpecker plugin-git https://github.com/woodpecker-ci/plugin-git
ARG PLUGIN_VERSION=2.6.5 `
    PLUGIN_VERSION_SHA256=23fd58af7a0e90c81436218d407a255ac686bb1b91a1d2dbe62e43a8acd3fdbc

LABEL maintainer="OpenCloud.eu Team <devops@opencloud.eu>" `
      name="opencloud-eu/woodpecker-windows-git-plugin" `
      vendor="OpenCloud GmbH" `
      source="https://github.com/opencloud-eu/containers-woodpecker-windows"

SHELL ["cmd", "/S", "/C"]

# Install plugin
RUN curl -fSsLo /bin/plugin-git.exe https://github.com/woodpecker-ci/plugin-git/releases/download/%PLUGIN_VERSION%/windows-amd64_plugin-git.exe && `
    /bin/echo "%PLUGIN_VERSION_SHA256% /bin/plugin-git.exe" > SHA256SUM && `
    /bin/sha256sum -c SHA256SUM && `
    /bin/rm -f SHA256SUM

USER ContainerUser

# Install plugin
ENV GODEBUG=netdns=go

WORKDIR C:\woodpecker

SHELL ["bash.exe", "-c"]

ENTRYPOINT ["plugin-git.exe"]
