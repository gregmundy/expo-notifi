defmodule Notifi.Tasks.TransactionReminder do
  @moduledoc """
  Send a transaction reminder notification to the user.
  """

  alias Notifi.{NotificationGenerator, NotificationClient}
  alias Notifi.Services.MeetSteve
  require Logger

  @doc """
  Send reminders to users with greater than a certain number of unreviewed transactions.
  """
  @spec send() :: :ok
  def send do
    {:ok, users_to_notify} = MeetSteve.get_unreviewed_transactions()
    reminder_note = get_transaction_reminder_message()

    notifications =
      Enum.map(users_to_notify, fn %{ "expoToken" => expoToken } = user ->
        IO.inspect(user)
        # Render the notification payload for each user
        {:ok, payload} =
          NotificationGenerator.render("transaction_reminder", %{
            to: expoToken,
            title: reminder_note.title,
            body: reminder_note.body
          })

        payload
      end)

    case notifications do
      [] -> Logger.info("No users to notify")
      _ -> NotificationClient.send_notification(notifications)
    end
  end

  defp get_transaction_reminder_message do
    transaction_reminders = [
      %{
        title: "Have You Checked Your Transactions Today? 📅",
        body: "Take a moment to review your latest transactions and keep everything up-to-date!"
      },
      %{
        title: "Stay on Top of Your Transactions 📊",
        body:
          "A quick review each day helps you keep track of your spending. Check in when you can!"
      },
      %{
        title: "Today’s Financial Check-In 🚀",
        body:
          "Keeping a daily eye on your transactions can help you manage your money better. Give them a quick look!"
      },
      %{
        title: "Your Daily Transaction Review 💼",
        body:
          "Start your day with a quick look at your transactions. It’s a small step toward staying financially organized!"
      },
      %{
        title: "Time for Your Daily Financial Check! 📅",
        body:
          "Make it a habit to review your transactions regularly. A quick look today can help you stay on track!"
      }
    ]

    Enum.random(transaction_reminders)
  end
end
