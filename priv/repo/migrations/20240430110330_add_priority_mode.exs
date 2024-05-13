defmodule ListenLists.Repo.Migrations.AddPriorityMode do
  use Ecto.Migration

  def change do
    alter table("listen_lists") do
      add :priority_mode, :integer, default: 0
    end
  end
end
