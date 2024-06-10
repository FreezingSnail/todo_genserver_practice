defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link(folder) do
    GenServer.start_link(__MODULE__, folder)
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def init(folder) do
    IO.puts("starting DB worker")
    File.mkdir_p!(folder)
    {:ok, {folder, nil}}
  end

  def handle_cast({:store, key, data}, {folder, state}) do
    key
    |> file_name(folder)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, {folder, state}}
  end

  def handle_call({:get, key}, _, {folder, state}) do
    data =
      case File.read(file_name(key, folder)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, {folder, state}}
  end

  def file_name(key, folder) do
    Path.join(folder, to_string(key))
  end
end
