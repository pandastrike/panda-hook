#===============================================================================
# PandaHook - The Ultimate Githook Script Management Tool.
#===============================================================================

#====================
# Modules
#====================
{argv} = process
{resolve} = require "path"
{read, write, remove} = require "fairmont" # Easy file read/write
{parse} = require "c50n"           # .cson file parsing

PH = require "./pandahook"
builder = require "./build/cli"    # Githook Script Generator, through CLI parser.


#====================
# Helper Fucntions
#====================
# Output an Info Blurb and optional message.
usage = (entry, message) ->
  if message?
    process.stderr.write "#{message}\n"

  process.stderr.write( read( resolve( __dirname, "..", "doc", entry ) ) )
  process.exit -1

# Accept only the allowed values for flags that take an enumerated type.
allow_only = (allowed_values, value, flag) ->
  if allowed_values.indexOf(value) == -1
    process.stderr.write "\nError: Only Allowed Values May Be Specified For Flag: #{flag}\n\n"
    process.exit -1

#===============================================================================
# Parsing Functions
#===============================================================================
# Define parsing functions for each sub-command's arguments.

#------------------------
# Create
#------------------------
parse_create_arguments = (argv) ->
  # Deliver an info blurb if neccessary.
  if argv.length == 1 or argv[1] == "-h" or argv[1] == "help"
    usage "create"

  # Begin buliding the "options" object.
  options = {}

  # Establish an array of flags that *must* be found for this method to succeed.
  required_flags = ["-n"]

  # Loop over arguments.  Collect settings and validate where possible.
  argv = argv[1..]

  while argv.length > 0
    if argv.length == 1
      usage "create", "\nError: Flag Provided But Not Defined: #{argv[0]}\n"

    switch argv[0]
      when "-n"
        options.repo_name = argv[1]
        remove required_flags, "-n"
      else
        usage "create", "\nError: Unrecognized Flag Provided: #{argv[0]}\n"

    argv = argv[2..]

  # Done looping.  Check to see if all required flags have been defined.
  if required_flags.length != 0
    usage "create", "\nError: Mandatory Flag(s) Remain Undefined: #{required_flags}\n"

  # After successful parsing, return the completed "options" object.
  return options


#------------------------
# Destroy
#------------------------
parse_destroy_arguments = (argv) ->
  # Deliver an info blurb if neccessary.
  if argv.length == 1 or argv[1] == "-h" or argv[1] == "help" or argv.length > 2
    usage "destroy"

  # Build the "options" object.
  options = {}
  options.repo_name = argv[1]

  # After successful parsing, return the completed "options" object.
  return options


#------------------------
# Push
#------------------------
parse_push_arguments = (argv) ->
  # Deliver an info blurb if neccessary.
  if argv.length == 1 or argv[1] == "-h" or argv[1] == "help"
    usage "push"

  # Begin buliding the "options" object.
  options = {}

  # Establish an array of flags that *must* be found for this method to succeed.
  required_flags = ["-h", "-n"]

  # Loop over arguments.  Collect settings and validate where possible.
  argv = argv[1..]

  while argv.length > 0
    if argv.length == 1
      usage "push", "\nError: Flag Provided But Not Defined: #{argv[0]}\n"

    switch argv[0]
      when "-h"
        allowed_values = ["applypatch-msg", "pre-applypatch", "post-applypatch",
        "pre-commit", "prepare-commit-msg", "commit-msg", "commit-msg", "post-commit",
        "pre-rebase", "post-checkout", "post-merge", "pre-push", "pre-receive",
        "update", "post-receive", "post-update", "pre-auto-gc", "post-rewrite"]

        allow_only allowed_values, argv[1], argv[0]
        options.hook_name = argv[1]
        remove required_flags, "-h"
      when "-n"
        options.repo_name = argv[1]
        remove required_flags, "-n"
      else
        usage "push", "\nError: Unrecognized Flag Provided: #{argv[0]}\n"

    argv = argv[2..]

  # Done looping.  Check to see if all required flags have been defined.
  if required_flags.length != 0
    usage "push", "\nError: Mandatory Flag(s) Remain Undefined: #{required_flags}\n"

  # After successful parsing, return the completed "options" object.
  return options




#------------------------
# Remove (rm)
#------------------------
parse_rm_arguments = (argv) ->
  # Deliver an info blurb if neccessary.
  if argv.length == 1 or argv[1] == "-h" or argv[1] == "help"
    usage "rm"

  # Begin buliding the "options" object.
  options = {}

  # Establish an array of flags that *must* be found for this method to succeed.
  required_flags = ["-h", "-n"]

  # Loop over arguments.  Collect settings and validate where possible.
  argv = argv[1..]

  while argv.length > 0
    if argv.length == 1
      usage "rm", "\nError: Flag Provided But Not Defined: #{argv[0]}\n"

    switch argv[0]
      when "-h"
        allowed_values = ["applypatch-msg", "pre-applypatch", "post-applypatch",
        "pre-commit", "prepare-commit-msg", "commit-msg", "commit-msg", "post-commit",
        "pre-rebase", "post-checkout", "post-merge", "pre-push", "pre-receive",
        "update", "post-receive", "post-update", "pre-auto-gc", "post-rewrite"]

        allow_only allowed_values, argv[1], argv[0]
        options.hook_name = argv[1]
        remove required_flags, "-h"
      when "-n"
        options.repo_name = argv[1]
        remove required_flags, "-n"
      else
        usage "rm", "\nError: Unrecognized Flag Provided: #{argv[0]}\n"

    argv = argv[2..]

  # Done looping.  Check to see if all required flags have been defined.
  if required_flags.length != 0
    usage "rm", "\nError: Mandatory Flag(s) Remain Undefined: #{required_flags}\n"

  # After successful parsing, return the completed "options" object.
  return options


#===============================================================================
# Top-Level Command-Line Parsing
#===============================================================================
# Chop off the argument array so that only the arguments remain.
argv = argv[2..]

# Deliver an info blurb if neccessary.
if argv.length == 0 or argv[0] == "-h" or argv[0] == "help"
  usage "main"

# Extract configuration data from the PandaHook dotfile.
config = parse( read( resolve( "#{process.env.HOME}/.pandahook.cson" )))

# Now, look for the top-level commands.
switch argv[0]
  when "build"
    # This command automates the process of writing githook scripts.  Its construction is
    # modular and separate from this file so that it remains extensible and easily modified.
    builder.parse_module config, argv[1..]
  when "create"
    options = parse_create_arguments argv
    PH.create config, options
  when "destroy"
    options = parse_destroy_arguments argv
    PH.destroy config, options
  when "push"
    options = parse_push_arguments argv
    PH.push config, options
  when "rm"
    options = parse_rm_arguments argv
    PH.rm config, options
  else
    # When the command cannot be identified, display the help guide.
    usage "main", "\nError: Command Not Found: #{argv[0]} \n"
