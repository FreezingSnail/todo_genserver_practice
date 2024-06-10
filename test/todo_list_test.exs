defmodule TodoListTest do
  use ExUnit.Case
  doctest Todo.List

  test CreateTodoList do
    assert Todo.List.new() == %Todo.List{next_id: 1, entries: %{}}
  end

  test AddEntry do
    todo_list = Todo.List.new()

    todo_list =
      Todo.List.add_entry(todo_list, %{date: "2021-01-01", description: "Buy milk"})

    assert todo_list == %Todo.List{
             next_id: 2,
             entries: %{
               1 => %{date: "2021-01-01", description: "Buy milk", id: 1}
             }
           }
  end

  test Entries do
    todo_list = Todo.List.new()

    todo_list =
      Todo.List.add_entry(todo_list, %{date: "2021-01-01", description: "Buy milk"})

    todo_list = Todo.List.add_entry(todo_list, %{date: "2021-01-01", description: "Buy eggs"})
    todo_list = Todo.List.add_entry(todo_list, %{date: "2021-01-02", description: "Buy bread"})
    entries = Todo.List.entries(todo_list, "2021-01-01")

    assert entries == [
             %{date: "2021-01-01", description: "Buy milk", id: 1},
             %{date: "2021-01-01", description: "Buy eggs", id: 2}
           ]
  end

  test UpdateEntry do
    todo_list = Todo.List.new()

    todo_list =
      Todo.List.add_entry(todo_list, %{date: "2021-01-01", description: "Buy milk"})

    todo_list =
      Todo.List.update_entry(todo_list, 1, &Map.put(&1, :description, "Buy milk and eggs"))

    assert todo_list == %Todo.List{
             next_id: 2,
             entries: %{
               1 => %{date: "2021-01-01", description: "Buy milk and eggs", id: 1}
             }
           }
  end

  test DeleteEntry do
    todo_list = Todo.List.new()

    todo_list =
      Todo.List.add_entry(todo_list, %{date: "2021-01-01", description: "Buy milk"})

    todo_list = Todo.List.delete_entry(todo_list, 1)
    assert todo_list == %Todo.List{next_id: 2, entries: %{}}
  end
end
