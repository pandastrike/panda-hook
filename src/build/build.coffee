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
async = (require "when/generator").lift   # Makes resuable generators.

coreos = require "./coreos/coreos"

#====================
# Helper Fucntions
#====================


#===============================
# Module Definition
#===============================
module.exports =
  main: async (config, options) ->

    # Continue on to the specified module.
    switch options.build_module
      when "coreos"
        coreos.main config, options
      else
        # When the module cannot be identified, throw error.
        throw "Error: Build Module Not Found: #{options.build_module}"
