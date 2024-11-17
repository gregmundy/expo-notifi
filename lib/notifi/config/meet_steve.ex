defmodule Notifi.Config.MeetSteve do
  @moduledoc """
  General configuration for the Meet Steve API.
  """

  @doc """
  Returns the base URL for the Meet Steve API.
  """
  @spec api_base_url() :: String.t()
  def api_base_url do
    Application.fetch_env!(:notifi, :meet_steve)[:api_base_url]
  end

  @doc """
  Returns the API key for the Meet Steve API.
  """
  @spec api_key() :: String.t()
  def api_key do
    Application.fetch_env!(:notifi, :meet_steve)[:api_key]
  end
end
