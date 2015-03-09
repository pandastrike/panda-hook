#!/usr/bin/env bash
cd hooks/coreos_restart
npm install .
rm stdin.txt
read foo bar branch_name
echo "$foo $bar $branch_name" >> stdin.txt
coffee --nodejs --harmony coreos_restart.coffee < stdin.txt
