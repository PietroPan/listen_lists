defmodule ListenLists.Repo.Migrations.AddIsCurrentAlbum do
  use Ecto.Migration

  def change do
    alter table("albums_listen_lists") do
      add :is_current_album, :boolean, default: false
    end
  end
end
