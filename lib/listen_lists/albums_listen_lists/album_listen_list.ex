defmodule ListenLists.AlbumsListenLists.AlbumListenList do
  use Ecto.Schema
  import Ecto.Changeset

  alias ListenLists.ListenLists.ListenList
  alias ListenLists.Albums.Album
  alias ListenLists.Accounts.User

  schema "albums_listen_lists" do

    field :revealed, :boolean, default: false
    field :is_current_album, :boolean, default: false
    belongs_to :album, Album, primary_key: true
    belongs_to :listen_list, ListenList, primary_key: true
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(album_listen_list, attrs) do
    album_listen_list
    |> cast(attrs, [:album_id, :listen_list_id, :revealed, :is_current_album, :user_id])
    |> validate_required([:album_id, :listen_list_id, :user_id])
    |> foreign_key_constraint(:album_id)
    |> foreign_key_constraint(:listen_list_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:album_id, :listen_list_id], name: :album_listen_list_pkey)
  end
end
