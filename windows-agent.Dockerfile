# syntax = docker/dockerfile:1
# escape=`

FROM opencloud-eu/woodpecker-windows-busybox:latest

# Woodpecker Windows Agent https://github.com/woodpecker-ci/woodpecker/tags
ARG WOODPECKER_AGENT_VERSION=v3.0.1 `
    WOODPECKER_AGENT_VERSION_SHA256=d4ef8e2fa94281bc1e369786030fe7d5afa70fff98ec613d60e4c795bfd8ac8b

LABEL maintainer="OpenCloud.eu Team <devops@opencloud.eu>" `
      name="opencloud-eu/woodpecker-windows-agent" `
      vendor="OpenCloud GmbH" `
      source="https://github.com/opencloud-eu/containers-woodpecker-windows"

SHELL ["cmd", "/S", "/C"]

USER ContainerAdministrator

# Install Woodpecker Windows Agent
RUN mkdir C:\etc\ssl\certs `
          C:\etc\woodpecker && `
    curl -fSsLo woodpecker-agent.zip https://github.com/woodpecker-ci/woodpecker/releases/download/%WOODPECKER_AGENT_VERSION%/woodpecker-agent_windows_amd64.zip && `
    /bin/unzip -d /bin woodpecker-agent.zip && `
    /bin/echo "%WOODPECKER_AGENT_VERSION_SHA256% woodpecker-agent.zip" > SHA256SUM && `
    /bin/sha256sum -c SHA256SUM && `
    /bin/rm -f woodpecker-agent.zip SHA256SUM

# Internal setting do NOT change! Signals that woodpecker is running inside a container
ENV GODEBUG=netdns=go `
    WOODPECKER_IN_CONTAINER=true

EXPOSE 3000

HEALTHCHECK CMD ["/bin/woodpecker-agent", "ping"]
ENTRYPOINT ["/bin/woodpecker-agent"]
