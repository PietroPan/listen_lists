defmodule ListenListsWeb.AlbumLive.Album do
  use ListenListsWeb, :live_view
  require Logger


  @impl true
  def mount(params, _session, socket) do
    album = ListenLists.Albums.get_album!(params["album_id"])
    reviews = ListenLists.Albums.get_reviews(album.id)
    Logger.debug "Reviews: #{inspect(reviews)}"
    socket =
      socket
      |> assign(form: %{})
      |> assign(album: album)
      |> assign(reviews_num: length(reviews))
      |> stream(:reviews, reviews)
    {:ok, socket}
  end

  @impl true
  def handle_event("add_review", params, socket) do
    %{current_user: user} = socket.assigns
    Logger.debug "Review: #{inspect(params)}"
    {rating, _} = Float.parse(params["rating"])
    socket = cond do
      rating < 1 or rating > 10 ->
        socket |> put_flash(:error, "Rating must be between 1 and 10!")
      true ->
        review = ListenLists.Reviews.create_and_preload(%{comment: params["comment"], rating: params["rating"], user_id: user.id, album_id: params["album_id"]})
        {:ok, album} = ListenLists.Albums.calculate_album_rating(params["album_id"])
        socket
        |> put_flash(:info, "Review added successfully!")
        |> assign(reviews_num: socket.assigns.reviews_num+1)
        |> assign(album: album)
        |> stream(:reviews, [review], at: 0)
    end
    {:noreply, socket}
  end
end
