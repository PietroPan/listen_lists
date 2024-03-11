defmodule ListenLists.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  alias ListenLists.Albums.Album
  alias ListenLists.Accounts.User

  schema "reviews" do
    field :comment, :string
    field :rating, :integer
    belongs_to :user, User
    belongs_to :album, Album

    timestamps()
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:comment, :rating, :user_id, :album_id])
    |> validate_required([:comment, :rating])
  end
end
