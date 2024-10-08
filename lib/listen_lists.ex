defmodule ListenLists do
  @moduledoc """
  ListenLists keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def handle_date(date) do
    {y,m,d} = NaiveDateTime.to_date(date)
    |> Calendar.Date.to_erl()

    m = case m do
      1 -> "January"
      2 -> "February"
      3 -> "March"
      4 -> "April"
      5 -> "May"
      6 -> "June"
      7 -> "July"
      8 -> "August"
      9 -> "September"
      10 -> "October"
      11 -> "November"
      12 -> "December"
    end

    "#{d} #{m} #{y}"
  end
end
