#===============================================================================
# PandaHook - The Ultimate Githook Script Management Tool.
#===============================================================================

#====================
# Modules
#====================
{argv} = process
{resolve} = require "path"
{read, write} = require "fairmont" # Easy file read/write
{parse} = require "c50n"           # .cson file parsing
{exec} = require "shelljs"         # Access to commandline

builder = require "./build/build"    # Githook Script Generator

# Extract any configuration settings from the dotfile located in the user's home directory.
config = parse( read( resolve( process.env.HOME, ".pandahook.cson")))

#====================
# Helper Fucntions
#====================
usage = (entry, message) ->
  if message?
    process.stderr.write "#{message}\n"

  process.stderr.write( read( resolve( __dirname, "..", "doc", entry ) ) )
  process.exit -1

#===============================
# Top-Level Command Definitions
#===============================
# These are simple for now, but each top-level command is left separate so
# there is room to develop additional sophistication in the future.


# This command clones a bare repo on the hook-server.
create = (argv) ->
  # Check the command arguments.  Deliver an info blurb if needed.
  if argv.length == 3 or argv[3] == "help"
    usage "create"

  # Let's begin. Create the bare repo.  We rely on a small, easily maintainable
  # Bash script to deal with the ugliness of issuing shell commands inside an SSH command.
  exec "bash #{__dirname}/scripts/create #{config.hookServer.address} #{argv[3]}"

# This command deletes the specified repo from the hook-server.
destroy = (argv) ->
  # Check the command arguments.  Deliver an info blurb if needed.
  if argv.length == 3 or argv[3] == "help"
    usage "destroy"

  # Let's begin. Delete the bare repo and its clone.  We rely on a small, easily maintainable
  # Bash script to deal with the ugliness of issuing shell commands inside an SSH command.
  exec "bash #{__dirname}/scripts/destroy #{config.hookServer.address} #{argv[3]}"

# This command places a githook script into a remote repo.
push = (argv) ->
  # Check the command arguments.  Deliver an info blurb if needed.
  if argv.length == 3 or argv.length == 4 or argv[3] == "help"
    usage "push"

  # Let's begin. Place the githook into the remote repo and make it executable. We rely on a
  # small Bash script to deal with the ugliness of issuing shell commands inside an SSH command.
  exec "bash #{__dirname}/scripts/push #{config.hookServer.address} #{argv[3]} #{argv[4]}",
    async:false,
    (code, output) ->
      if code == 1
        # The "push" Bash script cannot add a githook if the repo does not exist.
        # Create it now, then try to push again.
        exec "bash #{__dirname}/scripts/create #{config.hookServer.address} #{argv[3]}"
        exec "bash #{__dirname}/scripts/push #{config.hookServer.address} #{argv[3]} #{argv[4]}"

# This command deletes a githook script from a remote repo.
rm = (argv) ->
  # Check the command arguments.  Deliver an info blurb if needed.
  if argv.length == 3 or argv.length == 4 or argv[3] == "help"
    usage "rm"

  # Let's begin. Place the githook into the remote repo and make it executable. We rely on a
  # small Bash script to deal with the ugliness of issuing shell commands inside an SSH command.
  exec "bash #{__dirname}/scripts/rm #{config.hookServer.address} #{argv[3]} #{argv[4]}",
    async:false,
    (code, output) ->
      if code == 1
        # If the requested repo does not exist, warn the user.
        process.stdout.write "\nWARNING: The repository \"#{argv[3]}\" does not exist.\n\n"

#===============================================================================
# Main
#===============================================================================
# First, check the command arguments.  Deliver an info blurb if neccessary.
if argv.length == 2 or argv[2] == "help"
  usage "main"
  process.exit -1


# Now, look for the top-level commands.
switch argv[2]
  when "build"
    # This command automates the process of writing githook scripts.  Its construction is
    # modular and separate from this file so that it remains extensible and easily modified.
    builder.main argv, config

  when "create"
    create argv
  when "destroy"
    destroy argv
  when "push"
    push argv
  when "rm"
    rm argv
  else
    # When the command cannot be identified, display the help guide.
    usage "main", "\nError: Command Not Found: #{argv[2]} \n"
