# syntax = docker/dockerfile:1
# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["cmd", "/S", "/C"]

LABEL maintainer="OpenCloud.eu Team <devops@opencloud.eu>" `
      name="opencloudeu/woodpecker-windows-chocolatey" `
      vendor="OpenCloud GmbH" `
      source="https://github.com/opencloud-eu/containers-woodpecker-windows"

# Install latest Chocolatey (https://docs.chocolatey.org/en-us/choco/setup)
RUN powershell -Command `
     "Set-ExecutionPolicy Bypass -Scope Process -Force; `
      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
      iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" `
    && C:\\ProgramData\\chocolatey\\bin\\choco.exe config set cachelocation C:\\tmp\\cache `
    && C:\\ProgramData\\chocolatey\\bin\\choco.exe feature disable --name=showDownloadProgress `
    # install extensions and powershell core
    && C:\\ProgramData\\chocolatey\\bin\\choco.exe install -y chocolatey-core.extension powershell-core `
    # cleanup
    && powershell -Command "Remove-Item @(`
     'C:\tmp\cache', `
     'C:\Windows\Temp\*', `
     'C:\Windows\Prefetch\*', `
     'C:\Documents and Settings\*\Local Settings\temp\*', `
     'C:\Users\*\Appdata\Local\Temp\*') `
    -Force -Recurse -Verbose -ErrorAction SilentlyContinue"

SHELL ["pwsh", "-Command", "Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; $PSNativeCommandUseErrorActionPreference = $true;"]
CMD ["pwsh" ,"-NoExit", "-Command", "Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; $PSNativeCommandUseErrorActionPreference = $true;"]
