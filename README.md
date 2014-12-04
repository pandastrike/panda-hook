PandaHook
=========

### The Ultimate Tool to Manage and Deploy Githook Scripts.

---
Githooks are powerful tools.  Whatever you can script can be triggered from nothing but a git command.  PandaHook helps you manage this magic.

PandaHook is designed to not only assist you in generating githook scripts, but also setting them up in a remote server.  PandaHook is meant to be your Swiss Army knife, so it features a modular design with multiple sub-commands to keep the codebase manageable and future-friendly.  

## Installation
PandaHook is easily installed as a global npm package.  You will need CoffeeScript installed.

```
  npm install -g coffee-script
  npm install -g pandahook
```

## Usage Example
To see how PandaHook is used, you'll need a couple things:

1. The hook-server, a remote server to host your server-side githooks.
2. The configuration dotfile, `.pandahook.cson`, completed for your use-case and placed into your local `$HOME` directory (ie, at `~/.pandahook.cson`).  See below for more details.
3. A git repository on your local machine, from which you will push to the hook-server.
4. A service running somewhere on a second remote server.  Our initial examples will target services running inside CoreOS clusters.

You can see a *Hello World* example of PandaHook usage in [this repository](https://github.com/pandastrike/coreos-reflector/blob/master/githook_readme.md).  


## Configuration Dotfile
Reusable configuration data is stored in the dotfile `.pandahook.cson`.  This keeps you from having to re-type the same data repeatedly into commands.  Here is its layout:

```coffee
# Required Hook-Server Stanza
hookServer:
  address: "user@myHookServer.com"   # This is an SSH connection, not HTTPS

# Optional Stanzas for Target Services.  We will focus on CoreOS here.
coreos:
  address: "user@myCoreOSCluster.com" # This is an SSH connection, not HTTPS
```

## Sub-Commands
- **build**     Generates a githook script
- **create**    Clones a remote, bare repo on the hook-server
- **destroy**   Deletes a remote repo from the hook-server
- **push**      Adds the specified githook script to remote repo on the hook-server
- **rm**        Deletes the specifed githook script from the remote repo on the hook-server

## Build Sub-Command
The build sub-command encapsulates script generation functionality and is the most sophisticated.  The goal is to abstract some the more common actions you would perform with a githook, and then separate out unique command dependencies into modules with their own code and documentation.

At the moment, we're just starting with the CoreOS dependency fleetctl and a script that produces "restart" githooks that facilitate continuous integration.
