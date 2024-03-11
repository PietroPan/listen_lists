defmodule ListenLists.Reviews do
  alias ListenLists.Repo
  alias ListenLists.Reviews.Review

  def create_review(attrs \\ %{}) do
    %Review{}
    |> Review.changeset(attrs)
    |> Repo.insert()
  end

  def get_album!(id), do: Repo.get!(Review, id)


end
