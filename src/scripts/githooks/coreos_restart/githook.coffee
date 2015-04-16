#=================================================================================
# Huxley Cluster Githook - CoreOS Restart
#=================================================================================
# Algorithm:
# (1) Perform a clone of the "bare" repo we just pushed to, creating a regular repo.
# (2) Use the *.service files in the regular repo to re-deploy CoreOS services.

# Core Libraries
fs = require "fs"
{resolve, join} = require "path"

# Panda Strike Libraries
Configurator = require "panda-config"     # configuration
{call, shell, sleep} = require "fairmont" # panda-utility belt

# Githook components
api = require "./api"
{print_banner} = require "./helpers"
{pull_context, get_services, render_template} = require "./config"
{monitor} = require "./status"

#===============================================================================
call ->
  # Pull Cluster and Application level context.
  print_banner "Push Detected. Activating Githook."
  context = yield pull_context()
  {app, cluster} = context

  # Use this context to create a record in the Huxley API server.
  yield api.create context

  # Cloning the (freshly updated) bare repo creates a regular one, with a working tree we can actually use.
  print_banner "Cloning Bare Repo"
  yield shell "rm -rf #{app.path}"
  yield shell "/usr/bin/git clone -b #{app.branch} -- #{process.env.HOME}/repos/#{app.name}.git #{app.path}"

  # Identify the services we're dealing with.  Every sub-directory of "launch" is a separate service.
  services = yield get_services app, cluster

  # Stop every service.
  print_banner "Stopping Service(s)"
  for service of services
    console.log "Stopping #{service}"
    command = "/usr/bin/ssh -A -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null " +
              "-p #{cluster.port} #{cluster.address} " +
              "/usr/bin/fleetctl destroy #{service}.service;"
    yield shell command

  # It sometimes takes the CoreOS cluster a moment to register your command, leading to a race-condition.
  # If we wait a few seconds, fleetctl properly begins termination before accepting our "start" command.
  yield sleep 5000

  # Bring the service(s) back online. Start by rendering the service templates.
  print_banner "Restarting Service(s)"
  for service of services
    # Grab configuration for specific service.
    {config} = services[service]

    # Render Service File
    config.template = "#{service}.service.template"
    config.output = "#{service}.service"
    yield render_template config

    # Render Dockerfile
    config.template = "Dockerfile.template"
    config.output = "Dockerfile"
    yield render_template config


  # Don't forget to commit the rendered service files so the cluster can use them.
  try
    command = "GIT_DIR=#{join app.path, ".git"} && " +
              "cd #{app.path} && " +
              "git config --global user.email 'huxley@#{app.name}.cluster' && " +
              "git config --global user.name 'huxley agent' && " +
              "git add -A && " +
              "git commit -m 'rendered templates'"
    yield shell command
  catch error
    console.log error


  for service of services
    {port, address} = cluster
    # Wipe away the scratch space used by hook server.
    command = "/usr/bin/ssh -A -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null " +
              "-p #{port} #{address} sudo rm -rf prelaunch/#{service}"
    yield shell command

    # Copy the service files to the scratch space on the cluster
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null " +
              "-P #{port} -r #{app.path}/launch/#{service} " +
              "#{address}:/home/core/prelaunch/"
    yield shell command

    # Use fleetctl to start the services.  Point it at the service files in the scratch space.
    console.log "Spinning Up #{service}"
    command = "/usr/bin/ssh -A -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null " +
              "-p #{port} #{address} " +
              "/usr/bin/fleetctl start prelaunch/#{service}/#{service}.service"
    yield shell command


  # Monitor the services as they spin-up.
  print_banner "Service(s) Initialized...  Waiting on Deployment."
  result = yield monitor context, services
  if result then context.app.status = "online" else context.app.status = "failed"

  yield api.update context
  if result then console.log "Ready." else console.log "Failure."
