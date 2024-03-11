defmodule ListenListsWeb.ListenListLive.ListenList do
  use ListenListsWeb, :live_view
  require Logger

  @impl true
  def mount(params, _session, socket) do
    ll = ListenLists.ListenListss.get_listen_list!(params["listen_list_id"])
    ll_albums = ListenLists.AlbumsListenLists.get_albums_of_list(ll.id)
    socket =
      socket
      |> assign(form: to_form(%{}))
      |> assign(token: "")
      |> assign(query: "")
      |> assign(listen_list: ll)
      |> stream(:ll_albums, ll_albums)
      |> stream(:albums, [])
    {:ok, socket}
  end

  @impl true
  def handle_event("search_album", %{"query" => query}, socket) do
    # Handle the search event here
    token = socket.assigns.token
    Logger.debug "Query: #{query}"
    result = SpotifyApi.search_for_album(token,query)
    {:ok, token} = cond do
      token == "" -> SpotifyApi.get_access_token(System.get_env("SPOTIFY_CLIENT_ID"),System.get_env("SPOTIFY_CLIENT_SECRET"))
      result == {:error, "HTTP Error 401"} -> SpotifyApi.get_access_token(System.get_env("SPOTIFY_CLIENT_ID"),System.get_env("SPOTIFY_CLIENT_SECRET"))
      true -> {:ok, token}
    end

    socket = case SpotifyApi.search_for_album(token,query) do
      {:ok, response} ->
        r = response["albums"]["items"]
        |> Enum.map(fn x ->
          id = x["id"]
          name = x["name"]
          album_url = x["external_urls"]["spotify"]
          image_url = x["images"]
          |> Enum.at(0)
          |> Access.get("url")
          %{id: id, name: name,album_url: album_url,image_url: image_url} end)
        Logger.debug "Response: #{inspect(r)}"
        socket
        |> stream(:albums, r, reset: true)
      {:error, reason} ->
        socket
        |> put_flash(:error, "Something went wrong (#{reason})")
    end

    socket =
      socket
      |> assign(query: query)
      |> assign(token: token)
    {:noreply, socket}
  end


  @impl true
  def handle_event("add_album", params, socket) do
    # Handle the search event here
    socket = case ListenLists.Albums.add_to_listen_list(%{name: params["name"], image_url: params["image"], spotify_id: params["id"], album_url: params["url"]},params["listen_list_id"]) do
      {:ok, _} -> socket |> put_flash(:info, "Album added successfully")
      {:error, :album_already_added} -> socket |> put_flash(:error, "The album is already in the list")
    end
    {:noreply, socket}
  end

end
