defmodule ListenListsWeb.JoinListenListLive.JoinListenList do
  use ListenListsWeb, :live_view
  require Logger

  @impl true
  def mount(params, _session, socket) do
    ll = ListenLists.ListenListss.get_listen_list!(params["listen_list_id"])
    socket =
      socket
      |> assign(form: to_form(%{}))
      |> assign(listen_list: ll)
    {:ok, socket}
  end

  @impl true
  def handle_event("join_listen_list", params, socket) do
    %{current_user: user, listen_list: ll} = socket.assigns
    Logger.debug "HAHAHAHAH: #{inspect(params)}"
    socket = cond do
      params["pass"] == ll.password ->
        ListenLists.ListenListss.add_user_to_listen_list(user.id,ll.id)
        socket
        |> put_flash(:info, "Joined ListenList!")
        |> push_navigate(to: ~p"/listen_list/#{ll.id}")
      true ->
        socket
        |> put_flash(:error, "Password Is Incorrect")
    end
    {:noreply, socket}
  end

end
