defmodule Instachat.Repo do
  use Ecto.Repo,
    otp_app: :instachat,
    adapter: Ecto.Adapters.Postgres
end
