defmodule TodoServer do
  use GenServer

  def start do
    GenServer.start(TodoServer, nil)
  end

  def put(pid, value) do
    GenServer.cast(pid, {:put, value})
  end

  def get(pid, date) do
    GenServer.call(pid, {:get, date})
  end

  @impl true
  def init(_) do
    {:ok, %TodoList{}}
  end

  @impl true
  def handle_cast({:put, value}, state) do
    {:noreply, TodoList.add_entry(state, value)}
  end

  @impl true
  def handle_call({:get, date}, _from, state) do
    {:reply, TodoList.entries(state, date), state}
  end
end
