defmodule ListenLists.ListenListss do
  alias ListenLists.ListenLists.ListenList
  alias ListenLists.UsersListenLists

  alias ListenLists.Repo
  import Ecto.Query


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


end
