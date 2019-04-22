defmodule Pleroma.HealthcheckTest do
  use Pleroma.DataCase
  alias Pleroma.Healthcheck

  test "system_info/0" do
    db_info = %Healthcheck{active: 1, idle: 0, pool_size: 1, healthy: false}

    result = Healthcheck.system_info()

    refute result.healthy
    assert Map.delete(db_info, :memory_used) == Map.delete(result, :memory_used)
  end

  describe "check_health/1" do
    test "pool size equals active connections" do
      result = Healthcheck.check_health(%Healthcheck{pool_size: 10, active: 10})
      refute result.healthy
    end

    test "chech_health/1" do
      result = Healthcheck.check_health(%Healthcheck{pool_size: 10, active: 9})
      assert result.healthy
    end
  end
end
