defmodule ExBetter.Client do
  @moduledoc """
  HTTP Client for Better API using Tesla.

  ## Adapter

  To use different Tesla adapter, set it via Mix configuration.

  ```elixir
  config :tesla, ExForce.Client, adapter: Tesla.Adapter.Hackney
  ```
  """

  use Tesla

  # plug(Tesla.Middleware.Logger)
  # plug(Tesla.Middleware.JSON, enable_decoding: ["application/json", engine: Jason])
  plug(Tesla.Middleware.JSON)

  plug(Tesla.Middleware.Retry,
    delay: 500,
    max_retries: 10,
    max_delay: 4_000,
    should_retry: fn
      {:ok, %{status: status}} when status in [400, 500] -> true
      {:ok, _} -> false
      {:error, _} -> true
    end
  )

  @type t :: Tesla.Client.t()
end