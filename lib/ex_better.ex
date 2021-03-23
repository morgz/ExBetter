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

  def client(:production, token, opts),
  do: client("https://publicapi-uk01.legendonlineservices.co.uk/", token, opts)

  def client(base_url, token, opts) do

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Headers, Keyword.get(opts, :headers, [])},
      {Tesla.Middleware.Headers, [
        {"Authorization", "Bearer " <> token },
        {"User-Agent", @default_user_agent},
        {"Accept-Language", "en-GB;q=1.0"}
      ]}
    ]

    Tesla.client(middleware)
  end

  # client = ExBetter.client(:production, "token")
  # client |> ExBetter.sessions(["db9bd7d1-e741-41f2-9a99-7b4bf85cbfce"], "2021-03-29T13:24:44+0000", "2021-03-30T13:24:44+0000")
  # {:ok, _, body} = v
  # body |> Keyword.fetch!(:body)
  @spec sessions(
          Tesla.Client.t(),
          nonempty_maybe_improper_list,
          any,
          any,
          any,
          any,
          any,
          map
        ) ::
          {:error, any}
          | {:ok, nil | binary,
             [
               {:method, :delete | :get | :head | :options | :patch | :post | :put | :trace}
               | {:status, 1..1_114_111}
               | {:url, binary},
               ...
             ]}
  def sessions(
    client,
    [_|_] = location_ids,
    date_from,
    date_end,
    until_midnight_in_days \\ 1,
    page_no \\ 1,
    page_size \\ 10,
    opts \\ %{}
  ) do

    url = "sessions"

    params_map =
      %{
        locationIds: location_ids,
        dateFrom: date_from,
        dateEnd: date_end,
        untilMidnightInDays: until_midnight_in_days,
        pageNo: page_no,
        pageSize: page_size
      }
      |> Map.merge(opts)

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

  def append_path_parameter(url, nil), do: url

  def append_path_parameter(url, param) do
    url <> "/#{param}"
  end

end
