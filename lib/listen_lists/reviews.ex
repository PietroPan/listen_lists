defmodule ListenLists.Reviews do
  alias ListenLists.Repo
  alias ListenLists.Reviews.Review
  import Ecto.Query

  def create_review(attrs \\ %{}) do
    %Review{}
    |> Review.changeset(attrs)
    |> Repo.insert()
  end

  def get_and_preload(review_id) do
    query =
      from r in Review,
      where: r.id == ^review_id,
      select: r,
      preload: [:user]
    Repo.one(query)
  end

  def create_and_preload(attrs \\ %{}) do
    {:ok, review} = create_review(attrs)
    get_and_preload(review.id)
  end

  def get_album!(id), do: Repo.get!(Review, id)


end
