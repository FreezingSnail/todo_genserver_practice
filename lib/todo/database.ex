defmodule Todo.Database do
  require Logger
  @pool_size 3
  @db_folder "persist/"

  def start_link() do
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp worker_spec(worker_id) do
    node_name = Node.self() |> Atom.to_string()
    file_path = @db_folder <> node_name

    default_worker_spec = {Todo.DatabaseWorker, {file_path, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  def child_spec(_) do
    node_name = Node.self() |> Atom.to_string()
    file_path = @db_folder <> node_name
    Logger.info("Starting Database with file path: #{file_path}")

    File.mkdir_p!(file_path)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: 3
      ],
      [file_path]
    )
  end

  def store(key, data) do
    {_results, bad_nodes} =
      :rpc.multicall(
        __MODULE__,
        :store_local,
        [key, data],
        :timer.seconds(5)
      )

    Enum.each(bad_nodes, fn node ->
      Logger.error("Failed to store data on node #{node}")
    end)
  end

  def store_local(key, data) do
    :poolboy.transaction(__MODULE__, fn pid ->
      Todo.DatabaseWorker.store(pid, key, data)
    end)
  end

  def get(key) do
    :poolboy.transaction(__MODULE__, fn pid ->
      Todo.DatabaseWorker.get(pid, key)
    end)
  end

  def file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
