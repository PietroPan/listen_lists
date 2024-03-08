defmodule ListenLists.Repo do
  use Ecto.Repo,
    otp_app: :listen_lists,
    adapter: Ecto.Adapters.Postgres
end
