# VintagestoryServer Linux-Arm64

This repository houses the necessary files to to get a working VintagestoryServer .NET 7.0 running on linux Arm-64 architecture.

## Installation

### Requierments
 - linux Arm64 server
 - [.NET 7.0 Runtime](https://dotnet.microsoft.com/en-us/download/dotnet/7.0) installed

1. Download the latest VintagestoryServer [vs_server_linux-x64_1.18.8.tar.gz](https://cdn.vintagestory.at/gamefiles/stable/vs_server_linux-x64_1.18.8.tar.gz) and extract it.
2. Delete the following files and folders
 - VintagestoryServer
 - VintagestoryServer.deps.json
 - VintagestoryServer.dll
 - VintagestoryServer.pdb
 - VintagestoryServer.runtimeconfig.json
 - Lib

3. Download this [repository](https://github.com/anegostudios/VintagestoryServerArm64/archive/refs/heads/master.zip) and extract it.

4. Copy the contents of `server` from the extracted files to your server location.

5. Start the server using `./VintagestoryServer` or `dotnet VintagestoryServer.dll`

### Notes
This version *should* be compatible with any version of the .NET 7 version of the game. The reason is that this only contains some dependencies and the binary to start the server since more is not necessary.

So far we have tested it on a Raspberry Pi 4 4GB without issues. Keep in mind tho this is very experimental and we haven't done any more comprehensive testing so far. So this might run totally fine or have some major issues be warned.

Mods: We have not tested much with mods yet but since the rest of the code to make the server even start did not need any changes, like the internal mods, we expect it to work _fine_ with almost all mods. Eventually some mods that rely on specific native libraries that are not provided with the mod for linux-arm64 may not work.

Further we have not tested or planned to provide a Linux Arm64 client version as of now, since as far as we are aware there aren't much devise to make really use of it.

If you have any further question or wanna share your results/experience feel free todo so in [Discord #multiplayer ->
VintagestoryServer Arm64](https://discord.com/channels/302152934249070593/1128220205181587516) thread.