defmodule ShopifyAPI.GraphQL.GrahpQLRateLimiting do
  alias ShopifyAPI.GraphQL.GraphQLBudgetServer
  alias ShopifyAPI.GraphQL.GraphQLCostServer

  @fallback_avialable 2000
  @fallback_cost 0

  def check_budget(query, scope) do
    actual_query_cost = get_query_cost(query)
    {available, maximum_available} = get_avaialable(scope)

    metadata = %{
      name: query.name,
      actual_query_cost: actual_query_cost,
      available: available,
      maximum_available: maximum_available
    }

    if actual_query_cost < available do
      {:ok, metadata}
    else
      {:error, {:query_over_budget, metadata}}
    end
  end

  defp get_query_cost(query) do
    case GraphQLCostServer.get(query) do
      {:ok, query_cost} -> query_cost.actual_query_cost
      _ -> @fallback_cost
    end
  end

  defp get_avaialable(scope) do
    case GraphQLBudgetServer.get(scope) do
      {:ok, budget} -> {available(budget), budget.maximum_available}
      _ -> {@fallback_avialable, @fallback_avialable}
    end
  end

  defp available(budget)
       when is_integer(budget.currently_available) and is_integer(budget.maximum_available) do
    min(budget.currently_available + restored(budget), budget.maximum_available)
  end

  defp available(_budget), do: @fallback_avialable

  defp restored(budget)
       when is_integer(budget.restore_rate) and is_struct(budget.created_at, DateTime) do
    floor(
      DateTime.diff(DateTime.utc_now(), budget.created_at, :second) * budget.restore_rate /
        60
    )
  end

  defp restored(_budget), do: @fallback_cost
end
