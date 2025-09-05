# syntax = docker/dockerfile:1
# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Woodpecker plugin-git https://github.com/woodpecker-ci/plugin-git
ARG PLUGIN_VERSION=2.6.5 `
    PLUGIN_VERSION_SHA256=23fd58af7a0e90c81436218d407a255ac686bb1b91a1d2dbe62e43a8acd3fdbc

LABEL maintainer="OpenCloud.eu Team <devops@opencloud.eu>" `
      name="opencloudeu/woodpecker-windows-git-plugin" `
      vendor="OpenCloud GmbH" `
      source="https://github.com/opencloud-eu/containers-woodpecker-windows"

# Install Woodpecker git-plugin
RUN powershell -Command "New-item -type directory C:\bin ; `
    Invoke-WebRequest -OutFile C:\bin\plugin-git.exe `
     -Uri https://github.com/woodpecker-ci/plugin-git/releases/download/$env:PLUGIN_VERSION/windows-amd64_plugin-git.exe ; `
    # check digest
    $actual=(Get-FileHash -Algorithm SHA256 C:\bin\plugin-git.exe).Hash.ToLower(); `
    if ($actual -ne $env:PLUGIN_VERSION_SHA256) { throw 'SHA256 mismatch' } ; `
    # add to path for usage with custom entrypoints
    $env:PATH += ';C:\bin'; `
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH,[EnvironmentVariableTarget]::Machine)"

USER ContainerUser
ENV GODEBUG=netdns=go
WORKDIR C:\woodpecker
ENTRYPOINT ["/bin/plugin-git.exe"]
