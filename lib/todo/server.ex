defmodule Todo.Server do
  use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.seconds(10)

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  def put(pid, value) do
    GenServer.cast(pid, {:put, value})
  end

  def get(pid, date) do
    IO.inspect("Calling get")
    GenServer.call(pid, {:get, date})
  end

  @impl true
  def init(name) do
    IO.puts("starting server")
    {:ok, {name, nil}, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, {name, nil}) do
    list = Todo.Database.get(name) || Todo.List.new()
    {:noreply, {name, list}, @expiry_idle_timeout}
  end

  @impl true
  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Timeout TodoServer #{name}")
    {:stop, :normal, {name, todo_list}}
  end

  @impl true
  def handle_cast({:put, value}, {name, state}) do
    new_list = Todo.List.add_entry(state, value)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end

  @impl true
  def handle_call({:get, date}, _from, {name, state}) do
    {:reply, Todo.List.entries(state, date), {name, state}, @expiry_idle_timeout}
  end
end
