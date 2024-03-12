defmodule ListenLists.Repo.Migrations.AddNameToUser do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :username, :string, default: "Anonymous"
    end

    alter table("albums_listen_lists") do
      add :revealed, :boolean, default: false
    end
  end
end
