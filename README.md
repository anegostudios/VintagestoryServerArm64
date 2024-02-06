# VintagestoryServer Linux-Arm64

This repository houses the necessary files to get a working VintagestoryServer .NET 7.0 running on Linux Arm-64 architecture.

## Installation

#### Note
Mods using Harmony will not work properly on arm64 servers since Harmony is not compatible with arm64.

### Requirements
- Linux Arm64 server
- [.NET 7.0 Runtime](https://dotnet.microsoft.com/en-us/download/dotnet/7.0) installed

1. Download the latest VintagestoryServer from [account.vintagestory.at](https://account.vintagestory.at/) and extract it.
2. Delete the following files and folders:
   - VintagestoryServer
   - VintagestoryServer.deps.json
   - VintagestoryServer.dll
   - VintagestoryServer.pdb
   - VintagestoryServer.runtimeconfig.json
   - Lib

3. Download the release from this for your vintagestory version (1.18 or 1.19 as of now) [repository](https://github.com/anegostudios/VintagestoryServerArm64/releases) and extract it.

4. Copy the contents of the `server` folder from the extracted files to your server location.

5. Start the server using `./VintagestoryServer` or `dotnet VintagestoryServer.dll`

Alternatively, you can use the install script by doing the following:
1. Install required dependencies to use this script by doing `apt -y install curl jq` if on a debian based system. 

2. Create a new file named `arminstall.sh` by running `vim arminstall.sh` or `nano arminstall.sh`

3. Copy the contents of the `arminstall.sh` file from GitHub to your newly created file and save it by using `:wq` with Vim or `Ctrl + X`, then `Y`, then `Enter` with Nano.

4. Make the script executable by running `chmod +x arminstall.sh`

5. Run the script by doing `./arminstall.sh`

6. Start the server by using `./VintagestoryServer` or `dotnet VintagestoryServer.dll`

This will download the latest version of Vintagestory to the current working directory, then replace the needed files to work with ARM.

You may also specify a specific version; for example, `./arminstall.sh -v 1.18.8` will download version 1.18.8. Be sure to check all the available parameters by running `./arminstall.sh -h` for more information.

If at any time you want to update to the latest version of Vintage Story, simply run the script again.

### Notes
This version *should* be compatible with any version of the .NET 7 version of the game. The reason is that this only contains some dependencies and the binary to start the server since more is not necessary.

So far, we have tested it on a Raspberry Pi 4 4GB without issues. Keep in mind, though, this is very experimental, and we haven't done any more comprehensive testing so far. So this might run totally fine or have some major issues, be warned.

Mods: We have not tested much with mods yet, but since the rest of the code to make the server even start did not need any changes, like the internal mods, we expect it to work *fine* with almost all mods. Eventually, some mods that rely on specific native libraries that are not provided with the mod for Linux-arm64 may not work.

Furthermore, we have not tested or planned to provide a Linux Arm64 client version as of now, since as far as we are aware, there aren't many devices to make really use of it.

If you have any further questions or want to share your results/experience, feel free to do so in the [Discord #multiplayer -> VintagestoryServer Arm64](https://discord.com/channels/302152934249070593/1128220205181587516) thread.


## Using Docker

Runs Vintagestory Server in Docker using [official Microsoft .NET images](https://learn.microsoft.com/en-us/dotnet/core/docker/introduction).

### Requirements
- Linux Arm64 server. Tested with Raspberry Pi 5 (Raspbian OS).
- Install [Docker](https://www.docker.com/get-started/)
- Install [Docker compose plugin](https://docs.docker.com/compose/install/linux/#install-using-the-repository)

### Prepare server config
`serverconfig.json` contains mostly defaults (paths changed to work with the container). Any edits will make it into the server.

### Run
The following command will build an image using the provided Dockerfile, mount storage, run the server, and attach the terminal to it:
```bash
docker compose up -d && docker attach vintagestoryserverarm64-vsserver-1
```

The first run will take longer, but eventually you should be able to type `/help` and hit enter to see how to interact with the server.

### Tips

* To save and shutdown, type `/stop` and hit enter.
* Use `CTRL+P CTRL+Q` to detach terminal from the server.
* `docker volume inspect vintagestoryserverarm64_vsdata` will show the storage mount.
* `docker compose down -v` will remove the container _along with the storage_ if you need to start over.
* `docker compose up --build` to force rebuild from Dockerfile - this may be needed when updating Dockerfile.
