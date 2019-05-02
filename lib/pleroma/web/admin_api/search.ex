# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.AdminAPI.Search do
  import Ecto.Query

  alias Pleroma.Repo
  alias Pleroma.User

  @page_size 50

  def user(params) do
    query = maybe_filtered_query(params)

    paginated_query =
      maybe_filtered_query(params)
      |> paginate(params[:page] || 1, params[:page_size] || @page_size)

    count = query |> Repo.aggregate(:count, :id)

    results = Repo.all(paginated_query)

    {:ok, results, count}
  end

  defp maybe_filtered_query(params) do
    from(u in User, order_by: u.nickname)
    |> User.maybe_local_user_query(params[:local])
    |> User.maybe_external_user_query(params[:external])
    |> User.maybe_active_user_query(params[:active])
    |> User.maybe_deactivated_user_query(params[:deactivated])
    |> User.maybe_is_admin_user_query(params[:is_admin])
    |> User.maybe_is_moderator_user_query(params[:is_moderator])
    |> User.maybe_search_by_tags(params[:tags])
    |> User.maybe_nickname_query(params[:query])
  end

  defp paginate(query, page, page_size) do
    from(u in query,
      limit: ^page_size,
      offset: ^((page - 1) * page_size)
    )
  end
end
