# syntax = docker/dockerfile:1
# escape=`

# Use multi-stage builds to keep the final image small
# First stage: download and verify the Woodpecker agent binary
FROM mcr.microsoft.com/windows/servercore:ltsc2022 as download

# renovate: datasource=github-tags depName=woodpecker-ci/woodpecker
ARG WOODPECKER_AGENT_VERSION=v3.9.0
ARG WOODPECKER_AGENT_VERSION_SHA256=173deab1382b689334296e882e210854c189afa3ab86132460a28a8e0e6d0949

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

USER ContainerAdministrator

# Install Woodpecker Windows Agent
RUN mkdir C:\etc\ssl\certs, C:\etc\woodpecker; `
    Invoke-WebRequest -Uri "https://github.com/woodpecker-ci/woodpecker/releases/download/$env:WOODPECKER_AGENT_VERSION/woodpecker-agent_windows_amd64.zip" -OutFile "woodpecker-agent.zip" ; `
    Expand-Archive -Path "woodpecker-agent.zip" -DestinationPath "C:\bin" ; `
    $actual = (Get-FileHash -Algorithm SHA256 "woodpecker-agent.zip").Hash.ToLower(); `
    if ($actual -ne $env:WOODPECKER_AGENT_VERSION_SHA256) { throw "SHA256 mismatch" }


# Second stage: create the final lightweight image
FROM mcr.microsoft.com/windows/nanoserver:ltsc2022

LABEL maintainer="OpenCloud.eu Team <devops@opencloud.eu>" `
      name="opencloudeu/woodpecker-windows-agent" `
      vendor="OpenCloud GmbH" `
      source="https://github.com/opencloud-eu/containers-woodpecker-windows"

USER ContainerAdministrator

COPY --from=download C:\bin\woodpecker-agent.exe C:\bin\woodpecker-agent.exe

RUN mkdir C:\etc\ssl\certs, C:\etc\woodpecker;

ENV WOODPECKER_IN_CONTAINER=true

EXPOSE 3000

HEALTHCHECK CMD ["/bin/woodpecker-agent", "ping"]
ENTRYPOINT ["/bin/woodpecker-agent"]
