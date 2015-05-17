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
    deployments = (yield discover context.huxley.url).deployments
    yield deployments.create context

  # This handler updates the status of an existing deployment record.
  update: async (context) ->
    deployments = (yield discover context.huxley.url).deployments
    yield deployments.update context
