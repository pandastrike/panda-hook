PandaHook
=========

### The Ultimate Tool to Manage and Deploy Githook Scripts.

---
Githooks are powerful tools.  Whatever you can script can be triggered from nothing but a git command.  PandaHook helps you manage this magic.

PandaHook is designed to not only assist you in generating githook scripts, but also setting them up in a remote server.  PandaHook is meant to be your Swiss Army knife, so it features a modular design with multiple sub-commands to keep the codebase manageable and future-friendly.  

## Installation
PandaHook is easily installed via npm.  However, how you install PandaHook depends on how you'd like to use it.  You may either use PandaHook as a command-line tool or install it as a dependency into your project.  In either case, you will need CoffeeScript installed.

### Command-Line Tool
If you'd like to use PandaHook's command-line tool on your local machine, install it globally.
```shell
npm install -g coffee-script
npm install -g pandahook
```
This gives you a symlinked executable to invoke on your command-line. See *Command-Line Guide* below for more information on this executable.

### Node Library
If you would like to install PandaCluster as a library and programmatically access its methods, install it locally to your project.
```shell
npm install -g coffee-script
npm install --save pandahook
```
This places the PandaCluster Node module into your project and in your `package.json` file as a dependency. See *API Guide* below for more information on programatic access.

## Command-Line Guide
The command-line tool is accessed via several sub-commands. Information is available at any time by placing "help" or "-h" after most commands. Here is a list of currently available sub-commands.
```
--------------------------------------------
Usage: pandahook COMMAND [arg...]
--------------------------------------------
Follow any command with "help" for more information.

A tool to manage githook scripts and deploy them to your hook-server.

Commands:
build     Generates a githook script
create    Clones a remote, bare repo on the hook-server
destroy   Deletes a remote repo from the hook-server
push      Adds the specified githook script to remote repo on the hook-server
rm        Deletes the specifed githook script from the remote repo on the hook-server
```

In particular, the **build** sub-command is meant to be flexible and powerful.  Please see *build_subcommand.md* for more information.

### Configuration Dotfile
Reusable configuration data is stored in the dotfile `.pandahook.cson`.  This keeps you from having to re-type the same data repeatedly into commands.  This data must be provided in your code if you plan to access the library programmatically.  Here is a sample file layout:

```coffee
# Required Hook-Server Stanza
hook_server:
  address: "user@myHookServer.com"   # This is an SSH connection, not HTTPS

  # Optional Stanzas for Target Services.  We will focus on CoreOS here.
  coreos:
    address: "myCoreOSCluster.com"
```

## API Guide
To keep this ReadMe short, the API documentation has been placed into a separate file. See the file *API Guide.md* for complete information.

## Usage Example
To see how PandaHook is used, you'll need a couple things:

1. The hook-server, a remote server to host your server-side githooks.
2. The configuration dotfile, `.pandahook.cson`, completed for your use-case and placed into your local `$HOME` directory (ie, at `~/.pandahook.cson`).  See below for more details.
3. A git repository on your local machine, from which you will push to the hook-server.
4. The service targeted by your githook, running on a second remote server out there somewhere on the Internet.  Our initial examples will target services running inside CoreOS clusters.

You can see a *Hello World* example of PandaHook usage in [this repository](https://github.com/pandastrike/coreos-reflector/blob/master/githook_readme.md).  
