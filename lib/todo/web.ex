defmodule Todo.Web do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  def child_spec(_args) do
    Plug.Cowboy.child_spec(
      scheme: :http,
      plug: __MODULE__,
      options: [
        port: Application.fetch_env!(:todo_practice, :http_port)
      ]
    )
  end

  post "/add_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    title = Map.fetch!(conn.params, "title")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    list_name
    |> Todo.Cache.server_process()
    |> Todo.Server.put(%{title: title, date: date})

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end

  get "/entries" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    entries =
      list_name
      |> Todo.Cache.server_process()
      |> Todo.Server.get(date)

    formatted_entries =
      entries
      |> Enum.map(&"#{&1.title} - #{&1.date}")
      |> Enum.join("\n")

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, formatted_entries)
  end
end
