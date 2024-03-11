defmodule ListenLists.Repo.Migrations.CreateAlbums do
  use Ecto.Migration

  def change do
    create table(:albums) do
      add :name, :string
      add :image_url, :string
      add :spotify_id, :string
      add :album_url, :string

      timestamps()
    end

    create index(:albums, [:spotify_id], unique: true)
  end
end
