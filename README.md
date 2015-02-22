panda-hook
=========

### The Ultimate Tool to Manage and Deploy Githook Scripts.

> **Warning:** This is an experimental project under heavy development.  It's awesome and becoming even more so, but it is a work in progress.

---
Githooks are powerful tools.  Whatever you can script can be triggered from nothing but a git command.  PandaHook helps you manage this magic.

panda-hook is designed to not only assist you in generating githook scripts, but also setting them up in a remote server.  panda-hook is meant to be your Swiss Army knife, so it features a modular design with multiple sub-commands to keep the codebase manageable and future-friendly.  

## Installation
You may either use panda-hook as a command-line tool or install it as a dependency into your project.  In either case, you will need CoffeeScript installed.

```shell
npm install -g coffee-script
```

### Command-Line Tool
If you'd like to use PandaHook's command-line tool on your local machine, install it globally.
```shell
git clone https://github.com/pandastrike/panda-hook.git panda-hook
cd panda-hook
npm install -g .
```
This gives you a symlinked executable to invoke on your command-line. See [command-line-guide.md][1] for more information on this executable.

### Node Library
If you would like to install panda-hook as a library and programmatically access its methods, install it locally to your project.  Place this line in the "dependencies" object of your project's `package.json` file.

```json
"panda-hook": "git://github.com/pandastrike/panda-hook.git"
```

See [api-guide.md][2] for more information on programatic access.

## Usage Example
To see panda-hook in action, please see the Huxley "flavor" examples.  The simplest *Hello World* example is [vanilla][3], so that's a good place to start.

[1]:https://github.com/pandastrike/panda-hook/blob/master/command-line-guide.md
[2]:https://github.com/pandastrike/panda-hook/blob/master/api-guide.md
[3]:https://github.com/pandastrike/vanilla
