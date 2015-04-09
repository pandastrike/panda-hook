#=================================================================================
# Huxley Cluster Githook - Deployment Status Monitoring
#=================================================================================
# This file contains helper functions meant to access the main cluster, parse
# output from fleetctl and deliver status information to the Huxley API server.

{async} = require "fairmont"
api = require "./api"

module.exports =
  
