#===============================================================================
# PandaHook - The Ultimate Githook Script Management Tool.
#===============================================================================

#====================
# Modules
#====================
{readFileSync, writeFileSync} = require "fs"
{resolve} = require "path"

builder = require "./build/build"         # Githook Script Generator

{render} = require "mustache"             # Awesome templating
{exec} = require "shelljs"                # Access to commandline


#===============================
# Helpers
#===============================
# This fucntion enforces configuration defaults if no value is provided.
# file_fields array is used to loop quickly push and remove files
file_fields = [ "hook" ]
use_defaults = (options) ->
  options.launch_path          ||= "launch"
  options.remote_alias         ||= "hook"
  options.hook_source          ||= resolve __dirname, "scripts/githooks/coreos_restart.sh"
  options.hook_name            ||= "post-receive"
  options.accessory_dir_path   ||= resolve __dirname, "scripts/githooks/coreos_restart"

  return options

# This function prepare some default values for panda-hook, and it renders the githook template.
prepare_template = (options) ->
  # Defaults
  options = use_defaults options

  # Parse Port Info for Hook Server
  result = options.hook_address.split(":")
  options.hook_address = result[0]
  options.hook_port = result[1] || "22"

  # Parse Port Info for Main Cluster Instance.
  result = options.cluster_address.split(":")
  options.cluster_address = result[0]
  options.cluster_port = result[1] || "22"

  # Render Template
  path = resolve __dirname, "scripts/githooks/coreos_restart/coreos_restart.template"
  input = readFileSync path, "utf-8"
  contents = render input, options

  output_path = resolve __dirname, "scripts/githooks/coreos_restart/coreos_restart.coffee"
  writeFileSync output_path, contents

  return options


#===============================
# PandaHook Definition
#===============================
module.exports =
  # For now, we rely on small, easily maintainable Bash scripts for shell calls.
  # This is to deal with the ugliness of issuing shell commands inside an SSH command.


  # # This method automates the process of writing githook scripts.
  # # It's body is maintained in the "build" directory.
  # build: (options) ->
  #   builder.main config, options

  # This method clones a bare repo on the hook-server.
  create: (options) ->
    exec "bash #{__dirname}/scripts/create #{options.hook_address} #{options.hook_port} #{options.repo_name} #{options.remote_alias}"

  # This method deletes the specified repo from the hook-server.
  destroy: (options) ->
    exec "bash #{__dirname}/scripts/destroy #{options.hook_address} #{options.hook_port} #{options.repo_name}"

  # This method places a githook script into a remote repo.
  push: (options) ->
    # Generate default CoreOS post-receive githook, unless given another source.
    options = prepare_template options

    exec "bash #{__dirname}/scripts/push #{options.hook_address} #{options.hook_port} #{options.repo_name} 
               #{options.hook_name} #{options.hook_source} #{options.accessory_dir_path} #{options.remote_alias}",
      {async: false},
      (code, output) ->
        if code == 1
          # The "push" Bash script cannot add a githook if the repo does not exist.
          # Create it now, then try to push again.
          exec "bash #{__dirname}/scripts/create #{options.hook_address} #{options.hook_port} #{options.repo_name} #{options.remote_alias}"
          exec "bash #{__dirname}/scripts/push #{options.hook_address} #{options.hook_port} #{options.repo_name} 
                     #{options.hook_name} #{options.hook_source} #{options.accessory_dir_path} #{options.remote_alias}"

  # This method deletes a githook script from a remote repo.
  rm: (options) ->

    exec "bash #{__dirname}/scripts/rm #{options.hook_address} #{options.hook_port} #{options.repo_name} #{options.hook_name}",
      {async: false},
      (code, output) ->
        if code == 1
          # If the requested repo does not exist, warn the user.
          process.stdout.write "\nWARNING: The repository \"#{options.repo_name}\" does not exist.\n\n"
