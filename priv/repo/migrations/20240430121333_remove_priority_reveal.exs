defmodule ListenLists.Repo.Migrations.RemovePriorityReveal do
  use Ecto.Migration

  def change do
    alter table("listen_lists") do
      remove :priority_reveal
    end
  end
end
