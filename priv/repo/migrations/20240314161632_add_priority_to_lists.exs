defmodule ListenLists.Repo.Migrations.AddPriorityToLists do
  use Ecto.Migration

  def change do
    alter table("listen_lists") do
      add :priority_reveal, :boolean, default: false
    end

    alter table("users_listen_lists") do
      add :priority, :integer, default: 1
    end
  end
end
