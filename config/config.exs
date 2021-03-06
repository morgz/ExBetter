use Mix.Config

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
config :tesla, adapter: Tesla.Adapter.Hackney

if Mix.env() != :docs, do: import_config("#{Mix.env()}.exs")
