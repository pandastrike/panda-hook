#!/usr/bin/env bash
cd hooks/coreos_restart

# Silently install panda-hook githook packages.
npm install .  &>/dev/null

# From stdin, read the information provided by git: (1) commit hash before, (2) commit hash after, (3) branch name
read before after branch

# Silently execute the CoffeeScript program that is the meat of this githook
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa
nohup coffee --nodejs --harmony githook.coffee $branch &>log.txt &
