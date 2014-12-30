# PandaHook API Guide
This guide aims to document and specify the API of PandaHook when used as a Node library.

Methods:

* build
* create
* destroy
* push
* rm

Before we talk about the methods in detail, we should first mention the configuration object. Most of the following methods access a remote server to do things for you automatically.  There are several members of the object that must be set for successful access.  Additionally, your public SSH key must be on the remote server, though that full tutorial is beyond the scope of this API Guide.

The object `config` is passed into most of the below functions and contains the following members:

```coffee
config =
  # This object is required.
  hook_server:
    # This is an SSH connection, not HTTPS
    address: "user@myHookServer.com"

  # Optional objects for target stacks.
  coreos:
    address: "myCoreOSCluster.com"
```

## build (config, options)
This function aims to assist in githook script construction and is special among the sub-commands.  We aim to abstract common githook actions and provide dependencies for the various stacks by focusing on a modular design.  For example, CoreOS uses fleetctl.

The only option important at this level is the "build module".  From here, the modules allow the possibility of greater variability.  
### options
This is an object with the following members:
* **build_module** - Name of the PandaHook build module.  This module is a Node library capable of producing githook script using the designated stack's dependencies.
* **command** - This is one of the abstract actions taken with githook scripts.
* **Note:** Remaining members depend on which build module and command have been selected.  Please see *Build Guide.md* for more information.

## create (config, options)
This function creates a "bare" repository on the hook-server.  The repository consists solely of what is usually within the `.git` folder of a regular repository.  This function also creates a git alias for the remote repository under the name "hook".
### options
This is an object with the following members:
* **repo_name** - Name of remote repository.  It will need to match the name of the local repository for pushes to take place.

## destroy (config, options)
This function is the converse of `create`.  It deletes the bare repository bearing the specified name, as well as its standard-repo copy, if present.  This function also removes the git alias "hook".
### options
This is an object with the following members:
* **repo_name** - Name of remote repository.

## push (config, options)
This function places a githook script into the remote "bare" repository.  It is placed into the `hooks` directory and made executable.
### options
This is an object with the following members:
* **hook_name** - Path to the githook script on the local machine.  This should be relative to the working directory.

  Allowed values are "applypatch-msg", "pre-applypatch", "post-applypatch", "pre-commit", "prepare-commit-msg", "commit-msg", "commit-msg", "post-commit", "pre-rebase", "post-checkout", "post-merge", "pre-push", "pre-receive", "update", "post-receive", "post-update", "pre-auto-gc", "post-rewrite"
* **repo_name** - Name of remote repository.  If the remote repository does not exist on the hook-server, one will be created for you.

## rm (config, options)
This is an object with the following members:
This function is the converse of `push`.  It removes githook scripts from the remote repository.
### options
This is an object with the following members:
* **hook_name** - Name of the target githook script.  The githook script must exist in the target repository for this function to succeed.

  Allowed values are "applypatch-msg", "pre-applypatch", "post-applypatch", "pre-commit", "prepare-commit-msg", "commit-msg", "commit-msg", "post-commit", "pre-rebase", "post-checkout", "post-merge", "pre-push", "pre-receive", "update", "post-receive", "post-update", "pre-auto-gc", "post-rewrite"
* **repo_name** - Name of remote repository. The remote repository must exist on the hook-server for this function to succeed.
