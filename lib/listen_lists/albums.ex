defmodule ListenLists.Albums do
  alias ListenLists.Repo

  alias ListenLists.Albums.Album
  alias ListenLists.Accounts.User
  alias ListenLists.AlbumsListenLists
  alias ListenLists.AlbumsListenLists.AlbumListenList
  alias ListenLists.Reviews.Review
  alias ListenLists.UsersListenLists
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

  def get_reviews(album_id) do
    query =
      from r in Review,
      where: r.album_id == ^album_id,
      select: r,
      order_by: [desc: :inserted_at],
      preload: [:user]
    Repo.all(query)
  end

  def get_list_reviews(album_id, ll_id) do
    query =
      from u in UsersListenLists,
      where: u.listen_list_id == ^ll_id

    query =
      from u in query,
      join: r in Review, on: r.user_id == u.user_id,
      select: r
    reviews = Repo.all(query)

    ratings =
      reviews
      |> Enum.map(fn x -> x.rating end)

    {reviews |> Repo.preload(:user), Float.round(Enum.sum(ratings)/length(ratings),2)}
  end


  #ListenLists.Albums.get_list_reviews(3,10)

  def calculate_album_rating(album_id) do
    query =
      from r in Review,
      where: r.album_id == ^album_id,
      select: r.rating
    ratings = Repo.all(query)
    get_album!(album_id)
    |> Ecto.Changeset.change(rating: Float.round(Enum.sum(ratings)/length(ratings),2))
    |> Repo.update()
  end

end
