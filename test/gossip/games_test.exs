defmodule Gossip.GamesTest do
  use Gossip.DataCase

  alias Gossip.Games

  describe "registering a new game" do
    test "successful" do
      user = create_user()

      {:ok, game} = Games.register(user, %{
        name: "A MUD",
      })

      assert game.name == "A MUD"
      assert game.client_id
      assert game.client_secret
    end
  end

  describe "verifying a client id and secret" do
    setup do
      %{game: create_game(create_user())}
    end

    test "when valid", %{game: game} do
      assert {:ok, _game} = Games.validate_socket(game.client_id, game.client_secret)
    end

    test "when bad secret", %{game: game} do
      assert {:error, :invalid} = Games.validate_socket(game.client_id, "bad")
    end

    test "when bad id", %{game: game} do
      assert {:error, :invalid} = Games.validate_socket("bad", game.client_id)
    end

    test "saves the user agent if available", %{game: game} do
      assert {:ok, game} = Games.validate_socket(game.client_id, game.client_secret, %{"user_agent" => "ExVenture 0.23.0"})
      assert game.user_agent == "ExVenture 0.23.0"
    end
  end
end
