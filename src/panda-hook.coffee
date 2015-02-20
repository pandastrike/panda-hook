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
# This function prepare some default values for panda-hook, and it renders the githook template.
prepare_template = (options) ->
  # Defaults
  options.hook_source ||= "scripts/githooks/coreos_restart"
  options.hook_name   ||= "post-receive"
  options.launch_path ||= "launch"

  # Parse Port Info for Hook Server
  temp = options.hook_server.split(":")
  options.hook_server = temp[0]
  options.hook_port = temp[1] || "22"

  # Render Template
  path = resolve __dirname, options.hook_source
  input = readFileSync path, "utf-8"
  contents = render input, options

  options.hook_source = resolve __dirname, "scripts/githooks/temp"
  writeFileSync options.hook_source, contents

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
    exec "bash #{__dirname}/scripts/create #{options.hook_server} #{options.hook_port} #{options.repo_name}"

  # This method deletes the specified repo from the hook-server.
  destroy: (options) ->
    exec "bash #{__dirname}/scripts/destroy #{options.hook_server} #{options.hook_port} #{options.repo_name}"

  # This method places a githook script into a remote repo.
  push: (options) ->
    # Generate default CoreOS post-receive githook, unless given another source.
    options = prepare_template options

    exec "bash #{__dirname}/scripts/push #{options.hook_server} #{options.hook_port} #{options.repo_name} #{options.hook_name}",
      {async: false},
      (code, output) ->
        if code == 1
          # The "push" Bash script cannot add a githook if the repo does not exist.
          # Create it now, then try to push again.
          exec "bash #{__dirname}/scripts/create #{options.hook_server} #{options.hook_port} #{options.repo_name}"
          exec "bash #{__dirname}/scripts/push #{options.hook_server} #{options.hook_port} #{options.repo_name} #{options.hook_name} #{options.hook_source}"

  # This method deletes a githook script from a remote repo.
  rm: (options) ->
    exec "bash #{__dirname}/scripts/rm #{options.hook_server} #{options.hook_port} #{options.repo_name} #{options.hook_name}",
      async:false,
      (code, output) ->
        if code == 1
          # If the requested repo does not exist, warn the user.
          process.stdout.write "\nWARNING: The repository \"#{options.repo_name}\" does not exist.\n\n"
