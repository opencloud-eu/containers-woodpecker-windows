# syntax = docker/dockerfile:1
# escape=`

FROM opencloudeu/woodpecker-windows-chocolatey:latest

# Woodpecker plugin-git https://github.com/woodpecker-ci/plugin-git
ARG PLUGIN_VERSION=2.6.5 `
    PLUGIN_VERSION_SHA256=23fd58af7a0e90c81436218d407a255ac686bb1b91a1d2dbe62e43a8acd3fdbc

LABEL maintainer="OpenCloud.eu Team <devops@opencloud.eu>" `
      name="opencloudeu/woodpecker-windows-git-plugin" `
      vendor="OpenCloud GmbH" `
      source="https://github.com/opencloud-eu/containers-woodpecker-windows"

RUN `
    # Install git with chocolatey
    C:\\ProgramData\\chocolatey\\bin\\choco.exe install -y git `
    # cleanup
    && Remove-Item @( `
     'C:\tmp\cache', `
     'C:\Windows\Temp\*', `
     'C:\Windows\Prefetch\*', `
     'C:\Documents and Settings\*\Local Settings\temp\*', `
     'C:\Users\*\Appdata\Local\Temp\*' ) `
    -Force -Recurse -Verbose -ErrorAction SilentlyContinue `
    New-item -type directory C:\bin ; `
    # Install Woodpecker git-plugin
    Invoke-WebRequest -OutFile "C:\bin\plugin-git.exe" `
     -Uri https://github.com/woodpecker-ci/plugin-git/releases/download/$env:PLUGIN_VERSION/windows-amd64_plugin-git.exe ; `
    # check digest
    $actual=(Get-FileHash -Algorithm SHA256 "C:\bin\plugin-git.exe").Hash.ToLower(); `
    if ($actual -ne $env:PLUGIN_VERSION_SHA256) { throw "SHA256 mismatch" } ; `
    $env:PATH += ';C:\bin'; `
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH,[EnvironmentVariableTarget]::Machine)

USER ContainerUser
ENV GODEBUG=netdns=go
WORKDIR C:\woodpecker
ENTRYPOINT ["plugin-git.exe"]
