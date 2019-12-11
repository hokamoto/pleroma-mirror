defmodule Pleroma.Repo.Migrations.AddObjectApIdTriggerToActivities do
  use Ecto.Migration

  def change do
    execute("""
    CREATE OR REPLACE FUNCTION set_object_ap_id()
    RETURNS trigger
    LANGUAGE plpgsql
    AS $BODY$
    BEGIN
    NEW.object_ap_id = COALESCE(NEW.data->'object'->>'id', NEW.data->>'object');
    RETURN NEW;
    END
    $BODY$;
    """)

    execute("""
    CREATE TRIGGER activities_object_ap_id_extraction
    BEFORE INSERT OR UPDATE
    ON activities
    FOR EACH ROW
    EXECUTE PROCEDURE set_object_ap_id();
    """)
  end
end
