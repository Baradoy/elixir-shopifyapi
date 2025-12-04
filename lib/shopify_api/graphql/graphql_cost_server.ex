defmodule ShopifyAPI.GraphQL.GraphQLCostServer do
  @moduledoc """
  Tracks the maximum and actual cost of queries
  """

  use GenServer

  alias ShopifyAPI.AuthToken
  alias ShopifyAPI.GraphQL.GraphQLCost
  alias ShopifyAPI.GraphQL.GraphQLQuery
  alias ShopifyAPI.UserToken

  @table __MODULE__

  @spec set(AuthToken.t() | UserToken.t(), GraphQLCost.t()) :: :ok
  def set(%GraphQLQuery{} = query, %GraphQLCost{} = cost) do
    case get(query) do
      {:ok, %GraphQLCost{actual_query_cost: actual_query_cost}}
      when cost.actual_query_cost > actual_query_cost ->
        :ok

      _ ->
        :ets.insert(@table, {query.name, cost})
        :ok
    end
  end

  @spec get(AuthToken.t() | UserToken.t()) :: {:ok, GraphQLCost.t()}
  def get(%GraphQLQuery{} = query) do
    case :ets.lookup(@table, query.name) do
      [{_key, cost}] -> {:ok, cost}
      [] -> {:error, {:cost_not_found, query.name}}
    end
  end

  ## GenServer Callbacks

  def start_link(_opts), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl GenServer
  def init(:ok) do
    :ets.new(@table, [
      :set,
      :public,
      :named_table,
      read_concurrency: true
    ])

    {:ok, :no_state}
  end
end
