defmodule Todo.Database do
  alias Todo.DatabaseWorker
  use GenServer

  @db_folder "./persist"

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def init(_) do
    IO.puts("starting DB")

    workers =
      for index <- 0..2, into: %{} do
        {:ok, pid} = DatabaseWorker.start_link(@db_folder)
        {index, pid}
      end

    {:ok, {nil, workers}}
  end

  def handle_cast({:store, key, data}, {state, workers}) do
    worker = chose_worker(key, workers)
    Todo.DatabaseWorker.store(worker, key, data)

    {:noreply, {state, workers}}
  end

  def handle_call({:get, key}, _, {state, workers}) do
    worker = chose_worker(key, workers)

    data =
      Todo.DatabaseWorker.get(worker, key)

    {:reply, data, {state, workers}}
  end

  def file_name(key) do
    Path.join(@db_folder, to_string(key))
  end

  def chose_worker(key, workers) do
    index = :erlang.phash2(key, 3)
    Map.get(workers, index)
  end
end
