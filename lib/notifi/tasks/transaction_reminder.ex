defmodule Notifi.Tasks.TransactionReminder do
  @moduledoc """
  Send a transaction reminder notification to the user.
  """

  alias Notifi.{NotificationGenerator, NotificationClient}

  def send do
    # count unreviewed transactions ordered by users
    # send a reminder to each user

    reminder_note = get_transaction_reminder_message()

    {:ok, payload} =
      NotificationGenerator.render("transaction_reminder", %{
        to: "ExponentPushToken[XTbiwQOuGpXp8A-lgXwrjF]",
        title: reminder_note.title,
        body: reminder_note.body
      })

    NotificationClient.send_notification([payload])
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
