#===============================================================================
# PandaHook - The Ultimate Githook Script Management Tool.
#===============================================================================

#====================
# Modules
#====================
# Core Libraries
{resolve} = require "path"

# PandaStrike Libraries
{read, write, shell} = require "fairmont" # utility library

# Third Party Libraries
{render} = require "mustache"             # templating
{call} = require "when/generator"         # promises
async = (require "when/generator").lift

# Components
builder = require "./build/build"         # Githook Script Generator

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
  options.launch_path          ||= "launch"
  options.remote_alias         ||= "hook"
  options.hook_source          ||= resolve __dirname, "scripts/githooks/coreos_restart.sh"
  options.hook_name            ||= "post-receive"
  options.hook_accessory       ||= resolve __dirname, "scripts/githooks/coreos_restart"

  # Parse Port Info for Hook Server
  result = options.hook_address.split(":")
  options.hook_address = result[0]
  options.hook_port = result[1] || "22"

  if options.cluster_address?
    # Parse Port Info for Main Cluster Instance.
    result = options.cluster_address.split(":")
    options.cluster_address = result[0]
    options.cluster_port = result[1] || "22"

  return options

# This function prepare some default values for panda-hook, and it renders the githook template.
# TODO: Make this not hard-coded to the "CoreOS Restart" githook.
prepare_template = async (options) ->
  # Render Template
  path = resolve __dirname, "scripts/githooks/coreos_restart/coreos_restart.template"
  input = yield read path
  contents = render input, options

  output_path = resolve __dirname, "scripts/githooks/coreos_restart/coreos_restart.coffee"
  yield write output_path, contents

  return options


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
      command = "bash #{__dirname}/scripts/create #{options.hook_address} " +
                "#{options.hook_port} #{options.repo_name} #{options.remote_alias}"
      {stdout} = yield shell command
      console.log stdout


  # This method deletes the specified repo from the hook-server.
  destroy: async (options) ->
    catch_fail ->
      options = enforce_defaults options
      command = "bash #{__dirname}/scripts/destroy #{options.hook_address} " +
                "#{options.hook_port} #{options.repo_name}"
      {stdout} = yield shell command
      console.log stdout

  # This method places a githook script into a remote repo.
  push: async (options) ->
    catch_fail ->
      options = enforce_defaults options

      # Generate default CoreOS post-receive githook, unless given another source.
      options = yield prepare_template options

      command_push = "bash #{__dirname}/scripts/push #{options.hook_address} #{options.hook_port} "+
                "#{options.repo_name} #{options.hook_name} #{options.hook_source} " +
                "#{options.hook_accessory} #{options.remote_alias}"
      try
        {stdout} = yield shell command
        console.log stdout
      catch
        # The "push" Bash script cannot add a githook if the repo does not exist.
        # Create it now, then try to push again.
        command_create = "bash #{__dirname}/scripts/create #{options.hook_address} #{options.hook_port} "+
                  "#{options.repo_name} #{options.remote_alias}"
        {stdout} = yield shell command_create
        console.log stdout
        {stdout} = yield shell command_push
        console.log stdout


  # This method deletes a githook script from a remote repo.
  rm: async (options) ->
    catch_fail ->
      options = enforce_defaults options
      command = "bash #{__dirname}/scripts/rm #{options.hook_address} #{options.hook_port} "+
                "#{options.repo_name} #{options.hook_name}"
      try
        {stdout} = yield shell command
        console.log stdout
      catch
        # If the requested repo does not exist, warn the user.
        process.stdout.write "\nWARNING: The repository \"#{options.repo_name}\" does not exist.\n\n"
