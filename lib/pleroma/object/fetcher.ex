# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Object.Fetcher do
  alias Pleroma.HTTP
  alias Pleroma.Object
  alias Pleroma.Object.Containment
  alias Pleroma.Repo
  alias Pleroma.Signature
  alias Pleroma.Web.ActivityPub.InternalFetchActor
  alias Pleroma.Web.ActivityPub.Transmogrifier
  alias Pleroma.Web.Federator
  alias Pleroma.Web.FedSockets

  require Logger
  require Pleroma.Constants

  defp touch_changeset(changeset) do
    updated_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    Ecto.Changeset.put_change(changeset, :updated_at, updated_at)
  end

  defp maybe_reinject_internal_fields(data, %{data: %{} = old_data}) do
    internal_fields = Map.take(old_data, Pleroma.Constants.object_internal_fields())

    Map.merge(data, internal_fields)
  end

  defp maybe_reinject_internal_fields(data, _), do: data

  @spec reinject_object(struct(), map()) :: {:ok, Object.t()} | {:error, any()}
  defp reinject_object(struct, data) do
    Logger.debug("Reinjecting object #{data["id"]}")

    with data <- Transmogrifier.fix_object(data),
         data <- maybe_reinject_internal_fields(data, struct),
         changeset <- Object.change(struct, %{data: data}),
         changeset <- touch_changeset(changeset),
         {:ok, object} <- Repo.insert_or_update(changeset),
         {:ok, object} <- Object.set_cache(object) do
      {:ok, object}
    else
      e ->
        Logger.error("Error while processing object: #{inspect(e)}")
        {:error, e}
    end
  end

  def refetch_object(%Object{data: %{"id" => id}} = object) do
    with {:local, false} <- {:local, Object.local?(object)},
         {:ok, data} <- fetch_and_contain_remote_object_from_id(id),
         {:ok, object} <- reinject_object(object, data) do
      {:ok, object}
    else
      {:local, true} -> {:ok, object}
      e -> {:error, e}
    end
  end

  # Note: will create a Create activity, which we need internally at the moment.
  def fetch_object_from_id(id, options \\ []) do
    with {_, nil} <- {:fetch_object, Object.get_cached_by_ap_id(id)},
         {_, true} <- {:allowed_depth, Federator.allowed_thread_distance?(options[:depth])},
         {_, {:ok, data}} <- {:fetch, fetch_and_contain_remote_object_from_id(id)},
         {_, nil} <- {:normalize, Object.normalize(data, false)},
         params <- prepare_activity_params(data),
         {_, :ok} <- {:containment, Containment.contain_origin(id, params)},
         {_, {:ok, activity}} <-
           {:transmogrifier, Transmogrifier.handle_incoming(params, options)},
         {_, _data, %Object{} = object} <-
           {:object, data, Object.normalize(activity, false)} do
      {:ok, object}
    else
      {:allowed_depth, false} ->
        {:error, "Max thread distance exceeded."}

      {:containment, _} ->
        {:error, "Object containment failed."}

      {:transmogrifier, {:error, {:reject, nil}}} ->
        {:reject, nil}

      {:transmogrifier, _} ->
        {:error, "Transmogrifier failure."}

      {:object, data, nil} ->
        reinject_object(%Object{}, data)

      {:normalize, object = %Object{}} ->
        {:ok, object}

      {:fetch_object, %Object{} = object} ->
        {:ok, object}

      {:fetch, {:error, error}} ->
        {:error, error}

      e ->
        e
    end
  end

  defp prepare_activity_params(data) do
    %{
      "type" => "Create",
      "to" => data["to"],
      "cc" => data["cc"],
      # Should we seriously keep this attributedTo thing?
      "actor" => data["actor"] || data["attributedTo"],
      "object" => data
    }
  end

  def fetch_object_from_id!(id, options \\ []) do
    with {:ok, object} <- fetch_object_from_id(id, options) do
      object
    else
      {:error, %Tesla.Mock.Error{}} ->
        nil

      {:error, "Object has been deleted"} ->
        nil

      e ->
        Logger.error("Error while fetching #{id}: #{inspect(e)}")
        nil
    end
  end

  defp make_signature(id, date) do
    uri = URI.parse(id)

    signature =
      InternalFetchActor.get_actor()
      |> Signature.sign(%{
        "(request-target)": "get #{uri.path}",
        host: uri.host,
        date: date
      })

    [{:Signature, signature}]
  end

  defp sign_fetch(headers, id, date) do
    if Pleroma.Config.get([:activitypub, :sign_object_fetches]) do
      headers ++ make_signature(id, date)
    else
      headers
    end
  end

  defp maybe_date_fetch(headers, date) do
    if Pleroma.Config.get([:activitypub, :sign_object_fetches]) do
      headers ++ [{:Date, date}]
    else
      headers
    end
  end

  def fetch_and_contain_remote_object_from_id(prm, opts \\ [])

  def fetch_and_contain_remote_object_from_id(%{"id" => id}, opts),
    do: fetch_and_contain_remote_object_from_id(id, opts)

  def fetch_and_contain_remote_object_from_id(id, opts) when is_binary(id) do
    Logger.debug("Fetching object #{id} via AP")

    with {:scheme, true} <- {:scheme, String.starts_with?(id, "http")},
         {:ok, body} <- get_object(id, opts),
         {:ok, data} <- safe_json_decode(body),
         :ok <- Containment.contain_origin_from_id(id, data) do
      {:ok, data}
    else
      {:scheme, _} ->
        {:error, "Unsupported URI scheme"}

      {:error, e} ->
        {:error, e}

      e ->
        {:error, e}
    end
  end

  def fetch_and_contain_remote_object_from_id(_id, _opts),
    do: {:error, "id must be a string"}

  defp get_object(id, opts) do
    with false <- Keyword.get(opts, :force_http, false),
         {:ok, fedsocket} <- FedSockets.get_or_create_fed_socket(id) do
      IO.inspect(id, label: "#{inspect(self())} - fetching via fedsocket")
      FedSockets.fetch(fedsocket, id)
    else
      _other ->
        IO.inspect(id, label: "#{inspect(self())} - fetching via http")
        get_object_http(id)
    end
  end

  defp get_object_http(id) do
    date = Pleroma.Signature.signed_date()

    headers =
      [{:Accept, "application/activity+json"}]
      |> maybe_date_fetch(date)
      |> sign_fetch(id, date)

    case HTTP.get(id, headers) do
      {:ok, %{body: body, status: code}} when code in 200..299 ->
        {:ok, body}

      {:ok, %{status: code}} when code in [404, 410] ->
        {:error, "Object has been deleted"}

      {:error, e} ->
        {:error, e}

      e ->
        {:error, e}
    end
  end

  defp safe_json_decode(nil), do: {:ok, nil}
  defp safe_json_decode(json), do: Jason.decode(json)
end
