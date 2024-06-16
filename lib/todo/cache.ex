defmodule Todo.Cache do
  def start_link() do
    IO.puts("starting Cache")
    DynamicSupervisor.start_link(name: __MODULE__, stategy: :one_for_one)
  end

  def child_spec(_arg) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, []}, type: :supervisor}
  end

  def server_process(todo_list_name) do
    case start_child(todo_list_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(todo_list_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Todo.Server, todo_list_name}
    )
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        {:ok, todo_server} = Todo.Server.start_link(todo_list_name)

        {
          :reply,
          todo_server,
          Map.put(todo_servers, todo_list_name, todo_server)
        }
    end
  end
end
