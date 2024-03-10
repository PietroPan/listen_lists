defmodule ListenLists.Repo.Migrations.CreateUsersListenLists do
  use Ecto.Migration

  def change do
    create table(:users_listen_lists) do
      add :user_id, references(:users, on_delete: :nothing)
      add :listen_list_id, references(:listen_lists, on_delete: :nothing)

      timestamps()
    end

    create index(:users_listen_lists, [:user_id])
    create index(:users_listen_lists, [:listen_list_id])
    create(unique_index(:users_listen_lists, [:user_id, :listen_list_id]))
  end
end
