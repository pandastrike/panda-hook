#===============================================================================
# PandaHook CoreOS Builder
#===============================================================================
# This is the main file defining the builder's CoreOS module.

#====================
# Modules
#====================
async = (require "when/generator").lift   # Makes resuable generators.

{restart} = require "./restart"

#===============================
# Sub-Module Definition
#===============================
module.exports =

  # When this library is accessed programatically, this method used for standardized
  # access.  Other methods are called from here.
  main: async (config, options) ->
    # Continue on to the specified command.
    switch options.command
      when "restart"
        @restart config, options
      else
        # When the command cannot be identified, throw error.
        throw "Error: Sub-Command Not Found in CoreOS Build Module: #{options.command}"

  # Produces a script that destroys and restarts services on the CoreOS cluster.
  restart: async (config, options) ->
    restart config, options
