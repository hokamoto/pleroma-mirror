defmodule Pleroma.Web.TwitterAPI.TwoFactorAuthenticationControllerTest do
  use Pleroma.Web.ConnCase

  import Pleroma.Factory
  alias Pleroma.MultiFactorAuthentications.Settings
  alias Pleroma.Web.Auth.TOTP

  describe "GET /api/pleroma/profile/mfa/settings" do
    test "returns user mfa settings for new user", %{conn: conn} do
      user = insert(:user)

      response =
        conn
        |> assign(:user, user)
        |> get("/api/pleroma/profile/mfa")
        |> json_response(:ok)

      assert response == %{
               "settings" => %{"enabled" => false, "totp" => false}
             }
    end

    test "returns user mfa settings with enabled totp", %{conn: conn} do
      user =
        insert(:user,
          multi_factor_authentication_settings: %Settings{
            enabled: true,
            totp: %Settings.TOTP{secret: "XXX", delivery_type: "app", confirmed: true}
          }
        )

      response =
        conn
        |> assign(:user, user)
        |> get("/api/pleroma/profile/mfa")
        |> json_response(:ok)

      assert response == %{
               "settings" => %{"enabled" => true, "totp" => true}
             }
    end
  end

  describe "GET /api/pleroma/profile/mfa/backup_codes" do
    test "returns backup codes", %{conn: conn} do
      user =
        insert(:user,
          multi_factor_authentication_settings: %Settings{backup_codes: ["1", "2", "3"]}
        )

      response =
        conn
        |> assign(:user, user)
        |> get("/api/pleroma/profile/mfa/backup_codes")
        |> json_response(:ok)

      assert response["status"] == "success"
      assert [<<_::bytes-size(6)>>, <<_::bytes-size(6)>>] = response["codes"]
      user = refresh_record(user)
      mfa_settings = user.multi_factor_authentication_settings
      refute mfa_settings.backup_codes == ["1", "2", "3"]
      refute mfa_settings.backup_codes == []
    end
  end

  describe "GET /api/pleroma/profile/mfa/setup/totp" do
    test "return errors when method is invalid", %{conn: conn} do
      user = insert(:user)

      response =
        conn
        |> assign(:user, user)
        |> get("/api/pleroma/profile/mfa/setup/torf")
        |> json_response(:ok)

      assert response == %{"error" => "undefined mfa method"}
    end

    test "returns key and provisioning_uri", %{conn: conn} do
      user =
        insert(:user,
          multi_factor_authentication_settings: %Settings{backup_codes: ["1", "2", "3"]}
        )

      response =
        conn
        |> assign(:user, user)
        |> get("/api/pleroma/profile/mfa/setup/totp")
        |> json_response(:ok)

      user = refresh_record(user)
      mfa_settings = user.multi_factor_authentication_settings
      secret = mfa_settings.totp.secret
      refute mfa_settings.enabled
      assert mfa_settings.backup_codes == ["1", "2", "3"]

      assert response == %{
               "key" => secret,
               "provisioning_uri" => TOTP.provisioning_uri(secret, "#{user.email}"),
               "status" => "success"
             }
    end
  end

  describe "GET /api/pleroma/profile/mfa/confirm/totp" do
    test "returns success result", %{conn: conn} do
      secret = TOTP.generate_secret()
      code = TOTP.generate_token(secret)

      user =
        insert(:user,
          multi_factor_authentication_settings: %Settings{
            backup_codes: ["1", "2", "3"],
            totp: %Settings.TOTP{secret: secret}
          }
        )

      response =
        conn
        |> assign(:user, user)
        |> post("/api/pleroma/profile/mfa/confirm/totp", %{password: "test", code: code})
        |> json_response(:ok)

      settings = refresh_record(user).multi_factor_authentication_settings
      assert settings.enabled
      assert settings.totp.secret == secret
      assert settings.totp.confirmed
      assert settings.backup_codes == ["1", "2", "3"]
      assert response == %{"status" => "success"}
    end

    test "returns error if password incorrect", %{conn: conn} do
      secret = TOTP.generate_secret()
      code = TOTP.generate_token(secret)

      user =
        insert(:user,
          multi_factor_authentication_settings: %Settings{
            backup_codes: ["1", "2", "3"],
            totp: %Settings.TOTP{secret: secret}
          }
        )

      response =
        conn
        |> assign(:user, user)
        |> post("/api/pleroma/profile/mfa/confirm/totp", %{password: "xxx", code: code})
        |> json_response(:ok)

      settings = refresh_record(user).multi_factor_authentication_settings
      refute settings.enabled
      refute settings.totp.confirmed
      assert settings.backup_codes == ["1", "2", "3"]
      assert response == %{"status" => "error", "error" => "Invalid password."}
    end

    test "returns error if code incorrect", %{conn: conn} do
      secret = TOTP.generate_secret()

      user =
        insert(:user,
          multi_factor_authentication_settings: %Settings{
            backup_codes: ["1", "2", "3"],
            totp: %Settings.TOTP{secret: secret}
          }
        )

      response =
        conn
        |> assign(:user, user)
        |> post("/api/pleroma/profile/mfa/confirm/totp", %{password: "test", code: "code"})
        |> json_response(:ok)

      settings = refresh_record(user).multi_factor_authentication_settings
      refute settings.enabled
      refute settings.totp.confirmed
      assert settings.backup_codes == ["1", "2", "3"]
      assert response == %{"status" => "error", "error" => "invalid_token"}
    end
  end

  describe "DELETE /api/pleroma/profile/mfa/totp" do
    test "returns success result", %{conn: conn} do
      user =
        insert(:user,
          multi_factor_authentication_settings: %Settings{
            backup_codes: ["1", "2", "3"],
            totp: %Settings.TOTP{secret: "secret"}
          }
        )

      response =
        conn
        |> assign(:user, user)
        |> delete("/api/pleroma/profile/mfa/totp", %{password: "test"})
        |> json_response(:ok)

      settings = refresh_record(user).multi_factor_authentication_settings
      refute settings.enabled
      assert settings.totp.secret == nil
      refute settings.totp.confirmed
      assert response == %{"status" => "success"}
    end
  end
end
