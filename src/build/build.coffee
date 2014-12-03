#===============================================================================
# PandaHook Builder
#===============================================================================
# This is the main file defining the "build" command in PandaHook.  Ultimately,
# it is much more complex than the other commands, so its code has been pulled out
# into a separate module.

# The goal is to abstract common tasks (like restarting services) and allow
# commands unique to a given deployment stack to be grouped into mini "modules".
# This design is meant to be future-friendly and encourage community participation
# and extension.

#====================
# Modules
#====================
{resolve} = require "path"
{read, write} = require "fairmont" # Easy file read/write

coreos = require "./coreos/coreos"


#====================
# Helper Fucntions
#====================
usage = (entry, message) ->
  if message?
    process.stderr.write "#{message}\n"

  process.stderr.write( read( resolve( __dirname, "doc", entry ) ) )
  process.exit -1

#===============================
# Module Definition
#===============================
builder =
  main: (argv, config) ->
    # Check the command arguments.  Deliver an info blurb if needed.
    if argv.length == 3 or argv[3] == "help"
      usage "build"

    # Now, look for module references.
    switch argv[3]
      when "coreos"
        coreos.main argv, config
      else
        # When the module cannot be identified, display the help guide.
        usage "build", "\nError: Build Module Not Found: #{argv[3]} \n"

module.exports = builder
