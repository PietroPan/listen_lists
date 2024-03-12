defmodule ListenLists.ListenLists.ListenList do
  use Ecto.Schema
  import Ecto.Changeset
  alias ListenLists.Accounts.User
  alias ListenLists.UsersListenLists
  alias ListenLists.AlbumsListenLists.AlbumListenList
  alias ListenLists.Albums.Album

  schema "listen_lists" do
    field :name, :string
    field :description, :string
    field :password, :string
    field :image_path, :string
    field :active, :boolean, default: false
    field :reveal_interval, :time
    field :reveal_date, :naive_datetime
    field :days_till_reveal, :integer, default: 0
    field :days_between_reveals, :integer, default: 1
    field :current_album_id, :id
    many_to_many(:users, User, join_through: UsersListenLists, on_replace: :delete)
    many_to_many(:albums, Album, join_through: AlbumListenList, on_replace: :delete)


    timestamps()
  end

  @doc false
  def changeset(listen_list, attrs) do
    listen_list
    |> cast(attrs, [:name, :image_path, :description, :password, :active, :reveal_interval, :reveal_date, :current_album_id, :days_till_reveal, :days_between_reveals])
    |> validate_required([:name, :description, :password])
    |> foreign_key_constraint(:current_album_id, [name: :listen_lists_current_album_id_fkey])
  end
end
