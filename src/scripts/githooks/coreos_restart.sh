#!/usr/bin/env bash
cd hooks/coreos_restart
npm install .
coffee --nodejs --harmony coreos_restart.coffee <&0
