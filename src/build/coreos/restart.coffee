#===============================================================================
# PandaHook - CoreOS Restart
#===============================================================================
# This tool constructs a Bash script to be used as a server-side githook that
# restarts targeted CoreOS services.

#====================
# Modules
#====================
{readFileSync, writeFileSync} = require "fs"
{resolve} = require "path"

{render} = require "mustache"


#===============================
# Helpers
#===============================
# This function accesses the run directory

#===============================
# Module Definition
#===============================
module.exports =
  restart: (options) ->  
    input_path = resolve( __dirname, "templates/restart")
    template = readFileSync input_path, "utf-8"

    output_path = resolve process.cwd(), options.hook_name
    contents = render( template, options)
    writeFileSync output_path, contents
