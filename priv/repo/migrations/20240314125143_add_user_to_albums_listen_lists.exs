defmodule ListenLists.Repo.Migrations.AddUserToAlbumsListenLists do
  use Ecto.Migration

  def change do
    alter table("albums_listen_lists") do
      add :user_id, references(:users, on_delete: :nothing)
    end
  end
end
