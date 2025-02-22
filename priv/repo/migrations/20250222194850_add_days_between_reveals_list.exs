defmodule ListenLists.Repo.Migrations.AddDaysBetweenRevealsList do
  use Ecto.Migration

  def change do
    alter table("listen_lists") do
      add :days_between_reveals_i, :integer, default: 0
      remove :days_between_reveals
      add :days_between_reveals, {:array, :integer}, default: [1]
    end
  end
end
