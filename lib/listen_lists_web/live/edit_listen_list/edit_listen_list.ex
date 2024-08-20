defmodule ListenListsWeb.EditListenListLive.EditListenList do
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
      |> assign(reveal_mode: get_reveal_mode(ll.reveal_mode))
      |> stream(:ll_albums, ll_albums)
      |> stream(:albums, [])
    {:ok, socket}
  end

  def get_reveal_mode(reveal_mode) do
    case reveal_mode do
      0 -> "Random"
      1 -> "Priority"
      2 -> "Oldest First"
    end
  end

  @impl true
  def handle_event("search_album", %{"query" => query}, socket) do
    # Handle the search event here
    token = socket.assigns.token
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
    %{current_user: user} = socket.assigns
    # Handle the search event here
    socket = case ListenLists.Albums.add_to_listen_list(%{name: params["name"], image_url: params["image"], spotify_id: params["id"], album_url: params["url"]},params["listen_list_id"],user.id) do
      {:ok, _} ->
        ll_albums = ListenLists.AlbumsListenLists.get_albums_of_list(params["listen_list_id"])
        socket |> put_flash(:info, "Album added successfully") |> stream(:ll_albums, ll_albums, reset: true)
      {:error, :album_already_added} -> socket |> put_flash(:error, "The album is already in the list")
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("add_custom_album", params, socket) do
    %{current_user: user} = socket.assigns
    ll_id = socket.assigns.listen_list.id
    album_id = "custom" <> params["name"]
    socket = case ListenLists.Albums.add_to_listen_list(%{name: params["name"], image_url: params["image"], spotify_id: album_id, album_url: params["url"]}, ll_id ,user.id) do
      {:ok, _} ->
        ll_albums = ListenLists.AlbumsListenLists.get_albums_of_list(ll_id)
        socket |> put_flash(:info, "Album added successfully") |> stream(:ll_albums, ll_albums, reset: true)
      {:error, :album_already_added} -> socket |> put_flash(:error, "The album is already in the list")
    end
    {:noreply, socket |> push_navigate(to: ~p"/listen_list/#{ll_id}/edit")}
  end

  @impl true
  def handle_event("remove_album", params, socket) do
    ListenLists.AlbumsListenLists.delete_album_listen_list(params["id"],params["listen_list_id"])
    ll_albums = ListenLists.AlbumsListenLists.get_albums_of_list(params["listen_list_id"])
    {:noreply, socket |> put_flash(:info, "Album removed successfully") |> stream(:ll_albums, ll_albums, reset: true)}
  end

  @impl true
  def handle_event("reveal_album", params, socket) do
    r = ListenLists.ListenListss.reveal_next_album(params["id"],params["mode"])
    socket = case r do
      {:error, _} -> socket |> put_flash(:error, "No more albums to be revealed!")
      {:ok, _} -> socket |> put_flash(:info, "Next Album Revealed!")
    end
    ll_albums = ListenLists.AlbumsListenLists.get_albums_of_list(params["id"])
    {:noreply, socket |> stream(:ll_albums, ll_albums)}
  end

  @impl true
  def handle_event("restart_list", params, socket) do
    ListenLists.ListenListss.restart_list(params["id"])
    ll_albums = ListenLists.AlbumsListenLists.get_albums_of_list(params["id"])

    {:noreply, socket |> put_flash(:info, "Restarted Successfully") |> stream(:ll_albums, ll_albums)}
  end

  @impl true
  def handle_event("start_list", params, socket) do
    {:ok, ll} = ListenLists.ListenListss.start_list(params["id"])
    {:noreply, socket |> put_flash(:info, "List started successfully!") |> assign(listen_list: ll)}
  end

  @impl true
  def handle_event("pause_list", params, socket) do
    {:ok, ll} = ListenLists.ListenListss.stop_list(params["id"])
    {:noreply, socket |> put_flash(:info, "List paused successfully!") |> assign(listen_list: ll)}
  end

  @impl true
  def handle_event("change_days", params, socket) do
    {:ok, ll} = ListenLists.ListenListss.change_days_between_reveals(params["id"],String.to_integer(params["days_between"]))
    {:noreply, socket |> put_flash(:info, "Days changed successfully!") |> assign(listen_list: ll)}
  end

  @impl true
  def handle_event("change_reveal_mode", params, socket) do
    {:ok, ll} = ListenLists.ListenListss.change_reveal_mode(params["id"],params["mode"])
    {:noreply, socket |> put_flash(:info, "Reveal mode changed successfully!") |> assign(listen_list: ll) |> push_navigate(to: ~p"/listen_list/#{params["id"]}/edit")}
  end

  @impl true
  def handle_event("debug", params, socket) do
    Logger.info "DEBUG: #{inspect(params)}"
    {:noreply, socket}
  end
end
