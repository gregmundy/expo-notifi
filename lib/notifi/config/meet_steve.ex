defmodule Notifi.Config.MeetSteve do
  @moduledoc """
  General configuration for the Meet Steve API.
  """

  @doc """
  Returns the base URL for the Meet Steve API.
  """
  @spec api_base_url() :: String.t()
  def api_base_url do
    get_config(:api_base_url)
  end

  @doc """
  Returns the API key for the Meet Steve API.
  """
  @spec api_key() :: String.t()
  def api_key do
    get_config(:api_key)
  end

  # Private helper function to fetch configuration
  defp get_config(key) do
    Application.get_env(:notifi, :meet_steve)[key]
  end
end
