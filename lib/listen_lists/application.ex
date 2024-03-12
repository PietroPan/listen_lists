defmodule ListenLists.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ListenListsWeb.Telemetry,
      # Start the Ecto repository
      ListenLists.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ListenLists.PubSub},
      # Start Finch
      {Finch, name: ListenLists.Finch},
      # Start the Endpoint (http/https)
      ListenListsWeb.Endpoint,
      # Start a worker by calling: ListenLists.Worker.start_link(arg)
      # {ListenLists.Worker, arg}
      ListenLists.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ListenLists.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ListenListsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
