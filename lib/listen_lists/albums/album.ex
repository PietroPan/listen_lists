defmodule ListenLists.Albums.Album do
  use Ecto.Schema
  import Ecto.Changeset
  alias ListenLists.Reviews.Review
  alias ListenLists.AlbumsListenLists.AlbumListenList
  alias ListenLists.ListenLists.ListenList

  schema "albums" do
    field :name, :string
    field :image_url, :string
    field :spotify_id, :string
    field :album_url, :string
    field :rating, :float, default: 0.0
    has_many :reviews, Review
    many_to_many(:listen_lists, ListenList, join_through: AlbumListenList, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(album, attrs) do
    album
    |> cast(attrs, [:name, :image_url, :spotify_id, :album_url, :rating])
    |> validate_required([:name, :image_url, :spotify_id, :album_url])
  end
end
