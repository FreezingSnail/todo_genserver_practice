defmodule Todo.Database do
  @pool_size 3
  @db_folder "persist"

  def start_link() do
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  def child_spec(_) do
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: 3
      ],
      [@db_folder]
    )
  end

  def store(key, data) do
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
