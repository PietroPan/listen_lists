defmodule ListenListsWeb.HomeLive.Home do
  use ListenListsWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    %{current_user: user} = socket.assigns
    socket =
      socket
      |> assign(list_id: "0")
      |> assign(list_name: "default")
      |> assign(form: to_form(%{}))
      |> assign(show_yours: false)
      |> stream(:your_listen_lists, ListenLists.ListenListss.list_your_listen_lists(user.id))
      |> stream(:listen_lists, ListenLists.ListenListss.list_listen_lists())

    {:ok, socket}
  end

  @impl true
  def handle_event("create-listen_list", params, socket) do
    %{current_user: user} = socket.assigns
    ListenLists.ListenListss.create_listen_list_with_id(params,user.id)
    socket =
      socket
      |> put_flash(:info, "ListenList created successfully!")
      |> push_navigate(to: ~p"/home")
    {:noreply, socket}
  end

  def handle_event("join_or_enter", params, socket) do
    %{current_user: user} = socket.assigns
    socket = cond do
      ListenLists.ListenListss.check_if_user_belongs(user.id,params["list"]) ->
        socket
        |> push_navigate(to: ~p"/listen_list/#{params["list"]}/edit")
      true ->
        socket
        |> push_navigate(to: ~p"/join/#{params["list"]}")
    end
    {:noreply, socket}
  end

  def handle_event("test", params, socket) do
    Logger.debug "HAHAHAHAH: #{inspect(params)}"
    {:noreply, socket}
  end

end
