defmodule ListenLists.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :comment, :text
      add :rating, :integer
      add :user_id, references(:users, on_delete: :nothing)
      add :album_id, references(:albums, on_delete: :nothing)

      timestamps()
    end

    create index(:reviews, [:user_id])
    create index(:reviews, [:album_id])
  end
end
