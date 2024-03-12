defmodule ListenLists.Repo.Migrations.AddLlCurrentAlbum do
  use Ecto.Migration

  def change do
    alter table("listen_lists") do
      add :current_album_id, references(:albums, on_delete: :nothing)
    end
  end
end
