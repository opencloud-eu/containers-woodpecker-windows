Param(
    [Parameter(
        Position=0,
        Mandatory=$false
    )][string]$imageToBuild,
    [Parameter(
        Mandatory=$False
    )][switch]$buildonly
)

### VARS
# team/user name for the registry used to tag the images
$registrypath = "opencloudeu"

# registries to push the images to
$registries = @(
    "docker.io",
    "quay.io"
)

# matrix with file-names target image names and tags, increment tags as needed
# order is important, the images are depending on each other
$matrix = @(
    @{
        name      = "windows-chocolatey"
        imagename = "$registrypath/woodpecker-windows-chocolatey"
        tags      = @(
            "latest",
            "v2.0.0",
            "v2.0",
            "v2"
        )
    },
    @{
        name      = "windows-agent"
        imagename = "$registrypath/woodpecker-windows-agent"
        tags      = @(
            "latest",
            "v3.0.1",
            "v3.0",
            "v3"
        )
    },
    @{
        name      = "windows-git-plugin"
        imagename = "$registrypath/woodpecker-windows-git-plugin"
        tags      = @(
            "latest",
            "v2.0.0",
            "v2.0",
            "v2"
        )
    },
    @{
        name      = "windows-desktop-build-tools"
        imagename = "$registrypath/woodpecker-windows-busybox"
        tags      = @(
            "latest",
            "v1.1.0",
            "v1.1",
            "v1"
        )
    },
    @{
        name      = "windows-git"
        imagename = "$registrypath/woodpecker-windows-git"
        tags      = @(
            "latest",
            "v2.0.0",
            "v2.0",
            "v2"
        )
    }
)

# iterate over the Dockerfile matrix
$matrix | ForEach-Object {
    # check if imageToBuild is specified and matches the current image
    if ($PSBoundParameters.ContainsKey('imageToBuild') -and $_.name -ne $imageToBuild) {
        return
    }

    $name = $_.name
    $image = $_.imagename
    $tags = $_.tags
    $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
    
    # build image with name and latest-tag
    Write-Host "Building image: $image"
    docker build $scriptPath -f "$scriptPath\$name.Dockerfile" -t "$image`:latest"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed for image: $image"
        exit $LASTEXITCODE
    }
    
    # tag the image with the given tags for each registry
    Write-Host "Adding tags to $image"
    $registries | ForEach-Object {
        $registry = $_
        $tags | ForEach-Object {
            $tag = $_
            $latest = "$image" + ":latest"
            $tagged = "$image" + ":" + "$tag"
            $regtag = "$registry/$tagged"
            Write-Host "Tagging image $latest -> $regtag"
            docker tag "$latest" "$regtag"
        }
    }
}

# Push images to registries
if (-not $buildonly) {
    $registries | ForEach-Object {
        $registry = $_
        $matrix | ForEach-Object {
            # check if imageToBuild is specified and matches the current image
            if ($imageToBuild -and $_.name -ne $imageToBuild) {
                continue
            }
            $image = $_.imagename
            $tags = $_.tags
            $tags | ForEach-Object {
                $tag = $_
                $tagged = "$image" + ":" + "$tag"
                $regtag = "$registry/$tagged"
                Write-Host "Pushing image $regtag"
                docker push "$regtag"
            }
        }
    }
}
