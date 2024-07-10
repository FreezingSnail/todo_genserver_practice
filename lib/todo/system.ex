defmodule Todo.System do
  def start_link do
    Supervisor.start_link(
      [
        Todo.Cache,
        Todo.ProcessRegistry,
        Todo.Database,
        # Todo.Metrics,
        Todo.Web
      ],
      strategy: :one_for_one
    )
  end
end
