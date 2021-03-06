defmodule GrapevineData.Messages do
  @moduledoc """
  Record messages posted in the chat
  """

  import Ecto.Query

  alias GrapevineData.Messages.Message
  alias GrapevineData.Repo

  @doc """
  Load messages for a channel
  """
  def for(channel, opts \\ []) do
    Message
    |> where([m], m.channel_id == ^channel.id)
    |> order_by(desc: :inserted_at)
    |> maybe_limit(opts[:limit])
    |> Repo.all()
  end

  defp maybe_limit(query, nil), do: query

  defp maybe_limit(query, total), do: limit(query, ^total)

  @doc """
  Create a message from the socket
  """
  def record_socket(game, channel, params) do
    %Message{}
    |> Message.create_socket_changeset(game, channel, params)
    |> Repo.insert()
  end

  @doc """
  Create a message from the web chat
  """
  def record_web(channel, user, text) do
    %Message{}
    |> Message.create_web_changeset(channel, user, text)
    |> Repo.insert()
  end
end
