Param(
    [Parameter(
        Position=0,
        Mandatory=$False
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
# the chocolatey image should go first, as it is our base image
$matrix = @(
    @{
        name      = "windows-chocolatey"
        imagename = "$registrypath/woodpecker-windows-chocolatey"
        version   = "v2"
    },
    @{
        # renovate: datasource=github-tags depName=woodpecker-ci/woodpecker
        name      = "windows-agent"
        imagename = "$registrypath/woodpecker-windows-agent"
        version   = "v3.12.0"
    },
    @{
        name      = "windows-git-plugin"
        imagename = "$registrypath/woodpecker-windows-git-plugin"
        version   = "v2.1"
    },
    @{
        name      = "windows-desktop-build-tools"
        imagename = "$registrypath/woodpecker-windows-desktop-build-tools"
        version   = "v1.1"
    },
    @{
        name      = "windows-git"
        imagename = "$registrypath/woodpecker-windows-git"
        version   = "v2"
    }
)


### Functions

# Generate a list of semantic version tags based on the provided version parts
# to ensure that a version tag is added for its major, minor, and patch part.
# If only one part is given the rest is padded with zeros to ensure all three parts are present.
function Get-SemVerTags {
    param([string]$version)
    $ver = $version.TrimStart("v")
    $parts = $ver -split '\.'
    
    # Pad missing parts with zeros to ensure 3 parts
    while ($parts.Length -lt 3) { $parts += '0' }
    $major = $parts[0]
    $minor = $parts[1]
    $patch = $parts[2]
    $tags = @(
        "latest",
        "v$major.$minor.$patch",
        "v$major.$minor",
        "v$major"
    )
    return $tags
}


### Main

# iterate over the Dockerfile matrix
$matrix | ForEach-Object {
    # check if imageToBuild is specified and matches the current image
    if ($PSBoundParameters.ContainsKey('imageToBuild') -and $_.name -ne $imageToBuild) {
        return
    }

    $name = $_.name
    $image = $_.imagename
    $tags = Get-SemVerTags $_.version
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
            $tags = Get-SemVerTags $_.version
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
