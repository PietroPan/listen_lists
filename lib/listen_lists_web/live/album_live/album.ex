defmodule ListenListsWeb.AlbumLive.Album do
  use ListenListsWeb, :live_view
  require Logger


  @impl true
  def mount(params, _session, socket) do
    album = ListenLists.Albums.get_album!(params["album_id"])
    socket =
      socket
      |> assign(album: album)
    {:ok, socket}
  end
end
