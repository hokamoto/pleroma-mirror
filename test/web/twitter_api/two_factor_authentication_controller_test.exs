defmodule Pleroma.Web.TwitterAPI.TwoFactorAuthenticationControllerTest do
  use Pleroma.Web.ConnCase

  import Pleroma.Factory
  alias Pleroma.Web.Auth.TOTP

  describe "GET /api/pleroma/2fa/provisioning_uri" do
    test "returns provisioning_uri for qr code", %{conn: conn} do
      user = insert(:user)

      response =
        conn
        |> assign(:user, user)
        |> get("/api/pleroma/2fa/provisioning_uri")
        |> json_response(:ok)

      user = refresh_record(user)

      assert response == %{
               "status" => "success",
               "key" => user.otp_secret,
               "provisioning_uri" =>
                 "otpauth://totp/#{user.email}?digits=6&issuer=Pleroma&period=30&secret=#{
                   user.otp_secret
                 }"
             }

      refute user.otp_enabled
      assert user.otp_secret
    end
  end

  describe "POST /api/pleroma/2fa/enable" do
    test "returns success with correct data", %{conn: conn} do
      user = insert(:user, otp_secret: TOTP.generate_secret())
      otp_token = TOTP.generate_token(user.otp_secret)

      response =
        conn
        |> assign(:user, user)
        |> post("/api/pleroma/2fa/enable", %{password: "test", otp_token: otp_token})
        |> json_response(:ok)

      assert response == %{"status" => "success"}
      user = refresh_record(user)
      assert user.otp_enabled
    end

    test "returns error if current password is incorrect", %{conn: conn} do
      user = insert(:user)

      response =
        conn
        |> assign(:user, user)
        |> post("/api/pleroma/2fa/enable", %{password: "42"})
        |> json_response(:ok)

      assert response == %{"error" => "Invalid password.", "status" => "error"}
      refute refresh_record(user).otp_enabled
    end

    test "returns error if otp_token is incorrect", %{conn: conn} do
      user = insert(:user, otp_secret: TOTP.generate_secret())

      response =
        conn
        |> assign(:user, user)
        |> post("/api/pleroma/2fa/enable", %{password: "test", otp_token: "incorrect"})
        |> json_response(:ok)

      assert response == %{"error" => "invalid_token", "status" => "error"}
    end
  end

  describe "POST /api/pleroma/2fa/disable" do
    test "returns success if current password is correct", %{conn: conn} do
      user = insert(:user, otp_enabled: true)

      response =
        conn
        |> assign(:user, user)
        |> post("/api/pleroma/2fa/disable", %{password: "test"})
        |> json_response(:ok)

      assert response == %{"status" => "success"}
      refute refresh_record(user).otp_enabled
    end

    test "returns error if current password is incorrect", %{conn: conn} do
      user = insert(:user)

      response =
        conn
        |> assign(:user, user)
        |> post("/api/pleroma/2fa/disable", %{password: "42"})
        |> json_response(:ok)

      assert response == %{"error" => "Invalid password."}
    end
  end

  describe "GET /api/pleroma/2fa/backup_codes" do
    test "returns backup codes", %{conn: conn} do
      user = insert(:user, otp_backup_codes: [])

      response =
        conn
        |> assign(:user, user)
        |> get("/api/pleroma/2fa/backup_codes")
        |> json_response(:ok)

      assert response["status"] == "success"
      assert [<<_::bytes-size(6)>>, <<_::bytes-size(6)>>] = response["codes"]
      hashed_codes = refresh_record(user).otp_backup_codes

      assert Enum.zip(response["codes"], hashed_codes)
             |> Enum.all?(fn {code, hash} ->
               Comeonin.Pbkdf2.checkpw(code, hash)
             end)
    end
  end
end
