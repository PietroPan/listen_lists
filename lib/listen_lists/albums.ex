defmodule ListenLists.Albums do
  alias ListenLists.Repo

  alias ListenLists.Albums.Album
  alias ListenLists.AlbumsListenLists
  import Ecto.Query

  def create_album(attrs \\ %{}) do
    %Album{}
    |> Album.changeset(attrs)
    |> Repo.insert()
  end

  def get_album!(id), do: Repo.get!(Album, id)

  def check_if_spotify_id_exists(spotify_id) do
    query =
      from a in Album,
      where: a.spotify_id == ^spotify_id,
      select: a
    Repo.exists?(query)
  end

  def get_album_id(spotify_id) do
    query =
      from a in Album,
      where: a.spotify_id == ^spotify_id,
      select: a.id
    Repo.one(query)
  end

  def add_to_listen_list(attrs \\ %{}, listen_list_id) do
    if !check_if_spotify_id_exists(attrs.spotify_id) do
      create_album(attrs)
    end

    album_id = get_album_id(attrs.spotify_id)

    cond do
      AlbumsListenLists.check_if_album_belongs(album_id, listen_list_id) ->
        {:error, :album_already_added}
      true ->
        {:ok, AlbumsListenLists.create_album_listen_list(%{album_id: album_id, listen_list_id: listen_list_id})}
    end
  end

end
