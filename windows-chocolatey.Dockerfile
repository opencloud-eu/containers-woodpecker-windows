# syntax = docker/dockerfile:1
# escape=`

FROM opencloud-eu/woodpecker-windows-git:latest

SHELL ["cmd", "/S", "/C"]

LABEL maintainer="OpenCloud.eu Team <devops@opencloud.eu>" `
      name="opencloud-eu/woodpecker-windows-chocolatey" `
      vendor="OpenCloud GmbH" `
      source="https://github.com/opencloud-eu/containers-woodpecker-windows"

# Install last Chocolatey (https://docs.chocolatey.org/en-us/choco/setup)
RUN powershell -Command `
      "Set-ExecutionPolicy Bypass -Scope Process -Force; `
       [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
       iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" `
    `
    # Configure
    && C:\\ProgramData\\chocolatey\\bin\\choco.exe config set cachelocation C:\\tmp\\cache && `
	   C:\\ProgramData\\chocolatey\\bin\\choco.exe install -y chocolatey-core.extension && `
	   rmdir /S /Q C:\tmp\cache

SHELL ["bash.exe", "-c"]
