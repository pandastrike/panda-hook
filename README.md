panda-hook
=========

> **IMPORTANT** This project is no longer under active development.
> Based on what we've learned building this,
> we recommend looking at [Convox][] instead.

[Convox]:https://github.com/convox/rack

### Manage and Deploy Githook Scripts.

---
Githooks are powerful tools.  You can trigger local and server-side scripts with a git command, making them critical for automation.  [Huxley][huxley] relies on them to provide users with continuous integration after updating their server with a "git push".

However, one problem with githooks is that they are not transferred like other files in your directory tree.  panda-hook solves that problem and automates the process of setting up remote server-side githooks for Huxley.  panda-hook is meant to be your Swiss Army knife, so it features a modular design with multiple sub-commands to keep the codebase manageable and future-friendly.

Please see the [Huxley Wiki][wiki] for more documentation.  

## Requirements
panda-hook makes use of ES6 features, including promises and generators.  Using this library requires Node 0.12+.

```shell
git clone https://github.com/creationix/nvm.git ~/.nvm
source ~/.nvm/nvm.sh && nvm install 0.12
```

Compiling the ES6 compliant CoffeeScript requires `coffee-script` 1.9+.
```shell
npm install -g coffee-script
```

## Install
Install panda-hook locally to your project with:

```
npm install pandastrike/panda-hook --save
```

[huxley]:https://github.com/pandastrike/huxley
[wiki]:https://github.com/pandastrike/huxley/wiki/panda-hook
