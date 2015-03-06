#!/usr/bin/env bash
pacman-db-upgrade
pacman -S nodejs --noconfirm
npm install coffee -g
npm install
coffee --nodejs --harmony post-receive.coffee <&0
