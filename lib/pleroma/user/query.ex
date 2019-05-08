# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.User.Query do
  import Ecto.Query
  import Pleroma.Web.AdminAPI.Search, only: [not_empty_string: 1]
  alias Pleroma.User

  @type criteria ::
          %{
            query: String.t(),
            page: pos_integer(),
            page_size: pos_integer(),
            tags: [String.t()],
            name: String.t(),
            email: String.t(),
            local: boolean(),
            external: boolean(),
            active: boolean(),
            deactivated: boolean(),
            is_admin: boolean(),
            is_moderator: boolean(),
            super_users: boolean(),
            followers: User.t(),
            friends: User.t(),
            from_set: [String.t()],
            recipients_from_activity: [String.t()],
            muted: [String.t()],
            blocked: [String.t()],
            subscribers: [String.t()]
          }
          | %{}

  @ilike_criteria [:nickname, :name, :query]
  @equal_criteria [:email]
  @role_criteria [:is_admin, :is_moderator]

  @spec build(criteria()) :: Query.t()
  def build(criteria) do
    prepare_query(base_query(), criteria)
  end

  @spec paginate(Ecto.Query.t(), pos_integer(), pos_integer()) :: Ecto.Query.t()
  def paginate(query, page, page_size) do
    from(u in query,
      limit: ^page_size,
      offset: ^((page - 1) * page_size)
    )
  end

  defp base_query do
    from(u in User)
  end

  defp prepare_query(query, criteria) do
    Enum.reduce(criteria, query, &compose_query/2)
  end

  defp compose_query({key, value}, query)
       when key in @ilike_criteria and not_empty_string(value) do
    # hack for :query key
    key = if key == :query, do: :nickname, else: key
    where(query, [u], ilike(field(u, ^key), ^"%#{value}%"))
  end

  defp compose_query({key, value}, query)
       when key in @equal_criteria and not_empty_string(value) do
    where(query, [u], ^[{key, value}])
  end

  defp compose_query({:tags, tags}, query) when is_list(tags) and length(tags) > 0 do
    Enum.reduce(tags, query, &prepare_tag_criteria/2)
  end

  defp compose_query({key, _}, query) when key in @role_criteria do
    where(query, [u], fragment("(?->? @> 'true')", u.info, ^to_string(key)))
  end

  defp compose_query({:local, _}, query), do: location_query(query, true)

  defp compose_query({:external, _}, query), do: location_query(query, false)

  defp compose_query({:active, _}, query) do
    where(query, [u], fragment("not (?->'deactivated' @> 'true')", u.info))
    |> where([u], not is_nil(u.nickname))
  end

  defp compose_query({:deactivated, _}, query) do
    where(query, [u], fragment("?->'deactivated' @> 'true'", u.info))
    |> where([u], not is_nil(u.nickname))
  end

  defp compose_query({:followers, %User{id: id, follower_address: follower_address}}, query) do
    where(query, [u], fragment("? <@ ?", ^[follower_address], u.following))
    |> where([u], u.id != ^id)
  end

  defp compose_query({:friends, %User{id: id, following: following}}, query) do
    where(query, [u], u.follower_address in ^following)
    |> where([u], u.id != ^id)
  end

  defp compose_query({:from_set, ap_ids}, query) do
    where(query, [u], u.ap_id in ^ap_ids)
  end

  defp compose_query({:recipients_from_activity, to}, query) do
    where(query, [u], u.ap_id in ^to or fragment("? && ?", u.following, ^to))
  end

  defp compose_query({:muted, muted_list}, query) do
    where(query, [u], u.ap_id in ^muted_list)
  end

  defp compose_query({:blocked, blocked_list}, query) do
    where(query, [u], u.ap_id in ^blocked_list)
  end

  defp compose_query({:subscribers, subscribers_list}, query) do
    where(query, [u], u.ap_id in ^subscribers_list)
  end

  defp compose_query({:super_users, _}, query) do
    where(
      query,
      [u],
      fragment("?->'is_admin' @> 'true' OR ?->'is_moderator' @> 'true'", u.info, u.info)
    )
  end

  defp compose_query(_unsupported_param, query), do: query

  defp prepare_tag_criteria(tag, query) do
    or_where(query, [u], fragment("? = any(?)", ^tag, u.tags))
  end

  defp location_query(query, local) do
    where(query, [u], u.local == ^local)
    |> where([u], not is_nil(u.nickname))
  end
end
