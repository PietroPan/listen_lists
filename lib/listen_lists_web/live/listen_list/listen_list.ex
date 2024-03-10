defmodule ListenListsWeb.ListenListLive.ListenList do
  use ListenListsWeb, :live_view
  require Logger

  @impl true
  def mount(params, _session, socket) do
    ll = ListenLists.ListenListss.get_listen_list!(params["listen_list_id"])
    socket =
      socket
      |> assign(listen_list: ll)
    {:ok, socket}
  end

end
