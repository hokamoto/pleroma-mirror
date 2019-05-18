defmodule Pleroma.Web.AdminAPI.ConfigTest do
  use Pleroma.DataCase, async: true
  import Pleroma.Factory
  alias Pleroma.Web.AdminAPI.Config

  test "get_by_key/1" do
    config = insert(:config)
    insert(:config)

    assert config == Config.get_by_key(config.key)
  end

  test "create/1" do
    {:ok, config} = Config.create(%{key: "some_key", value: "some_value"})
    assert config == Config.get_by_key("some_key")
  end

  test "update/1" do
    config = insert(:config)
    {:ok, updated} = Config.update(config, %{value: "some_value"})
    loaded = Config.get_by_key(config.key)
    assert loaded == updated
  end

  test "update_or_create/1" do
    config = insert(:config)
    key2 = "another_key"

    params = [
      %{key: key2, value: "another_value"},
      %{key: config.key, value: "new_value"}
    ]

    assert Repo.all(Config) |> length() == 1

    Enum.each(params, &Config.update_or_create(&1))

    assert Repo.all(Config) |> length() == 2

    config1 = Config.get_by_key(config.key)
    config2 = Config.get_by_key(key2)

    assert config1.value == Config.prepare_value("new_value")
    assert config2.value == Config.prepare_value("another_value")
  end

  test "delete/1" do
    config = insert(:config)
    {:ok, _} = Config.delete(config.key)
    refute Config.get_by_key(config.key)
  end

  test "prepare_value/1" do
    assert Config.prepare_value("some_value") == :erlang.term_to_binary("some_value")
  end

  test "convert_value/1" do
    assert Config.convert_value(
             <<131, 109, 0, 0, 0, 10, 115, 111, 109, 101, 95, 118, 97, 108, 117, 101>>
           ) == "some_value"
  end
end
