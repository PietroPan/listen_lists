defmodule ListenListsWeb.ListenListLive.ListenList do
  use ListenListsWeb, :live_view
  require Logger

  @impl true
  def mount(params, _session, socket) do
    ll = ListenLists.ListenListss.get_listen_list!(params["listen_list_id"])
    {_, current_album} = ListenLists.ListenListss.get_current_album(params["listen_list_id"])
    socket = cond do
      current_album != :no_album_revealed ->
        {t_reviews, rating} = ListenLists.Albums.get_list_reviews(current_album.album.id,ll.id)
        socket
        |> assign(reviews_num: length(t_reviews))
        |> assign(rating: rating)
        |> stream(:reviews, t_reviews)
      true -> socket
    end
    socket =
      socket
      |> assign(form: %{})
      |> assign(listen_list: ll)
      |> assign(current_album: current_album)

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
