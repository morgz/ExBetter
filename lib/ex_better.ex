defmodule ExBetter do
  @moduledoc """
  Documentation for `ExBetter`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ExBetter.hello()
      :world

  """
  require Logger

  import ExBetter.Client, only: [request: 2]

  @default_user_agent "iPhone"
  @success_codes 200..299

  def client(url, token, opts \\ [])
  def client(:production, token, opts), do: client("https://publicapi-uk01.legendonlineservices.co.uk/", token, opts)
  def client(base_url, token, opts) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Headers, Keyword.get(opts, :headers, [])},
      {Tesla.Middleware.Headers,
      [
        {"User-Agent", @default_user_agent},
        {"Accept-Language", "en-GB;q=1.0"}
      ] ++ case token do # Maybe add the token if it's provided
        nil -> []
        "" -> []
        token -> [{"Authorization", "Bearer " <> token }]
      end
      }
    ]
    Tesla.client(middleware)
  end

  # client = ExBetter.client(:production, "token")
  # client |> ExBetter.current_user
  def current_user(client) do
    url = "contacts/current"

    case request(client, method: :get, url: url) do
      {:ok, %Tesla.Env{status: status, body: body, url: url, method: method}}
      when status in @success_codes ->
        {:ok, body, [{:url, url}, {:status, status}, {:method, method}]}

      {:ok, %Tesla.Env{body: body}} ->
        {:error, body}

      {:error, _} = other ->
        other
    end
  end

  # client = ExBetter.client(:production, "token")
  # client |> ExBetter.sessions(["db9bd7d1-e741-41f2-9a99-7b4bf85cbfce"], "2021-03-29T13:24:44+0000", "2021-03-30T13:24:44+0000")
  # {:ok, _, body} = v
  # body |> Keyword.fetch!(:body)
  def sessions(
    client,
    [_|_] = location_ids,
    date_from,
    date_end,
    opts \\ []
  ) do

    url = "sessions"

    params_map =
      %{
        locationIds: location_ids,
        dateFrom: date_from,
        dateEnd: date_end
      }
      |> Map.merge(Enum.into(opts, %{}))

      case request(
        client,
        method: :post,
        url: url,
        body: params_map
      ) do
        {:ok, %Tesla.Env{status: status, url: url, method: method, body: body}}
        when status in @success_codes ->
          {:ok, [{:url, url}, {:status, status}, {:method, method}, {:body, body}]}
        {:ok, %Tesla.Env{body: body}} ->
          {:error, body}
        {:error, _} = other ->
          other
      end
    end


# client = ExBetter.client(:production, "token")
# client |> ExBetter.session("ae87621e-9865-4347-acc9-f98c1e49afa2")
  def session(client, session_id) do
    url =
      "sessions"
      |> append_path_parameter(session_id)

    case request(client, method: :get, url: url) do
      {:ok, %Tesla.Env{status: status, body: body, url: url, method: method}}
      when status in @success_codes ->
        {:ok, body, [{:url, url}, {:status, status}, {:method, method}]}

      {:ok, %Tesla.Env{body: body}} ->
        {:error, body}

      {:error, _} = other ->
        other
    end
  end

  # client |> ExBetter.reservation("54437531-5c48-4434-ab4d-2d1e13c9b2c1")
  def reservation(client, reservation_id) do
    url =
      "contacts/current/reservations"
      |> append_path_parameter(reservation_id)

    case request(client, method: :get, url: url) do
      {:ok, %Tesla.Env{status: status, body: body, url: url, method: method}}
      when status in @success_codes ->
        {:ok, body, [{:url, url}, {:status, status}, {:method, method}]}
      {:ok, %Tesla.Env{body: body}} ->
        {:error, body}
      {:error, _} = other ->
        other
    end
  end

  # client |> ExBetter.create_reservation("6c53d33b-7ff0-4965-a51a-5a332e6ef23d")
  def create_reservation(client, session_id) do
    url = "sessions"
          |> append_path_parameter(session_id)
          |> append_path_parameter("reservations")

      case request(
        client,
        method: :post,
        url: url,
        body: %{}
      ) do
        {:ok, %Tesla.Env{status: status, url: url, method: method, body: body}}
        when status in @success_codes ->
          {:ok, [{:url, url}, {:status, status}, {:method, method}, {:body, body}]}
        {:ok, %Tesla.Env{body: body}} ->
          {:error, body}
        {:error, _} = other ->
          other
      end
  end

  # client |> ExBetter.cancel_reservation("40497d86-92e0-4553-ab22-a7032cd0347f")
  def cancel_reservation(client, reservation_id) do
    url =
      "contacts/current/reservations"
      |> append_path_parameter(reservation_id)

      case request(
        client,
        method: :patch,
        url: url,
        body: %{"reservationStatus": "Cancelled"}
      ) do
        {:ok, %Tesla.Env{status: status, url: url, method: method, body: body}}
        when status in @success_codes ->
          {:ok, [{:url, url}, {:status, status}, {:method, method}, {:body, body}]}
        {:ok, %Tesla.Env{body: body}} ->
          {:error, body}
        {:error, _} = other ->
          other
      end
  end

  def append_path_parameter(url, nil), do: url

  def append_path_parameter(url, param) do
    url <> "/#{param}"
  end

end
