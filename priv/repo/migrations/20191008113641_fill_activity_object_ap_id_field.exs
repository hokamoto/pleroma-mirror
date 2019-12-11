defmodule Pleroma.Repo.Migrations.FillActivityObjectApIdField do
  use Ecto.Migration

  def change do
    execute(
      "update activities set object_ap_id = COALESCE(data->'object'->>'id', data->>'object')"
    )
  end
end
