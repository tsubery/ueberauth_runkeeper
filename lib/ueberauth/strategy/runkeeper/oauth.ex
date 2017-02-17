defmodule Ueberauth.Strategy.Runkeeper.OAuth do
  @moduledoc """
  OAuth2 for Runkeeper.
  """
  use OAuth2.Strategy

  @defaults [
     strategy: __MODULE__,
     site: "https://api.runkeeper.com",
     authorize_url: "https://runkeeper.com/apps/authorize",
     token_url: "https://runkeeper.com/apps/token"
   ]

  @doc """
  Construct a client for requests to Runkeeper.

  This will be setup automatically for you in `Ueberauth.Strategy.Runkeeper`.

  These options are only useful for usage outside the normal callback phase of Ueberauth.
  """
  def client(opts \\ []) do
    config = Application.fetch_env!(:ueberauth, Ueberauth.Strategy.Runkeeper.OAuth)

    opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)

    OAuth2.Client.new(opts)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth. No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  def get(token, url, headers \\ [], opts \\ []) do
    client([token: token])
    |> put_param("client_secret", client().client_secret)
    |> OAuth2.Client.get(url, headers, opts)
  end

  def get_token!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.get_token!(params)
    |> Map.get(:token)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param("client_secret", client.client_secret)
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
