defmodule ListenLists.Repo.Migrations.CreateAlbumsListenLists do
  use Ecto.Migration

  def change do
    create table(:albums_listen_lists) do
      add :album_id, references(:albums, on_delete: :nothing)
      add :listen_list_id, references(:listen_lists, on_delete: :nothing)

      timestamps()
    end

    create index(:albums_listen_lists, [:album_id])
    create index(:albums_listen_lists, [:listen_list_id])
    create(unique_index(:albums_listen_lists, [:album_id, :listen_list_id]))
  end
end
