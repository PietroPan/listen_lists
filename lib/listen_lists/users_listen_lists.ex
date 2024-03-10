defmodule ListenLists.UsersListenLists do
  use Ecto.Schema
  import Ecto.Changeset
  alias ListenLists.Accounts.User
  alias ListenLists.ListenLists.ListenList

  schema "users_listen_lists" do

    belongs_to :user, User, primary_key: true
    belongs_to :listen_list, ListenList, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(users_listen_lists, attrs) do
    users_listen_lists
    |> cast(attrs, [:user_id, :listen_list_id])
    |> validate_required([:user_id, :listen_list_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:listen_list_id)
    |> unique_constraint([:user_id, :listen_list_id], name: :users_listen_lists_pkey)
  end
end
