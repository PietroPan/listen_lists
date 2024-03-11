defmodule ListenLists.AlbumsListenLists do
  alias ListenLists.Repo
  import Ecto.Query
  alias ListenLists.AlbumsListenLists.AlbumListenList

  def create_album_listen_list(attrs \\ %{}) do
    %AlbumListenList{}
    |> AlbumListenList.changeset(attrs)
    |> Repo.insert()
  end

  def check_if_album_belongs(album_id,ll_id) do
    query =
      from a in AlbumListenList,
      where: a.album_id == ^album_id and a.listen_list_id == ^ll_id,
      select: a
    Repo.exists?(query)
  end

  def get_albums_of_list(ll_id) do
    query =
      from a in AlbumListenList,
      where: a.listen_list_id == ^ll_id,
      order_by: [desc: :inserted_at],
      select: a,
      preload: [:album]
    Repo.all(query)
  end

end
