defmodule ListenLists.Repo.Migrations.AddRevealMode do
  use Ecto.Migration

  def change do
    alter table("listen_lists") do
      add :reveal_mode, :integer, default: 0
      remove :priority_mode
    end
  end
end
