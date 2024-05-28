defmodule TodoServerTest do
  use ExUnit.Case
  doctest TodoServer

  test Get do
    {:ok, pid} = TodoServer.start()
    TodoServer.put(pid, %{date: "2021-01-01", description: "Buy milk"})
    TodoServer.put(pid, %{date: "2021-01-01", description: "Buy eggs"})
    entries = TodoServer.get(pid, "2021-01-01")

    assert entries == [
             %{date: "2021-01-01", description: "Buy milk", id: 1},
             %{date: "2021-01-01", description: "Buy eggs", id: 2}
           ]
  end
end
