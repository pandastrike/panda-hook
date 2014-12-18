#===============================================================================
# PandaHook CoreOS Builder - Command-Line Interface
#===============================================================================
# This is the main file defining the builder's CoreOS module's CLI.

#====================
# Modules
#====================
{resolve} = require "path"
{read, write, remove} = require "fairmont" # Easy file read/write
async = (require "when/generator").lift   # Makes resuable generators.

coreos = require "./coreos"

#====================
# Helper Fucntions
#====================
usage = (entry, message) ->
  if message?
    process.stderr.write "#{message}\n"

  process.stderr.write( read( resolve( __dirname, "doc", entry ) ) )
  process.exit -1

# Accept only the allowed values for flags that take an enumerated type.
allow_only = (allowed_values, value, flag) ->
  if allowed_values.indexOf(value) == -1
    process.stderr.write "\nError: Only Allowed Values May Be Specified For Flag: #{flag}\n\n"
    process.exit -1

#===============================================================================
# Parsing Functions
#===============================================================================
#------------------------
# Restart
#------------------------
parse_restart_arguments = (argv) ->
  # Deliver an info blurb if neccessary.
  if argv.length == 1 or argv[1] == "help"
    usage "restart"

  # Begin buliding the "options" object.
  options = {}
  options.services = []

  # Establish an array of flags that *must* be found for this method to succeed.
  required_flags = ["-h", "-n", "-s"]

  # Loop over arguments.  Collect settings and validate where possible.
  argv = argv[1..]

  while argv.length > 0
    if argv.length == 1
      usage "restart", "\nError: Flag Provided But Not Defined: #{argv[0]}\n"

    switch argv[0]
      when "-h"
        allowed_values = ["applypatch-msg", "pre-applypatch", "post-applypatch",
        "pre-commit", "prepare-commit-msg", "commit-msg", "commit-msg", "post-commit",
        "pre-rebase", "post-checkout", "post-merge", "pre-push", "pre-receive",
        "update", "post-receive", "post-update", "pre-auto-gc", "post-rewrite"]

        allow_only allowed_values, argv[1], argv[0]
        options.hook = argv[1]
        remove required_flags, "-h"
      when "-n"
        options.repo = argv[1]
        remove required_flags, "-n"
      when "-s"
        options.services.push argv[1]
        unless required_flags.indexOf("-s") == -1
          remove required_flags, "-s"
      else
        usage "restart", "\nError: Unrecognized Flag Provided: #{argv[0]}\n"

    argv = argv[2..]

  # Done looping.  Check to see if all required flags have been defined.
  if required_flags.length != 0
    usage "restart", "\nError: Mandatory Flag(s) Remain Undefined: #{required_flags}\n"

  # After successful parsing, return the completed "options" object.
  return options

#===============================================================================
# Top-Level Command-Line Parsing
#===============================================================================
module.exports =
  parse_module: async (config, argv) ->
    # Check the command arguments.  Deliver an info blurb if needed.
    if argv.length == 0 or argv[0] == "help"
      usage "main"

    # Now, look for sub-commands for this module.
    switch argv[0]
      when "restart"
        options = parse_restart_arguments argv
        coreos.restart config, options
      else
        # When the module cannot be identified, display the help guide.
        usage "main", "\nError: Sub-Command Not Found: #{argv[0]} \n"
