#=================================================================================
# Huxley Cluster Githook - API Interface
#=================================================================================
# This file contains code that draws from PBX to form a client that can send
# information to the Huxley API server.

{async} = require "fairmont"
{discover} = (require "pbx").client

module.exports =
  # This handler creates a new deployment record.
  create: async (context) ->
    deployments = (discover context.huxley.url).deployments
    yield dexployments.create context

  # This handler updates the status of an existing deployment record.
  update: async (context) ->
    deployment = (discover context.huxley.url).deployment
    yield deployment.update context
