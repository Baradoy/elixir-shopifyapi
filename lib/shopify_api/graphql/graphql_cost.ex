defmodule ShopifyAPI.GraphQL.GraphQLCost do
  @doc """
  Costs of a GraphQLQuery
  """

  defstruct actual_query_cost: nil,
            requested_query_cost: nil,
            currently_available: nil,
            maximum_available: nil,
            restore_rate: nil

  @type t() :: %__MODULE__{
          actual_query_cost: nil | integer(),
          requested_query_cost: nil | integer(),
          currently_available: nil | integer(),
          maximum_available: nil | integer(),
          restore_rate: nil | integer()
        }

  @spec parse(Req.Response.t()) :: t()
  def parse(%Req.Response{body: %{"extensions" => %{"cost" => cost}}, status: 200}) do
    %__MODULE__{
      actual_query_cost: parse_actual_query_cost(cost),
      requested_query_cost: parse_requested_query_cost(cost),
      currently_available: parse_currently_available(cost),
      maximum_available: parse_maximum_available(cost),
      restore_rate: parse_restore_rate(cost)
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

  defp parse_currently_available(
         %{"throttleStatus" => %{"currentlyAvailable" => currently_available}} = _cost
       )
       when is_integer(currently_available),
       do: currently_available

  defp parse_currently_available(
         %{"throttleStatus" => %{"currentlyAvailable" => currently_available}} = _cost
       )
       when is_float(currently_available),
       do: currently_available

  defp parse_currently_available(_cost), do: nil

  defp parse_maximum_available(
         %{"throttleStatus" => %{"maximumAvailable" => maximum_available}} = _cost
       )
       when is_integer(maximum_available),
       do: maximum_available

  defp parse_maximum_available(
         %{"throttleStatus" => %{"maximumAvailable" => maximum_available}} = _cost
       )
       when is_float(maximum_available),
       do: maximum_available

  defp parse_maximum_available(_cost), do: nil

  defp parse_restore_rate(%{"throttleStatus" => %{"restoreRate" => restore_rate}} = _cost)
       when is_integer(restore_rate),
       do: restore_rate

  defp parse_restore_rate(%{"throttleStatus" => %{"restoreRate" => restore_rate}} = _cost)
       when is_float(restore_rate),
       do: restore_rate

  defp parse_restore_rate(_cost), do: nil
end
