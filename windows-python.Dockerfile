# syntax = docker/dockerfile:1
# escape=`

FROM opencloud-eu/woodpecker-windows-vsbuildtools:latest

ARG PYTHON_VERSION=311

LABEL maintainer="OpenCloud.eu Team <devops@opencloud.eu>" `
      name="opencloud-eu/woodpecker-windows-python" `
      vendor="OpenCloud GmbH" `
      source="https://github.com/opencloud-eu/containers-woodpecker-windows"

SHELL ["cmd", "/S", "/C"]

# Install Python
RUN choco install -y python%PYTHON_VERSION% --params "/InstallDir:C:\Python /NoLockdown" && `
    rmdir /S /Q C:\tmp\cache

# Upgrade
RUN python.exe -m pip install --no-cache-dir --upgrade pip && `
    pip install --no-cache-dir --upgrade setuptools

SHELL ["bash.exe", "-c"]
