#=================================================================================
# Huxley Cluster Githook - Deployment Status Monitoring
#=================================================================================
# This file contains helper functions meant to access the main cluster, parse
# output from fleetctl and deliver status information to the Huxley API server.

{async, shell, sleep, collect, map} = require "fairmont"
api = require "./api"


get_status = async (cluster, services) ->
  # Query the cluster's fleetctl tool for information about services.
  {stdout} = yield shell "/usr/bin/ssh -A " +
            "-o StrictHostKeyChecking=no " +
            "-o UserKnownHostsFile=/dev/null " +
            "-p #{cluster.port} #{cluster.address} " +
            "/usr/bin/fleetctl list-units"

  # Parse the output for structured data.
  data = stdout.split("\n")[1..]
  status = {}
  for line in data
    continue if line == ""

    fields = line.split "\t"
    name = fields[0][...-8]

    # Save service status, ignoring those not part of this deployment.
    if name in services
      status[name] = fields[2]
    else
      continue


  return status

# Monitor the services as they spin-up.
monitor = async (context, services) ->
  {cluster} = context
  while true
    # Read the status of all services.
    status = yield get_status cluster, services

    # Check for success. All services must be "active" to pass, but a single
    # failure ruins the whole thing.
    is_active = (x) -> x == "active"
    is_failed = (x) -> x == "failed"
    success = collect map is_active, status
    failure = collect map is_failed, status

    if true in failure
      return false        # Failure detected. All is lost, haha.
    else if false !in success
      return true         # *All* services are online and ready.
    else
      yield sleep 10000   # Continue polling.

module.exports = {monitor}
