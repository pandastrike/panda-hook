#===============================================================================
# PandaHook - The Ultimate Githook Script Management Tool.
#===============================================================================

#====================
# Modules
#====================
# Core Libraries
{resolve} = require "path"

# PandaStrike Libraries
{async, call, read, write, shell} = require "fairmont" # utility library

# Third Party Libraries
{render} = require "mustache"             # templating


#===============================
# Helpers
#===============================
catch_fail = (f) ->
  try
    f()
  catch e
    throw e

# Enforces configuration defaults if no value is provided.
enforce_defaults = (options) ->
  options.git = {}  unless options.git?
  options.app.launch           ||= "launch"
  options.git.alias            ||= "hook"
  options.hook.source          ||= resolve __dirname, "scripts/githooks/coreos_restart.sh"
  options.hook.name            ||= "post-receive"
  options.hook.accessory       ||= resolve __dirname, "scripts/githooks/coreos_restart"

  # Parse Port Info for Hook Server
  result = options.hook.address.split(":")
  options.hook.address = result[0]
  options.hook.port = result[1] || "22"

  # Parse Port Info for Main Cluster Instance.
  result = options.cluster.address.split(":")
  options.cluster.address = result[0]
  options.cluster.port = result[1] || "22"

  return options

# This function renders the config file of the githook template.
# TODO: Make this not hard-coded to the "CoreOS Restart" githook.
prepare_template = async (options) ->
  # Render Template
  path = resolve __dirname, "scripts/githooks/coreos_restart/context.template"
  input = yield read path
  contents = render input, options

  output_path = resolve __dirname, "scripts/githooks/coreos_restart/context.yaml"
  yield write output_path, contents


#===============================
# panda-hook Definition
#===============================
module.exports =
  # For now, we rely on small, easily maintainable Bash scripts for shell calls.
  # This is to deal with the ugliness of issuing shell commands inside an SSH command.

  # This method clones a bare repo on the hook-server.
  create: async (options) ->
    catch_fail ->
      options = enforce_defaults options
      {git, hook, app}

      command = "bash #{__dirname}/scripts/create " +
        "#{hook.address} #{hook.port} #{app.name} #{git.alias}"
      {stdout} = yield shell command
      console.log stdout


  # This method deletes the specified repo from the hook-server.
  destroy: async (options) ->
    catch_fail ->
      options = enforce_defaults options
      {app, hook} = options

      command = "bash #{__dirname}/scripts/destroy " +
        "#{hook.address} #{hook.port} #{app.name}"
      {stdout} = yield shell command
      console.log stdout

  # This method places a githook script into a remote repo.
  push: async (options) ->
    catch_fail ->
      options = enforce_defaults options

      # Generate default CoreOS post-receive githook, unless given another source.
      options = yield prepare_template options
      {git, hook, app} = options

      command_push = "bash #{__dirname}/scripts/push "+
        "#{hook.address} #{hook.port} #{app.name} #{hook.name} #{hook.source} #{hook.accessory} #{git.alias}"
      try
        {stdout} = yield shell command
        console.log stdout
      catch
        # The "push" Bash script cannot add a githook if the repo does not exist.
        # Create it now, then try to push again.
        command_create = "bash #{__dirname}/scripts/create " +
          "#{hook.address} #{hook.port} #{app.name} #{git.alias}"
        {stdout} = yield shell command_create
        console.log stdout
        {stdout} = yield shell command_push
        console.log stdout


  # This method deletes a githook script from a remote repo.
  rm: async (options) ->
    catch_fail ->
      options = enforce_defaults options
      {hook, app}

      command = "bash #{__dirname}/scripts/rm "+
        "#{hook.address} #{hook.port} #{app.name} #{hook.name}"
      try
        {stdout} = yield shell command
        console.log stdout
      catch
        # If the requested repo does not exist, warn the user.
        process.stdout.write "\nWARNING: The repository \"#{app.name}\" does not exist.\n\n"
