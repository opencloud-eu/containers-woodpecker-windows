# containers-woodpecker-windows

These are the Dockerfiles for windows-containers used by our ci.

## container hierarchie

```txt
mcr.microsoft.com/windows/servercore:ltsc2022
├── opencloudeu/woodpecker-windows-agent
├── opencloudeu/woodpecker-windows-git-plugin
└── opencloudeu/woodpecker-windows-chocolatey
    ├──opencloudeu/woodpecker-windows-desktop-build-tools
    └──opencloudeu/woodpecker-windows-git
```

## License

Released under GPLv3+

## Author Information

This Windows port was [originally](https://github.com/GECO-IT/woodpecker-windows) created in 2024 by Cyril DUCHENOY, CEO of [Geco-iT SARL](https://www.geco-it.fr).

It has been heavily modified/rewritten by @flimmy for usage at opencloud.eu
