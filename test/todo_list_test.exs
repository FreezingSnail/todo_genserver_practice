defmodule TodoListTest do
  use ExUnit.Case
  doctest TodoList

  test CreateTodoList do
    assert TodoList.new() == %TodoList{next_id: 1, entries: %{}}
  end

  test AddEntry do
    todo_list = TodoList.new()

    todo_list =
      TodoList.add_entry(todo_list, %{date: "2021-01-01", description: "Buy milk"})

    assert todo_list == %TodoList{
             next_id: 2,
             entries: %{
               1 => %{date: "2021-01-01", description: "Buy milk", id: 1}
             }
           }
  end

  test Entries do
    todo_list = TodoList.new()

    todo_list =
      TodoList.add_entry(todo_list, %{date: "2021-01-01", description: "Buy milk"})

    todo_list = TodoList.add_entry(todo_list, %{date: "2021-01-01", description: "Buy eggs"})
    todo_list = TodoList.add_entry(todo_list, %{date: "2021-01-02", description: "Buy bread"})
    entries = TodoList.entries(todo_list, "2021-01-01")

    assert entries == [
             %{date: "2021-01-01", description: "Buy milk", id: 1},
             %{date: "2021-01-01", description: "Buy eggs", id: 2}
           ]
  end

  test UpdateEntry do
    todo_list = TodoList.new()

    todo_list =
      TodoList.add_entry(todo_list, %{date: "2021-01-01", description: "Buy milk"})

    todo_list =
      TodoList.update_entry(todo_list, 1, &Map.put(&1, :description, "Buy milk and eggs"))

    assert todo_list == %TodoList{
             next_id: 2,
             entries: %{
               1 => %{date: "2021-01-01", description: "Buy milk and eggs", id: 1}
             }
           }
  end

  test DeleteEntry do
    todo_list = TodoList.new()

    todo_list =
      TodoList.add_entry(todo_list, %{date: "2021-01-01", description: "Buy milk"})

    todo_list = TodoList.delete_entry(todo_list, 1)
    assert todo_list == %TodoList{next_id: 2, entries: %{}}
  end
end
