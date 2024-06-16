defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link({db_folder, worker_id}) do
    GenServer.start_link(__MODULE__, {db_folder, worker_id}, name: via_tuple(worker_id))
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  def via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end

  def init({folder, state}) do
    IO.puts("starting DB worker")
    IO.inspect(folder)
    {:ok, {{folder, state}, nil}}
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
