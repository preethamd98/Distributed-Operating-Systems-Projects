defmodule Instachat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Instachat.Repo,
      # Start the endpoint when the application starts
      InstachatWeb.Endpoint
      # Starts a worker by calling: Instachat.Worker.start_link(arg)
      # {Instachat.Worker, arg},
    ]

      {:ok,twitter_engine} = GenServer.start_link(TwitterEngine,[])  
      :global.register_name(:twitter,twitter_engine)
      :ets.new(:cidtopid,[:set,:public,:named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Instachat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    InstachatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
