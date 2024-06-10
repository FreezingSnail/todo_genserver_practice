defmodule TodoServerTest do
  use ExUnit.Case
  doctest Todo.Server

  test Get do
    {:ok, pid} = Todo.Server.start("bob")
    Todo.Server.put(pid, %{date: "2021-01-01", description: "Buy milk"})
    Todo.Server.put(pid, %{date: "2021-01-01", description: "Buy eggs"})
    entries = Todo.Server.get(pid, "2021-01-01")

    assert entries == [
             %{date: "2021-01-01", description: "Buy milk", id: 1},
             %{date: "2021-01-01", description: "Buy eggs", id: 2}
           ]
  end
end
