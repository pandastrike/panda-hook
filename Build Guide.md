# PandaHook Build Sub-Command
In PandaHook, the build sub-command encapsulates script generation and is the most sophisticated.  The goal is to abstract some of the more common actions you would perform with a githook.  We want to separate out unique stack dependencies into modules with their own code and documentation.

# CoreOS
PandaHook is still in early development, so its focus is limited to CoreOS.  This module's main dependency is fleetctl, so you will see script templates that make use of that tool.

## Restart
Produces "restart" githooks that stop and restart the specified service(s).  This is meant to facilitate continuous integration.

### options
The following members must be provided to the options object:
* **hook** - Name of the target githook script.

    Allowed values are "applypatch-msg", "pre-applypatch", "post-applypatch", "pre-commit", "prepare-commit-msg", "commit-msg", "commit-msg", "post-commit", "pre-rebase", "post-checkout", "post-merge", "pre-push", "pre-receive", "update", "post-receive", "post-update", "pre-auto-gc", "post-rewrite"
* **repo** - Name of target repository.
* **services** - (Array) This is an array of services that are to be restarted by the hook-server.
