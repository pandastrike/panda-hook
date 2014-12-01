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

## Comparison to GitReceive:
Let's start by discussing why people have gone through the trouble of building tools like [GitReceive](https://github.com/progrium/gitreceive) and PandaHook.  Githooks are a really cool technology, and while we are most interested in their potential for continuous intergration, they can be used in many ways. The problem is that they can be a little cumbersome to maintain, which is ironic since git has transformed how developers approach source code management.  

Git's philosophy is built on the idea of distributed development, so its design emphasizes the "pull" action.  That is, if you wish to incorporate someone's code, you "pull" from their open repository.  This design paradigm is a break from using a centralized, authoritative repo strictly monitored by the Powers-That-Be.  If you consider that design decision, the following description of the problem PandaHook and GitReceive try to solve becomes clear.

### The Problem
Inside a git repository, git maintains your local working tree, a subdirectory of every file that you see if you were to `ls` your repo.  But there's more... Git maintains "meta-data" on your project.  We know git maintains the repo version history, but this all happens out of sight.  Version history is tucked away in the hidden `.git` directory.

Githooks are also located in the `.git` directory, and that's the problem.  Githook scripts were originally meant to be maintained locally and manually by one developer.  They are meant to make your life easier, but they do not move with working tree.  They are "meta-data".

Now, there are some nice benefits to having a centralized repository up on the web for everyone to see (Thank You GitHub!).  To accomodate this, git added the "push" command and ushered in some server-side githook scripts.  These are the ones we're interested in, but (for now) they are not touched by git commands.  That's where tools like PandaHook and GitReceive come in.

What follows is a comparison of the two tools.  In general PandaHook aims to be a *client-side* tool that wraps tedious SSH based commands to the hook-server into short sub-commands.  The modular design focuses on maintenance and extension, to be widely useful, and to be future-friendly for this DevOps stack.



<table>
  <tr>
    <th>Area of Comparison</th>
    <th>PandaHook</th>
    <th>GitReceive</th>
  </tr>

  <tr>
    <td class=title> General Approach </td>
    <td>
      Lives on your local machine.  It's a commandline tool that provides high-level sub-commands to interact with the hook server.  You'll never have deal with low-level shell commands to manually manipulate files on the hook server.  PandaHook is also meant to help with githook script generation.  
    </td>
    <td>
      Lives on the hook-server.  It's a commandline tool that provides high-level sub-commands, but these focus on preparing the hook-server's configuration.  The configuration commands are accessed over an SSH connection, while the main sub-commands are invoked programmatically by the githook script.  Scripts are constructed manually.
    </td>
  </tr>

<tr>
  <td class=title> SSH Access </td>
  <td>
    Your public key will need to be placed on the hook-server.  PandaHook relies on you using agent-forwarding so that all your credentials are fully available to you on the remote server while connected.  This works because git is built on SSH, so `git push` creates an SSH connection to the hook-server.<br> <br>

    The idea here is to stay simple (by only using a single public key), but give your githook scripts authority to access deployment servers, GitHub accounts, etc.
  </td>
  <td>
    Your public key will need to be placed on the hook-server.  GitReceive provides a nifty little sub-command (`upload-key`) for a user with `root` authority to add public keys piped into an SSH command. <br> <br>

    GitReceive's use of your public key is security-minded.  The `upload-key` command specifies limited use with your account and forbids agent-forwarding.  Any additional keys must be managed on the hook-server.
  </td>
</tr>

<tr>
  <td class=title> Githook Script Management </td>
  <td>
    Sub-commands are used to place scripts into the `.git` directory of the specified remote repo, where they are run directly.
  </td>
  <td>
    Scripts are placed into the hook server manually via an `sftp` or `scp` command.  They live in the `receiver` sub-directory of the remote home directory.  <br> <br>

    These scripts are not used directly by githooks, but are instead invoked by the `run` sub-command, which wraps their behavior.
  </td>
</tr>


<tr>
  <td class=title> Githook Script Generation </td>
  <td>
    This feature needs to be built out some more, but PandaHook is intended to support basic generation.  It abstracts some of the more common things you'd do with a githook (example: restart a service). <br><br>

    Because different projects will have different needs, we establish the concept of "modules" to package these needs.  For example, the "restart" command of the "coreos" module invokes `fleetctl` in its script. <br><br>

    We are likely to focus on CoreOS for the immediate future, but this is a potential platform for community involvement depending on the sophistication of the generator.
  </td>
  <td>
    There is no support for githook script generation, however there is an introductory example script provided by the `init` sub-command. <br> <br>
  </td>
</tr>


  <tr>
    <td class=title> Hook-Server Setup: <br> Before You Can Start Doing Stuff </td>
    <td>
      1. You'll need to setup a remote server with `ssh`, `git`, and any other dependencies you'll use in your githook script. <br> <br>
      2. Install PandaHook into your local machine `/bin/`. <br><br>
      3. If you wish for users to not have `root` access on the hook-server, you'll need to create a second user account.  All users will gain access through this account. <br><br>
      4. Any user that wishes to use the hook-server will need their public key installed. <br> <br>
      5. You're now ready to use PandaHook from your local machine. <br><br>
    </td>
    <td>
      1. You'll need to setup a remote server with `ssh`, `git`, and any other dependencies you'll use in your githook script. <br><br>
      2. Install `gitreceive` into the remote `/usr/bin` directory and make it executable. <br><br>
      3. Over SSH (with a user with `root` authority), run `gitreceive init` to create a new user account with a git identity. <br><br>
      4. Any user that wishes to use the hook-server will need their public key installed.  Pipe your public key into an SSH command (with a user with `root` authority) that executes `gitreceive upload-key`. <br><br>
      5. You're now ready to add a remote to your local repository and craft a githook script. <br><br>

    </td>
  </tr>
</table>
