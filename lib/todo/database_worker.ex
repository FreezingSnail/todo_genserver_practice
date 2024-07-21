defmodule Todo.DatabaseWorker do
  use GenServer
  require Logger

  def start_link(db_folder) do
    Logger.info("Starting DatabaseWorker")
    GenServer.start_link(__MODULE__, db_folder)
  end

  def store(worker_id, key, data) do
    GenServer.call(worker_id, {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(worker_id, {:get, key})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:store, key, data}, _, state) do
    key
    |> file_name(state)
    |> File.write!(:erlang.term_to_binary(data))

    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:get, key}, _, state) do
    data =
      case File.read(file_name(key, state)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, state}
  end

  def file_name(key, folder) do
    Path.join(folder, to_string(key))
  end
end
