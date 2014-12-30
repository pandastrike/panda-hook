#===============================================================================
# PandaHook - The Ultimate Githook Script Management Tool.
#===============================================================================
# This is the command-line processor for the "build" command.

#====================
# Modules
#====================
{resolve} = require "path"
{read, write, remove} = require "fairmont" # Easy file read/write

coreos = require "./coreos/cli"

#====================
# Helper Fucntions
#====================
# Output an Info Blurb and optional message.
usage = (entry, message) ->
  if message?
    process.stderr.write "#{message}\n"

  throw read( resolve( __dirname, "doc", entry ) )


#===============================================================================
# Top-Level Command-Line Parsing
#===============================================================================
module.exports =

  # Sorts Command-Line input for build command.
  parse_module: (config, argv) ->
    # Check the command arguments.  Deliver an info blurb if needed.
    if argv.length == 0 or argv[0] == "help" or argv[0] == "-h"
      usage "build"

    # Now, look for module references.
    switch argv[0]
      when "coreos"
        coreos.parse_module config, argv[1..]
      else
        # When the module cannot be identified, display the help guide.
        usage "build", "\nError: Build Module Not Found: #{argv[0]} \n"
