defmodule ListenListsWeb.PageController do
  use ListenListsWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    #render(conn, :home, layout: false)
    redirect(conn, to: ~p"/users/log_in")
  end
end
