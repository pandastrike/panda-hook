#=================================================================================
# Huxley Cluster Githook - API Interface
#=================================================================================
# This file contains code that draws from PBX to form a client that can send
# information to the Huxley API server.

{async} = require "fairmont"
{discover} = (require "pbx").client

module.exports =
  # This handler creates a new deployment record.
  create:

  # This handler updates the status of an existing deployment record.
  update:
