defmodule ShopifyAPI.GraphQL.GraphQLBudgetServer do
  @moduledoc """
  Tracks the remaining query budget for a token
  """

  use GenServer

  alias ShopifyAPI.AuthToken
  alias ShopifyAPI.GraphQL.GraphQLBudget
  alias ShopifyAPI.Scopes
  alias ShopifyAPI.UserToken

  @table __MODULE__

  @spec set(ShopifyAPI.Scope.t(), GraphQLBudget.t()) :: :ok
  def set(scope, %GraphQLBudget{} = budget) do
    :ets.insert(@table, {key(scope), budget})

    :ok
  end

  @spec get(ShopifyAPI.Scope.t()) :: {:ok, GraphQLBudget.t()}
  def get(scope) do
    case :ets.lookup(@table, key(scope)) do
      [{_key, budget}] -> {:ok, budget}
      [] -> {:error, :budget_not_found}
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

  # Private functions

  defp key(%UserToken{} = token), do: {token.shop_name, token.app_name, token.associated_user_id}
  defp key(%AuthToken{} = token), do: {token.shop_name, token.app_name}

  defp key(scope) do
    case Scopes.user_token(scope) do
      user_token = %ShopifyAPI.UserToken{} -> user_token |> key()
      _ -> scope |> Scopes.auth_token() |> key()
    end
  end
end
