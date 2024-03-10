defmodule ListenLists.ListenLists.ListenList do
  use Ecto.Schema
  import Ecto.Changeset
  alias ListenLists.Accounts.User
  alias ListenLists.UsersListenLists

  schema "listen_lists" do
    field :name, :string
    field :description, :string
    field :password, :string
    field :image_path, :string
    many_to_many(:users, User, join_through: UsersListenLists, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(listen_list, attrs) do
    listen_list
    |> cast(attrs, [:name, :image_path, :description, :password])
    |> validate_required([:name, :description, :password])
  end
end
