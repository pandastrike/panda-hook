PandaHook
=========

### The Ultimate Tool to Manage and Deploy Githook Scripts.

---
Githooks are powerful tools.  Whatever you can script can be performed for you automatically from nothing but a git command.  Panda Hook helps you manage this magic.

PandaHook is designed to not only assist you in generating githook scripts, but also setting them up in a remote server.  PandaHook is meant to be your Swiss Army knife, so it utilizes multiple sub-commands to keep the codebase manageable.  

Here is a sampling:

```
Usage: pandahook [OPTIONS] COMMAND [arg...]
--------------------------------------------
Follow any command with "help" for more information.

A tool to manage githook scripts and deploy them to your hook-server.

Commands:
   build     Generates a githook script
   create    Clones a remote, bare repo on the hook-server
   destroy   Deletes a remote repo from the hook-server
   init      Setup pandahook with details about the hook-server
   push      Adds the specified githook script to remote repo on the hook-server
   rm        Deletes the specifed githook script from the remote repo on the hook-server
   status    Gives details about Panda Hook configuration.
```
