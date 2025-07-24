# syntax = docker/dockerfile:1
# escape=`

FROM opencloud-eu/woodpecker-windows-busybox:latest

# Git installer https://github.com/git-for-windows/git
ARG GIT_VERSION=2.50.1 `
    GIT_VERSION_SHA256=9131f40e26985205432a1aa8583b3a90b5a64f3c6cc9324b2b63f05cb3448222

LABEL maintainer="OpenCloud.eu Team <devops@opencloud.eu>" `
      name="opencloud-eu/woodpecker-windows-git" `
      vendor="OpenCloud GmbH" `
      source="https://github.com/opencloud-eu/containers-woodpecker-windows"

SHELL ["cmd", "/S", "/C"]

# Install Git
RUN curl -fSsLo git.tar.bz2 https://github.com/git-for-windows/git/releases/download/v%GIT_VERSION%.windows.1/Git-%GIT_VERSION%-64-bit.tar.bz2 && `
    /bin/echo "%GIT_VERSION_SHA256% git.tar.bz2" > SHA256SUM && `
    /bin/sha256sum -c SHA256SUM && `
    /bin/mkdir /git && `
    /bin/tar -xf git.tar.bz2 -C /git && `
    /bin/rm -f git.tar.bz2 SHA256SUM

# Set System path
RUN setx /m PATH "C:\\git\\cmd;C:\\git\\mingw64\\bin;C:\\git\\usr\\bin;%path%"

USER ContainerUser

SHELL ["bash.exe", "-c"]
