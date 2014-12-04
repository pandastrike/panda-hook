#===============================================================================
# PandaHook - CoreOS Restart
#===============================================================================
# This tool constructs a Bash script to be used as a server-side githook that
# restarts targeted CoreOS services.

#====================
# Modules
#====================
fs = require "fs" # Access to commandline


#===============================
# Module Definition
#===============================
restart =
  build: (argv, config) ->

    # Write the begining, mostly static portion of the script.

    text = "
    #!/usr/bin/bash \n
    #=================================================================================\n
    # CoreOS Restart - Generated by PandaHook https://github.com/pandastrike/pandahook\n
    #=================================================================================\n
    # This Bash script controls the actions of a hook-server. While triggered by a git\n
    # command, this server can taking any addtional action possible on a Linux machine.\n
    \n
    # Restart Functions:\n
    # (1) Perform a clone of the bare** repo we just pushed to, creating a regular repo.\n
    # (2) Use the *.service files in the regular repo to re-deploy CoreOS services.\n
    \n
    # (**)A bare repo has the repository commit history, but no working tree (the actual files).\n
    \n
    echo \"\"\n
    echo \"===================================\"\n
    echo \"Push Detected. Activating Githook.\"\n
    echo \"===================================\"\n
    \n
    echo \"\"\n
    echo \"-----------\"\n
    echo \"Cloning Bare Repo\"\n
    echo \"-----------\"\n
    # Cloning the (freshly updated) bare repo creates a regular one with files we can use.\n
    # First, wipe away any old versions of the regular repo.  Note that our starting directory\n
    # is the repo's root, not the path of the githook script.\n
    cd ..\n
    rm -rf #{argv[6]}\n
    /usr/bin/git clone #{argv[6]}.git #{argv[6]}\n
    cd #{argv[6]}\n\n

    echo \"\"\n
    echo \"-----------\"\n
    echo \"Stopping Service(s)\"\n
    echo \"-----------\"\n"

    fs.writeFileSync "#{process.cwd()}/#{argv[4]}", "#{text}"


    # Now, write the script commands that destroy the specified CoreOS services.
    # We'll need to iterate through the listed services.

    for i in [7..argv.length - 1]
      text = "/usr/bin/fleetctl --tunnel #{config.coreos.address} destroy #{argv[i]}.service\"\n"
      fs.appendFileSync "#{process.cwd()}/#{argv[4]}", "#{text}"


    # Now, pause for a couple seconds to allow this command to register in the CoreOS cluster.
    text = "\n\n
    # It sometimes takes the CoreOS cluster a moment to register your command.  If\n
    # we wait a few seconds, the service will properly begin the termination sequence\n
    # before registering the following \"start\" command.\n
    sleep 5\n\n

    echo \"\"\n
    echo \"-----------\"\n
    echo \"Restarting Service: CoreOS Reflector Demo\"\n
    echo \"-----------\"\n"

    fs.appendFileSync "#{process.cwd()}/#{argv[4]}", "#{text}"

    # Finally, bring the service(s) back online.
    for i in [7..argv.length - 1]
      text = "/usr/bin/fleetctl --tunnel #{config.coreos.address} start #{argv[i]}.service\"\n"
      fs.appendFileSync "#{process.cwd()}/#{argv[4]}", "#{text}"



module.exports = restart
