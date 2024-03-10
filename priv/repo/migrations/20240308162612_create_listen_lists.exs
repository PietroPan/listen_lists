defmodule ListenLists.Repo.Migrations.CreateListenLists do
  use Ecto.Migration

  def change do
    create table(:listen_lists) do
      add :name, :string
      add :image_path, :string
      add :description, :text
      add :password, :string

      timestamps()
    end
  end
end
