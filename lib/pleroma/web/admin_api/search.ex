# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.AdminAPI.Search do
  import Ecto.Query

  alias Pleroma.Repo
  alias Pleroma.User
  alias Pleroma.User.Query, as: UsersQuery

  @page_size 50

  defmacro not_empty_string(string) do
    quote do
      is_binary(unquote(string)) and unquote(string) != ""
    end
  end

  @spec user(User.criteria()) :: {:ok, [User.t()], pos_integer()}
  def user(params \\ %{}) do
    query = UsersQuery.build(params) |> order_by([u], u.nickname)

    paginated_query = paginate(query, params[:page] || 1, params[:page_size] || @page_size)

    count = Repo.aggregate(query, :count, :id)

    results = Repo.all(paginated_query)

    {:ok, results, count}
  end

  defp paginate(query, page, page_size) do
    from(u in query,
      limit: ^page_size,
      offset: ^((page - 1) * page_size)
    )
  end
end
