defmodule ShopifyAPI.GraphQL.GraphQLCost do
  @doc """
  Tracks the cost of GraphQL querie
  """

  defstruct actual_query_cost: nil,
            requested_query_cost: nil

  @type t() :: %__MODULE__{
          actual_query_cost: nil | integer(),
          requested_query_cost: nil | integer()
        }

  @spec parse(Req.Response.t()) :: t()
  def parse(%Req.Response{body: %{"extensions" => %{"cost" => cost}}, status: 200}) do
    %__MODULE__{
      actual_query_cost: parse_actual_query_cost(cost),
      requested_query_cost: parse_requested_query_cost(cost)
    }
  end

  def parse(%Req.Response{}), do: %__MODULE__{}

  defp parse_actual_query_cost(%{"actualQueryCost" => actual_query_cost} = _cost)
       when is_integer(actual_query_cost),
       do: actual_query_cost

  defp parse_actual_query_cost(%{"actualQueryCost" => actual_query_cost} = _cost)
       when is_float(actual_query_cost),
       do: ceil(actual_query_cost)

  defp parse_actual_query_cost(_cost), do: nil

  defp parse_requested_query_cost(%{"requestedQueryCost" => requested_query_cost} = _cost)
       when is_integer(requested_query_cost),
       do: requested_query_cost

  defp parse_requested_query_cost(%{"requestedQueryCost" => requested_query_cost} = _cost)
       when is_float(requested_query_cost),
       do: ceil(requested_query_cost)

  defp parse_requested_query_cost(_cost), do: nil
end
