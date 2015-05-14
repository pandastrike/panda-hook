#=================================================================================
# Huxley Cluster Githook - Service Configuration
#=================================================================================
# This file contains helper functions related to managing deployment configuration.
{join} = require "path"
{async, read, write, merge} = require "fairmont"
{render} = require "mustache"

{pull_configuration, get_dirs, make_key} = require "./helpers"

module.exports =
  # Pull data from the context that gets rendered when the API server transfers this script to the cluster.
  pull_context: async () ->
    context = yield pull_configuration {name: "context", path: __dirname}
    {app} = context

    app.id = make_key()
    app.status = "starting"
    app.branch = process.argv[2][11..]
    app.path = join process.env.HOME, "repos", app.name
    app.launch = join process.env.HOME, "repos", app.name, "launch"

    context.app = app
    return context

  # Gather services and their relevant information into one package so we can take appropriate action.
  get_services: async (app) ->
    names = yield get_dirs app.launch
    services = {}
    for name in names
      services[name] = yield pull_configuration
        name: name
        path: join app.launch, name

    return services

  # Renders the templates as full text and then writes to file.
  render_template: async (spec) ->
    # Find the template for this service
    input = join spec.launch, spec.service, spec.template
    template = yield read input

    # Render.
    rendered_string = render template, spec

    # Write to file.
    yield write (join spec.launch, spec.service, spec.output), rendered_string
