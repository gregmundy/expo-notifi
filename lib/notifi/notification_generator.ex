defmodule Notifi.NotificationGenerator do
  @moduledoc """
  This module is responsible for generating messages based on specific templates.
  """

  @templates %{
    "transaction_reminder" => %{
      "to" => "<%= to %>",
      "title" => "<%= title %>",
      "body" => "<%= body %>",
      "data" => %{
        "screen" => "BudgetStack"
      }
    }
  }

  def render(template_name, data) do
    case find_template(template_name) do
      {:ok, template} ->
        # Convert data to a keyword list for EEx compatibility
        data = Map.to_list(data)

        # Check for required placeholders before rendering
        required_keys = extract_placeholders(template)
        missing_keys = required_keys -- Keyword.keys(data)

        if missing_keys == [] do
          try do
            rendered_template = process_template(template, data)
            {:ok, rendered_template}
          rescue
            e -> {:error, "Failed to render template: #{Exception.message(e)}"}
          end
        else
          {:error, "Missing required keys in data: #{inspect(missing_keys)}"}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp find_template(template_name) do
    case Map.get(@templates, template_name) do
      nil -> {:error, "Template not found"}
      template -> {:ok, template}
    end
  end

  # Recursively process each key-value pair in the map
  defp process_template(template, data) when is_map(template) do
    Enum.into(template, %{}, fn {key, value} ->
      {key, process_value(value, data)}
    end)
  end

  # Process individual values, evaluating EEx with the data as a keyword list
  defp process_value(value, data) when is_binary(value) do
    EEx.eval_string(value, data)
  end

  defp process_value(value, _data), do: value

  defp extract_placeholders(template) do
    template
    |> Enum.flat_map(fn {_key, value} ->
      if is_binary(value) do
        Regex.scan(~r/<%=\s*(\w+)\s*%>/, value)
        |> Enum.map(fn [_, key] -> String.to_atom(key) end)
      else
        # Skip non-string values
        []
      end
    end)
    |> Enum.uniq()
  end
end
