defmodule Notifi.Services.MeetSteve do
  @moduledoc """
  Service module for the Meet Steve API.
  """

  alias Notifi.Config.MeetSteve
  alias HTTPoison
  require Logger

  @api_base_url MeetSteve.api_base_url()
  @api_key MeetSteve.api_key()
  @headers [
    {"accept", "application/json"},
    {"content-type", "application/json"},
    {"x-api-key", @api_key}
  ]

  @doc """
  Retrieve a list of unreviewed transactions.
  """
  @spec get_unreviewed_transactions() :: {:ok, list} | {:error, any}
  def get_unreviewed_transactions do
    case HTTPoison.get("#{@api_base_url}/admin/users/unreviewed-transactions", @headers) do
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
end
