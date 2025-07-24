$registrypath = "opencloudeu"

$registries = @(
    "docker.io",
    "quay.io"
)

$matrix = @(
    @{
        name      = "windows-busybox"
        imagename = "$registrypath/woodpecker-windows-busybox"
        tags      = @(
            "latest",
            "v1.0",
            "v1"
        )
    },
    @{
        name      = "windows-git"
        imagename = "$registrypath/woodpecker-windows-git"
        tags      = @(
            "latest",
            "v1.0",
            "v1"
        )
    },
    @{
        name      = "windows-agent"
        imagename = "$registrypath/woodpecker-windows-agent"
        tags      = @(
            "latest",
            "v1.0",
            "v1"
        )
    },
    @{
        name      = "windows-git-plugin"
        imagename = "$registrypath/woodpecker-windows-git-plugin"
        tags      = @(
            "latest",
            "v1.1",
            "v1"
        )
    },
    @{
        name      = "windows-chocolatey"
        imagename = "$registrypath/woodpecker-windows-chocolatey"
        tags      = @(
            "latest",
            "v1.1",
            "v1"
        )
    },
    @{
        name      = "windows-vsbuildtools"
        imagename = "$registrypath/woodpecker-windows-vsbuildtools"
        tags      = @(
            "latest",
            "v1.1",
            "v1"
        )
    },
    @{
        name      = "windows-python"
        imagename = "$registrypath/woodpecker-windows-python"
        tags      = @(
            "latest",
            "v1.1",
            "v1"
        )
    }
)

$matrix | ForEach-Object {
    $name = $_.name
    $image = $_.imagename
    $tags = $_.tags
    Write-Host "Building image: $image"
    $arguments = '. -f ' + $( split-path -parent $MyInvocation.MyCommand.Definition ) + '"\' + "$name" + '.Dockerfile" -t "' + "$image" + ':latest"'
    Invoke-Expression "docker build $arguments"
    Write-Host "Adding tags: $image"
    $registries | ForEach-Object {
        $registry = $_
        $tags | ForEach-Object {
            $tag = $_
            $latest = "$image" + ":latest"
            $tagged = "$image" + ":" + "$tag"
            $regtag = "$registry/$tagged"
            Write-Host "Tagging image $latest -> $tagged"
            docker tag "$latest" "$regtag"
        }
    }
}

# Push images to registries
$registries | ForEach-Object {
    $registry = $_
    $matrix | ForEach-Object {
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
