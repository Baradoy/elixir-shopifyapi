defmodule ShopifyAPI.GraphQL.GraphQLBudget do
  @doc """
  Tracks the GraphQL budget for scope.
  """

  defstruct currently_available: nil,
            maximum_available: nil,
            restore_rate: nil,
            created_at: nil

  @type t() :: %__MODULE__{
          currently_available: nil | integer(),
          maximum_available: nil | integer(),
          restore_rate: nil | integer(),
          created_at: nil | DateTime.t()
        }

  @spec parse(Req.Response.t()) :: t()
  def parse(%Req.Response{body: %{"extensions" => %{"cost" => cost}}, status: 200}) do
    %__MODULE__{
      currently_available: parse_currently_available(cost),
      maximum_available: parse_maximum_available(cost),
      restore_rate: parse_restore_rate(cost),
      created_at: DateTime.utc_now()
    }
  end

  def parse(%Req.Response{}), do: %__MODULE__{}

  defp parse_currently_available(
         %{"throttleStatus" => %{"currentlyAvailable" => currently_available}} = _cost
       )
       when is_integer(currently_available),
       do: currently_available

  defp parse_currently_available(
         %{"throttleStatus" => %{"currentlyAvailable" => currently_available}} = _cost
       )
       when is_float(currently_available),
       do: floor(currently_available)

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
       do: ceil(maximum_available)

  defp parse_maximum_available(_cost), do: nil

  defp parse_restore_rate(%{"throttleStatus" => %{"restoreRate" => restore_rate}} = _cost)
       when is_integer(restore_rate),
       do: restore_rate

  defp parse_restore_rate(%{"throttleStatus" => %{"restoreRate" => restore_rate}} = _cost)
       when is_float(restore_rate),
       do: floor(restore_rate)

  defp parse_restore_rate(_cost), do: nil
end
