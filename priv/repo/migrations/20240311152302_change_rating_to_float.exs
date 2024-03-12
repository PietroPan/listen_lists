defmodule ListenLists.Repo.Migrations.ChangeRatingToFloat do
  use Ecto.Migration

  def change do
    alter table("reviews") do
      modify :rating, :float
    end

    alter table("albums") do
      add :rating, :float, default: 0
    end

    alter table("listen_lists") do
      add :active, :boolean, default: false
      add :reveal_interval, :time
      add :reveal_date, :naive_datetime
    end
  end

end
