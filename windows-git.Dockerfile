# syntax = docker/dockerfile:1
# escape=`

FROM opencloudeu/woodpecker-windows-chocolatey:latest

LABEL maintainer="OpenCloud.eu Team <devops@opencloud.eu>" `
      name="opencloudeu/woodpecker-windows-git" `
      vendor="OpenCloud GmbH" `
      source="https://github.com/opencloud-eu/containers-woodpecker-windows"

# Install git
RUN C:\\ProgramData\\chocolatey\\bin\\choco.exe install -y git `
    # cleanup
    && Remove-Item @( `
     'C:\tmp\cache', `
     'C:\Windows\Temp\*', `
     'C:\Windows\Prefetch\*', `
     'C:\Documents and Settings\*\Local Settings\temp\*', `
     'C:\Users\*\Appdata\Local\Temp\*' ) `
    -Force -Recurse -Verbose -ErrorAction SilentlyContinue ;`
    # set PATH
    $env:PATH += ';C:\\git\\cmd;C:\\git\\mingw64\\bin;C:\\git\\usr\\bin'; [Environment]::SetEnvironmentVariable('PATH', $env:PATH,[EnvironmentVariableTarget]::Machine)

USER ContainerUser
