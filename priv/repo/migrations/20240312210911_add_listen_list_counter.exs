defmodule ListenLists.Repo.Migrations.AddListenListCounter do
  use Ecto.Migration

  def change do
    alter table("listen_lists") do
      add :days_till_reveal, :integer, default: 0
      add :days_between_reveals, :integer, default: 1
    end
  end
end
