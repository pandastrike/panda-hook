#===============================================================================
# PandaHook CoreOS Builder
#===============================================================================
# This is the main file defining the builder's CoreOS module.

#====================
# Modules
#====================
{restart} = require "./restart"

#===============================
# Sub-Module Definition
#===============================
module.exports =

  # When this library is accessed programatically, this method used for standardized
  # access.  Other methods are called from here.
  main: (options) ->
    # Continue on to the specified command.
    switch options.command
      when "restart"
        restart options
      else
        # When the command cannot be identified, throw error.
        throw "Error: Sub-Command Not Found in CoreOS Build Module: #{options.command}"
