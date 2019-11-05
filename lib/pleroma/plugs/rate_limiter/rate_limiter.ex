# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Plugs.RateLimiter do
  @moduledoc """

  ## Configuration

  A keyword list of rate limiters where a key is a limiter name and value is the limiter configuration. The basic configuration is a tuple where:

  * The first element: `scale` (Integer). The time scale in milliseconds.
  * The second element: `limit` (Integer). How many requests to limit in the time scale provided.

  It is also possible to have different limits for unauthenticated and authenticated users: the keyword value must be a list of two tuples where the first one is a config for unauthenticated users and the second one is for authenticated.

  To disable a limiter set its value to `nil`.

  ### Example

      config :pleroma, :rate_limit,
        one: {1000, 10},
        two: [{10_000, 10}, {10_000, 50}],
        foobar: nil

  Here we have three limiters:

  * `one` which is not over 10req/1s
  * `two` which has two limits: 10req/10s for unauthenticated users and 50req/10s for authenticated users
  * `foobar` which is disabled

  ## Usage

  AllowedSyntax:

      plug(RateLimiter, name: :limiter_name)
      plug(RateLimiter, options})   # :name is a required option

  Allowed options:

      * `name` required
      * `bucket_name` overrides name (e.g. to have a separate limit for a set of actions)
      * `params` appends values of specified request params (e.g. ["id"]) to bucket name

  Inside a controller:

      plug(RateLimiter, [name: :one] when action == :one)
      plug(RateLimiter, [name: :two] when action in [:two, :three])

      plug(
        RateLimiter,
        [name: :status_id_action, bucket_name: "status_id_action:fav_unfav", params: ["id"]]
        when action in ~w(fav_status unfav_status)a
      )

  or inside a router pipeline:

      pipeline :api do
        ...
        plug(RateLimiter, name: :one)
        ...
      end
  """
  import Pleroma.Web.TranslationHelpers
  import Plug.Conn

  alias Pleroma.Plugs.RateLimiter.LimiterSupervisor
  alias Pleroma.User

  def init(opts) do
    limiter_name = Keyword.get(opts, :name)

    case Pleroma.Config.get([:rate_limit, limiter_name]) do
      nil ->
        nil

      config ->
        name_root = Keyword.get(opts, :bucket_name, limiter_name)

        %{
          name: name_root,
          limits: config,
          opts: opts
        }
    end
  end

  # Do not limit if there is no limiter configuration
  def call(conn, nil), do: conn

  def call(conn, settings) do
    settings
    |> incorporate_conn_info(conn)
    |> check_rate()
    |> case do
      {:ok, _count} ->
        conn

      {:error, _count} ->
        render_throttled_error(conn)
    end
  end

  def inspect_bucket(conn, name_root, settings) do
    name_root
    |> user_bucket_name()
    |> Process.whereis()
    |> case do
      nil ->
        {:err, :not_found}

      _ ->
        settings =
          settings
          |> incorporate_conn_info(conn)

        bucket_name = make_bucket_name(settings)
        key_name = make_key_name(settings)
        limit = get_limits(settings)

        count = ConCache.get(bucket_name, key_name) || 0
        {count, limit - count}
    end
  end

  defp check_rate(settings) do
    bucket_pid = get_or_create_bucket_pid(settings)
    key_name = make_key_name(settings)
    limit = get_limits(settings)
    {:ok, value} = ConCache.fetch_or_store(bucket_pid, key_name, &create_item/0)

    if value < limit do
      :ok = ConCache.update(bucket_pid, key_name, &update_item(&1))
      {:ok, value + 1}
    else
      {:error, value}
    end
  end

  defp get_or_create_bucket_pid(settings) do
    bucket_name = make_bucket_name(settings)
    bucket_pid = Process.whereis(bucket_name)

    if is_nil(bucket_pid) do
      initialize_bucket(settings)
      Process.whereis(bucket_name)
    else
      bucket_pid
    end
  end

  defp create_item, do: {:ok, 0}

  defp update_item(value), do: {:ok, %ConCache.Item{value: value + 1, ttl: :no_update}}

  defp incorporate_conn_info(settings, %{assigns: %{user: %User{id: user_id}}, params: params}) do
    Map.merge(settings, %{
      mode: :user,
      conn_params: params,
      conn_info: "#{user_id}"
    })
  end

  defp incorporate_conn_info(settings, %{params: params} = conn) do
    Map.merge(settings, %{
      mode: :anon,
      conn_params: params,
      conn_info: "#{ip(conn)}"
    })
  end

  defp ip(%{remote_ip: remote_ip}) do
    remote_ip
    |> Tuple.to_list()
    |> Enum.join(".")
  end

  defp render_throttled_error(conn) do
    conn
    |> render_error(:too_many_requests, "Throttled")
    |> halt()
  end

  defp make_key_name(settings) do
    ""
    |> attach_params(settings)
    |> attach_identity(settings)
  end

  defp get_scale(_, {scale, _}), do: scale

  defp get_scale(:anon, [{scale, _}, {_, _}]), do: scale

  defp get_scale(:user, [{_, _}, {scale, _}]), do: scale

  defp get_limits(%{limits: {_scale, limit}}), do: limit

  defp get_limits(%{mode: :user, limits: [_, {_, limit}]}), do: limit

  defp get_limits(%{limits: [{_, limit}, _]}), do: limit

  defp make_bucket_name(%{mode: :user, name: name_root}),
    do: user_bucket_name(name_root)

  defp make_bucket_name(%{mode: :anon, name: name_root}),
    do: anon_bucket_name(name_root)

  defp attach_params(input, %{conn_params: conn_params, opts: opts}) do
    param_string =
      opts
      |> Keyword.get(:params, [])
      |> Enum.sort()
      |> Enum.map(&Map.get(conn_params, &1, ""))
      |> Enum.join(":")

    "#{input}#{param_string}"
  end

  defp initialize_bucket(%{name: _name, limits: nil}), do: :ok

  defp initialize_bucket(%{name: name, limits: limits}) do
    LimiterSupervisor.add_limiter(anon_bucket_name(name), get_scale(:anon, limits))
    LimiterSupervisor.add_limiter(user_bucket_name(name), get_scale(:user, limits))
  end

  defp attach_identity(base, %{mode: :user, conn_info: conn_info}),
    do: "user:#{base}:#{conn_info}"

  defp attach_identity(base, %{mode: :anon, conn_info: conn_info}),
    do: "ip:#{base}:#{conn_info}"

  defp user_bucket_name(name_root), do: "user:#{name_root}" |> String.to_atom()
  defp anon_bucket_name(name_root), do: "anon:#{name_root}" |> String.to_atom()
end
