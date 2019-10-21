defmodule LibuWeb.Router do
  use LibuWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {LibuWeb.LayoutView, :app}
    plug :put_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LibuWeb do
    pipe_through :browser

    get "/", PageController, :index

    live "/projects", ProjectLive.Index
    live "/projects/kanban", ProjectLive.KanBan
    live "/projects/new", ProjectLive.New
    live "/projects/:id", ProjectLive.Show
    live "/projects/:id/edit", ProjectLive.Edit

    live "/clock", LiveClock

    live "/analysis", AnalysisSession, session: [:uuid]

    resources "/plain/projects", ProjectController
  end

  scope "/", LibuWeb do
    pipe_through [:browser, LibuWeb.Plugs.Auth]

    get "/chat/conversations/:id", ChatController, :conversation
    live "/chat", ChatLive.Index
    live "/chat/conversations/new", ChatLive.InitiateConversation, session: [:current_user]
  end

  scope "/auth", LibuWeb do
    pipe_through :browser

    get "/:provider", IdentityController, :index
    get "/:provider/callback", IdentityController, :callback
  end

  defp put_current_user(conn, _) do
    assign(conn, :current_user, get_session(conn, :current_user))
  end
end
