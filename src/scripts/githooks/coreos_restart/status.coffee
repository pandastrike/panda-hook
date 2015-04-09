#=================================================================================
# Huxley Cluster Githook - Deployment Status Monitoring
#=================================================================================
# This file contains helper functions meant to access the main cluster, parse
# output from fleetctl and deliver status information to the Huxley API server.

{async, shell, sleep} = require "fairmont"
api = require "./api"


get_status = async (cluster) ->
  # Query the cluster's fleetctl tool for information about services.
  command = "/usr/bin/ssh -A -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null " +
            "-p #{cluster.port} #{cluster.address} " +
            "/usr/bin/fleetctl list-units"
  {stdout} = yield shell command

  # Parse the output for structured data.
  stdout = stdout.split "\n"
  for i in [0..(stdout.length - 1)]
    if stdout[i] == "UNIT\tMACHINE\tACTIVE\tSUB"
      data = stdout[(i + 1)..]
      break

  status = {}
  for line in data
    continue if line == ""
    line = line.split "\t"
    status[line[0][..-9]] = line[2]

  console.log status


# Monitor the services as they spin-up.
monitor = async (context, services) ->
  {cluster} = context
  for i in [0..12]
    yield get_status cluster
    sleep 10000

module.exports = {get_status, monitor}
