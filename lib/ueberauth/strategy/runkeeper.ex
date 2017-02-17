defmodule Ueberauth.Strategy.Runkeeper do
  @moduledoc """
  Runkeeper Strategy for Überauth.
  """

  use Ueberauth.Strategy

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra
  alias Ueberauth.Strategy.Runkeeper.OAuth

  @doc """
  Handles initial request for Runkeeper authentication.
  """
  @user_url "https://api.runkeeper.com/user"
  @user_type [{"accept", "application/vnd.com.runkeeper.User+json"}]
  @profile_url "https://api.runkeeper.com/profile"
  @profile_type [{"accept", "application/vnd.com.runkeeper.Profile+json"}]

  def handle_request!(conn) do
    opts = [redirect_uri: callback_url(conn)]
    redirect!(conn, OAuth.authorize_url!(opts))
  end

  @doc """
  Handles the callback from Runkeeper.
  """
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    opts = [code: code, redirect_uri: callback_url(conn)]
    token = OAuth.get_token!(opts)
    if token.access_token do
      conn
      |> put_private(:runkeeper_token, token)
      |> set_user
      |> set_profile
    else
      set_errors!(conn, [error("auth failure", token.other_params["error"])])
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  defp set_user(conn) do
    case get_resource(conn, @user_url, @user_type) do
      {:ok, user} -> put_private(conn, :runkeeper_user, user)
      {:error, error} -> set_errors!(conn, error)
    end
  end

  @doc false
  defp set_profile(conn) do
    case get_resource(conn, @profile_url, @profile_type) do
      {:ok, user} -> put_private(conn, :runkeeper_profile, user)
      {:error, error} -> set_errors!(conn, error)
    end
  end

  @doc false
  defp get_resource(conn, url, type) do
    Ueberauth.Strategy.Runkeeper.OAuth.get(conn.private.runkeeper_token, url, type)
    |> case do
      {:ok, %OAuth2.Response{status_code: status_code, body: body}}
        when status_code in 200..399 ->
        {:ok, Poison.decode!(body)}

      {:ok, %OAuth2.Response{status_code: status_code}}
        when status_code in 400..499 ->
        {:error,[error("token", "unauthorized")]}

      {:error, %OAuth2.Error{reason: reason}} ->
        {:error, [error("OAuth2", reason)]}
    end
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:runkeeper_user, nil)
    |> put_private(:runkeeper_profile, nil)
    |> put_private(:runkeeper_token, nil)
  end

  @doc """
  Fetches the uid field from the response.
  """
  def uid(conn) do
    conn.private.runkeeper_user
    |> Map.fetch!("userID")
    |> Integer.to_string
  end

  @doc """
  Includes the credentials from the runkeeper response.
  """
  def credentials(conn) do
    token = conn.private.runkeeper_token

    %Credentials{
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      refresh_token: token.refresh_token,
      token: token.access_token
    }
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    %Info{name: conn.private.runkeeper_profile["name"]}
  end

  @doc """
  Stores the raw information (including the token) obtained from the runkeeper callback.
  """
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.runkeeper_token,
        user: conn.private.runkeeper_user,
        profile: conn.private.runkeeper_profile
      }
    }
  end
end
