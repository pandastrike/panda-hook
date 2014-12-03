#===============================================================================
# PandaHook CoreOS Builder
#===============================================================================
# This is the main file defining the builder's CoreOS module.

#====================
# Modules
#====================
{resolve} = require "path"
{read, write} = require "fairmont" # Easy file read/write

restart = require "./restart"

#====================
# Helper Fucntions
#====================
usage = (entry, message) ->
  if message?
    process.stderr.write "#{message}\n"

  process.stderr.write( read( resolve( __dirname, "doc", entry ) ) )
  process.exit -1


#===============================
# Sub-Command Definitions
#===============================
# Restarts every listed service file.
cmd_restart = (argv, config) ->
  # Check the command arguments.  Deliver an info blurb if needed.
  if argv.length == 6 or argv.length == 7 or argv[6] == "help"
    usage "restart"

  # Now, build the script!
  restart.build argv, config


#===============================
# Module Definition
#===============================
coreos =
  main: (argv, config) ->
    # Check the command arguments.  Deliver an info blurb if needed.
    if argv.length == 4 or argv.length == 5 or argv[4] == "help"
      usage "main"

    # Now, look for module references.
    switch argv[5]
      when "restart"
        cmd_restart argv, config
      else
        # When the module cannot be identified, display the help guide.
        usage "main", "\nError: Command Not Found: #{argv[5]} \n"

module.exports = coreos
