defmodule Web.GameView do
  use Web, :view

  alias Gossip.Channels
  alias Gossip.UserAgents

  def render("online.json", %{games: games}) do
    %{
      collection: render_many(games, __MODULE__, "presence.json")
    }
  end

  def render("presence.json", %{game: game}) do
    %{
      game: Map.take(game.game, [:name, :homepage_url]),
      players: game.players
    }
  end

  def user_agent(game) do
    case game.user_agent do
      nil ->
        nil

      user_agent ->
        display_user_agent(user_agent)
    end
  end

  defp display_user_agent(user_agent) do
    with {:ok, user_agent} <- UserAgents.get_user_agent(user_agent),
         {:ok, user_agent} <- check_if_repo_url(user_agent) do
      link(user_agent.version, to: user_agent.repo_url, target: "_blank")
    else
      {:error, :no_repo_url, user_agent} ->
        user_agent.version

      _ ->
        nil
    end
  end

  defp check_if_repo_url(user_agent) do
    case user_agent.repo_url do
      nil ->
        {:error, :no_repo_url, user_agent}

      _ ->
        {:ok, user_agent}
    end
  end

  def display_channel?(channel) do
    case Channels.get(channel) do
      {:ok, channel} ->
        !channel.hidden

      _ ->
        false
    end
  end
end
