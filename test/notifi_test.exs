defmodule NotifiTest do
  use ExUnit.Case
  doctest Notifi

  test "greets the world" do
    assert Notifi.hello() == :world
  end
end
