# Überauth Runkeeper

> Runkeeper OAuth2 strategy for Überauth.

## Installation

1. Setup your application at [Runkeeper Developer Site](https://runkeeper.com/up/developer/).

1. Add `:ueberauth_runkeeper` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_runkeeper, "~> 1.0"}]
    end
    ```

1. Make sure the application is started in mix.exs

    For Elixir 1.4+:
    ```elixir
    def application do
      [extra_applications: [:ueberauth_runkeeper]]
    end
    ```
    For older versions
    ```elixir
    def application do
      [applications: [:ueberauth_runkeeper]]
    end
    ```

1. Add Runkeeper to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        runkeeper: {Ueberauth.Strategy.Runkeeper, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Runkeeper.OAuth,
      client_id: System.get_env("RUNKEEPER_CLIENT_ID"),
      client_secret: System.get_env("RUNKEEPER_CLIENT_SECRET")
    ```

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initiate the request through:

    /auth/runkeeper

## License

Please see [LICENSE](https://github.com/tsubery/ueberauth_runkeeper/blob/master/LICENSE) for licensing details.
