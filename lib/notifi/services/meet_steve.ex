defmodule Notifi.Services.MeetSteve do
  @moduledoc """
  Service module for the Meet Steve API.
  """

  alias Notifi.Config
  alias HTTPoison
  require Logger

  @headers [
    {"accept", "application/json"},
    {"content-type", "application/json"},
  ]

  @doc """
  Retrieve a list of unreviewed transactions.
  """
  @spec get_unreviewed_transactions() :: {:ok, list} | {:error, any}
  def get_unreviewed_transactions do
    api_base_url = Config.MeetSteve.api_base_url()
    api_key = Config.MeetSteve.api_key()

    case HTTPoison.get(
           "#{api_base_url}/admin/users/unreviewed-transactions",
           auth_header(api_key)
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        response =
          body
          |> Jason.decode!()
          |> format_response()

        {:ok, response}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}

      other ->
        Logger.error("An unknown error occurred: #{inspect(other)}")
        {:error, "An unknown error occurred"}
    end
  end

  defp format_response(%{"data" => transactions}) when is_list(transactions) do
    transactions
  end

  defp auth_header(api_key) do
    @headers ++ [{"x-api-key", api_key}]
  end
end
