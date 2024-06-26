defmodule Todo.List do
  defstruct next_id: 1, entries: %{}

  def new(), do: %Todo.List{}

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)

    new_entries =
      Map.put(
        todo_list.entries,
        todo_list.next_id,
        entry
      )

    %Todo.List{todo_list | next_id: todo_list.next_id + 1, entries: new_entries}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end

  def update_entry(todo_list, entry_id, updater_func) do
    case Map.fetch(todo_list.entries, entry_id) do
      {:ok, entry} ->
        updated_entry = updater_func.(entry)
        new_entries = Map.put(todo_list.entries, entry_id, updated_entry)
        %Todo.List{todo_list | entries: new_entries}

      :error ->
        todo_list
    end
  end

  def delete_entry(todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %Todo.List{todo_list | entries: new_entries}
  end
end
