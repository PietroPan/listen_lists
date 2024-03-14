defmodule ListenLists.ListenListss do
  alias ListenLists.ListenLists.ListenList
  alias ListenLists.UsersListenLists
  alias ListenLists.AlbumsListenLists.AlbumListenList

  alias ListenLists.Repo
  import Ecto.Query
  require Logger


  def create_listen_list(attrs \\ %{}) do
    %ListenList{}
    |> ListenList.changeset(attrs)
    |> Repo.insert()
  end

  def get_listen_list!(id), do: Repo.get!(ListenList, id)

  def create_listen_list_with_id(listen_lists \\ %{}, user_id) do
    listen_list = %ListenList{}
    |> ListenList.changeset(listen_lists)
    |> Repo.insert!()

    %UsersListenLists{}
    |> UsersListenLists.changeset(%{user_id: user_id, listen_list_id: listen_list.id})
    |> Repo.insert()
  end

  def delete_listen_list(%ListenList{} = listen_list) do
    Repo.delete(listen_list)
  end

  def list_listen_lists() do
    query =
      from l in ListenList,
      select: l,
      order_by: [desc: :inserted_at],
      preload: [:users]
    Repo.all(query)
  end

  def list_your_listen_lists(user_id) do
    query =
      from l in ListenList,
      join: u in UsersListenLists, on: u.listen_list_id == l.id,
      select: l,
      where: u.user_id == ^user_id,
      order_by: [desc: :inserted_at],
      preload: [:users]
    Repo.all(query)
  end

  def check_if_user_belongs(user_id,ll_id) do
    query =
      from l in UsersListenLists,
      where: l.user_id == ^user_id and l.listen_list_id == ^ll_id,
      select: l
    Repo.exists?(query)
  end

  def add_user_to_listen_list(user_id,ll_id) do
    %UsersListenLists{}
    |> UsersListenLists.changeset(%{user_id: user_id, listen_list_id: ll_id})
    |> Repo.insert()
  end

  def get_current_album(ll_id) do
    query =
      from a in AlbumListenList,
      where: a.listen_list_id == ^ll_id and a.is_current_album,
      select: a,
      preload: [:album, :user]
    current_album = Repo.one(query)
    case current_album do
      nil -> {:error, :no_album_revealed}
      _ -> {:ok, current_album}
    end
  end

  def random_reveal_next_album(ll_id) do
    query =
      from a in AlbumListenList,
      where: a.listen_list_id == ^ll_id and a.revealed == false,
      select: a
    albums = Repo.all(query)
    case albums do
      [] -> {:error, :no_more_albums_to_reveal}
      _ ->
        {_, current_album} = get_current_album(ll_id)
        if current_album != :no_album_revealed do
          current_album
          |> Ecto.Changeset.change(is_current_album: false)
          |> Repo.update()
        end

        album =
          albums
          |> Enum.random()
          |> Ecto.Changeset.change(revealed: true, is_current_album: true)
          |> Repo.update()
        {:ok, album}
    end
  end

  def reveal_next_album(ll_id, priority) do
    cond do
      priority -> priority_reveal_next_album(ll_id)
      true -> random_reveal_next_album(ll_id)
    end
  end

  def reveal_album(album, ll_id) do
    {_, current_album} = get_current_album(ll_id)
    if current_album != :no_album_revealed do
      current_album
      |> Ecto.Changeset.change(is_current_album: false)
      |> Repo.update()
    end
    album
    |> Ecto.Changeset.change(revealed: true, is_current_album: true)
    |> Repo.update()
  end

  def priority_reveal_next_album(ll_id) do
    #Get Albums that weren't revealed yet
    query =
      from a in AlbumListenList,
      where: a.listen_list_id == ^ll_id and a.revealed == false,
      select: a
    albums = Repo.all(query)
    albums_users_id = albums
    |> Enum.map(fn x -> x.user_id end)

    #Get Priority 2 Users
    query =
      from u in UsersListenLists,
      where: u.listen_list_id == ^ll_id and u.priority == 2,
      select: u
    prio2_users = Repo.all(query)
    |> Enum.filter(fn x ->
      x.user_id in albums_users_id
    end)

    #If there are priority 2 users with albums yet to be reveal chose one random user and a random album reveal
    if prio2_users != [] do
      Logger.info "YES PRIO 2"
      user = Enum.random(prio2_users)
      user
      |> Ecto.Changeset.change(priority: 0)
      |> Repo.update()
      albums |> Enum.filter(fn x -> x.user_id == user.user_id end) |> Enum.random() |> reveal_album(ll_id)
    else
      #Get Priority 1 Users
      query =
        from u in UsersListenLists,
        where: u.listen_list_id == ^ll_id and u.priority == 1,
        select: u
      all_p1 = Repo.all(query)
      prio1_users = all_p1
      |> Enum.filter(fn x ->
        x.user_id in albums_users_id
      end)

      #If there are priority 1 users with albums yet to be reveal chose one random user and a random album reveal
      if prio1_users != [] do
        user = Enum.random(prio1_users)
        user
        |> Ecto.Changeset.change(priority: 0)
        |> Repo.update()
        albums |> Enum.filter(fn x -> x.user_id == user.user_id end) |> Enum.random() |> reveal_album(ll_id)
      else
        #Get Priority 0 Users
        query =
          from u in UsersListenLists,
          where: u.listen_list_id == ^ll_id and u.priority == 0,
          select: u
        all_p0 = Repo.all(query)
        prio0_users = all_p0
        |> Enum.filter(fn x ->
          x.user_id in albums_users_id
        end)

        #If there are priority 0 users with albums yet to be reveal chose one random user and a random album reveal
        if prio0_users != [] do
          user = Enum.random(prio0_users)
          # End of cycle, reveal a p0, set other p0 to p1 and all p1 to p2
          all_p0
          |> Enum.map(fn x ->
            if x != user do
              x
              |> Ecto.Changeset.change(priority: 1)
              |> Repo.update()
            end
          end)
          all_p1
          |> Enum.map(fn x ->
            x
            |> Ecto.Changeset.change(priority: 2)
            |> Repo.update()
          end)
          albums |> Enum.filter(fn x -> x.user_id == user.user_id end) |> Enum.random() |> reveal_album(ll_id)
        else
          {:error, :no_more_albums_to_reveal}
        end
      end
    end
  end

  def restart_list(ll_id) do
    {_, current_album} = get_current_album(ll_id)
    if current_album != :no_album_revealed do
      current_album
      |> Ecto.Changeset.change(is_current_album: false)
      |> Repo.update()
    end

    query =
      from a in AlbumListenList,
      where: a.listen_list_id == ^ll_id and a.revealed == true,
      select: a
    Repo.all(query)
    |> Enum.map(fn x -> x |> Ecto.Changeset.change(revealed: false) |> Repo.update() end)
  end

  def deactivate_listen_list(ll_id) do
    get_listen_list!(ll_id)
    |> Ecto.Changeset.change(active: false)
    |> Repo.update()
  end

  def reveal_albums() do
    query =
      from l in ListenList,
      where: l.active == true,
      select: l
    Repo.all(query)
    |> Enum.map(fn list ->
      n_days_till_reveal = list.days_till_reveal - 1
      changeset = cond do
        n_days_till_reveal == 0 ->
          case reveal_next_album(list.id,list.priority_reveal) do
            {:error, :no_more_albums_to_reveal} ->
              list
              |> Ecto.Changeset.change(days_till_reveal: list.days_between_reveals, active: false)
            _ ->
              list
              |> Ecto.Changeset.change(days_till_reveal: list.days_between_reveals)
          end
        true ->
          list
          |> Ecto.Changeset.change(days_till_reveal: n_days_till_reveal)
      end
      Repo.update(changeset)
    end)
  end

  def all_lists() do
    query =
      from l in ListenList,
      select: l
    Repo.all(query)
  end

  def start_list(ll_id) do
    get_listen_list!(ll_id)
    |> Ecto.Changeset.change(active: true)
    |> Repo.update()
  end

  def stop_list(ll_id) do
    get_listen_list!(ll_id)
    |> Ecto.Changeset.change(active: false)
    |> Repo.update()
  end

  def change_days_between_reveals(ll_id,days) do
    get_listen_list!(ll_id)
    |> Ecto.Changeset.change(days_between_reveals: days, days_till_reveal: days)
    |> Repo.update()
  end

  def toggle_priority(ll_id) do
    ll = get_listen_list!(ll_id)
    ll
    |> Ecto.Changeset.change(priority_reveal: !(ll.priority_reveal))
    |> Repo.update()
  end

end
