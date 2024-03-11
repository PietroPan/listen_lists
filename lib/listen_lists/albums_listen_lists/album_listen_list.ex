defmodule ListenLists.AlbumsListenLists.AlbumListenList do
  use Ecto.Schema
  import Ecto.Changeset

  alias ListenLists.ListenLists.ListenList
  alias ListenLists.Albums.Album

  schema "albums_listen_lists" do

    belongs_to :album, Album, primary_key: true
    belongs_to :listen_list, ListenList, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(album_listen_list, attrs) do
    album_listen_list
    |> cast(attrs, [:album_id, :listen_list_id])
    |> validate_required([:album_id, :listen_list_id])
    |> foreign_key_constraint(:album_id)
    |> foreign_key_constraint(:listen_list_id)
    |> unique_constraint([:album_id, :listen_list_id], name: :album_listen_list_pkey)
  end
end
