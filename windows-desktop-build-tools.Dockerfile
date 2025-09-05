# syntax = docker/dockerfile:1
# escape=`

FROM opencloudeu/woodpecker-windows-chocolatey:latest

LABEL maintainer="OpenCloud.eu Team <devops@opencloud.eu>" `
      name="opencloudeu/woodpecker-windows-desktop-build-tools" `
      vendor="OpenCloud GmbH" `
      source="https://github.com/opencloud-eu/containers-woodpecker-windows"
      # Adapted from https://invent.kde.org/sysadmin/ci-images/-/blob/809743239630856af833727364381569d3aa5384/windows-msvc2022/Dockerfile

# Restore the default Windows shell for correct batch processing with vs installer
SHELL ["cmd", "/S", "/C"]

# Visual Studio 2022 Build Tools (https://learn.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2022)
RUN `
    # Download the Build Tools bootstrapper.
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe &&`
    # Install required Build Tools, excluding workloads and components with known issues
    (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
        --noUpdateInstaller --channeluri https://aka.ms/vs/17/release/channel `
        --installchanneluri https://aka.ms/vs/17/release/channel `
        --add Microsoft.VisualStudio.Component.VC.ATL `
        --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
        --add Microsoft.VisualStudio.Component.VC.CoreBuildTools `
        --add Microsoft.VisualStudio.Component.VC.CLI.Support `
        --add Microsoft.VisualStudio.Component.Windows10SDK `
        --add Microsoft.VisualStudio.Component.Windows10SDK.20348 `
        --add Microsoft.VisualStudio.Component.Windows11SDK `
        --add Microsoft.VisualStudio.Component.Windows11SDK.26100 `
        --add Microsoft.VisualStudio.Component.VC.ASAN `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
        --remove Microsoft.VisualStudio.Component.Windows81SDK || IF "%ERRORLEVEL%"=="3010" EXIT 0) `
    `
    # Cleanup
    && del /q vs_buildtools.exe `
    && powershell -Command "Remove-Item @( `
     'C:\Windows\Temp\*', `
     'C:\Windows\Prefetch\*', `
     'C:\Documents and Settings\*\Local Settings\temp\*', `
     'C:\Users\*\Appdata\Local\Temp\*' ) `
    -Force -Recurse -Verbose -ErrorAction SilentlyContinue"

# Reset CMD and SHELL to powershell core (copied from base image)
SHELL ["pwsh", "-Command", "Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; $PSNativeCommandUseErrorActionPreference = $true;"]
CMD ["pwsh" ,"-NoExit", "-Command", "Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; $PSNativeCommandUseErrorActionPreference = $true;"]

RUN `
    # Use Chocolatey to install Git, Python 3, 7zip and MSYS2
    choco install -y git 7zip; `
    # Pin Python3 to 3.11 because QtWebEngine is not compatible with 3.12 yet
    choco install -y python3 --version=3.11.6; `
    choco install -y msys2 --params '/NoUpdate /InstallDir:C:\MSys2'; `
    Remove-Item @( 'C:\*Recycle.Bin\S-*' ) -Force -Recurse -Verbose;

RUN `
    # CI (Tooling and Notary Service) scripts need a couple of Python modules, so install those as well
    # * ci-notary-service client scripts need paramiko, pyyaml, requests
    # We have to do this as a separate invocation because changes to the system wide PATH definition don't take effect in Powershell until it is relaunched'
    pip install lxml pyyaml python-gitlab packaging paramiko requests s3cmd; `
    Remove-Item @( 'C:\Windows\Temp\*', `
     'C:\Windows\Prefetch\*', `
     'C:\Documents and Settings\*\Local Settings\temp\*', `
     'C:\Users\*\Appdata\Local\Temp\*' ) -Force -Recurse -Verbose -ErrorAction SilentlyContinue; `
    # Disable symlinks in git (https://git-scm.com/docs/git-config#Documentation/git-config.txt-coresymlinks)
    git config --system core.symlinks false ; `
    # Set everything as Safe Directory to avoid git warnings in CI with custom user/entrypoint
    git config --global --add safe.directory "*";
