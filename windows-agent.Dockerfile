# syntax = docker/dockerfile:1
# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2022

# renovate: datasource=github-tags depName=woodpecker-ci/woodpecker
ARG WOODPECKER_AGENT_VERSION=v3.0.1
ARG WOODPECKER_AGENT_VERSION_SHA256=d4ef8e2fa94281bc1e369786030fe7d5afa70fff98ec613d60e4c795bfd8ac8b

LABEL maintainer="OpenCloud.eu Team <devops@opencloud.eu>" `
      name="opencloudeu/woodpecker-windows-agent" `
      vendor="OpenCloud GmbH" `
      source="https://github.com/opencloud-eu/containers-woodpecker-windows"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

USER ContainerAdministrator

# Install Woodpecker Windows Agent
RUN mkdir C:\etc\ssl\certs, C:\etc\woodpecker; `
    Invoke-WebRequest -Uri "https://github.com/woodpecker-ci/woodpecker/releases/download/$env:WOODPECKER_AGENT_VERSION/woodpecker-agent_windows_amd64.zip" -OutFile "woodpecker-agent.zip" ; `
    Expand-Archive -Path "woodpecker-agent.zip" -DestinationPath "C:\bin" ; `
    $actual = (Get-FileHash -Algorithm SHA256 "woodpecker-agent.zip").Hash.ToLower(); `
    if ($actual -ne $env:WOODPECKER_AGENT_VERSION_SHA256) { throw "SHA256 mismatch" } ; `
    Remove-Item "woodpecker-agent.zip"

# Internal setting do NOT change! Signals that woodpecker is running inside a container
ENV GODEBUG=netdns=go `
    WOODPECKER_IN_CONTAINER=true

EXPOSE 3000

HEALTHCHECK CMD ["/bin/woodpecker-agent", "ping"]
ENTRYPOINT ["/bin/woodpecker-agent"]
