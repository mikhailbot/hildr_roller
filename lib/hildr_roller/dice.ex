defmodule HildrRoller.Dice do
  def generate(string) do
    string
    |> clean_input()
    |> pad_single_dice()
    |> validate_input()
    |> check_modifier()
    |> get_parts()
    |> get_rolls()
  end

  defp clean_input(string) do
    string |> String.upcase() |> String.trim()
  end

  # Ensure consistent dice format xDy
  defp pad_single_dice(string) do
    case String.match?(string, ~r/^D.*/) do
      true -> "1#{string}"
      false -> string
    end
  end

  defp validate_input(string) do
    case String.match?(string, ~r/^[1-9][0-9]*D[1-9][0-9]*[+-]?$/) do
      true -> {:ok, string}
      false -> {:error, %{message: "Unable to validate dice string #{string}"}}
    end
  end

  defp check_modifier({:ok, string}) do
    case String.last(string) do
      "+" ->
        {:ok, %{roll: String.slice(string, 0..-2), modifier: "+"}}

      "-" ->
        {:ok, %{roll: String.slice(string, 0..-2), modifier: "-"}}

      _ ->
        {:ok, %{roll: string, modifier: nil}}
    end
  end

  defp check_modifier({:error, opts}), do: {:error, opts}

  defp get_parts({:ok, %{roll: string, modifier: modifier}}) do
    case(String.split(string, "D", parts: 2, trim: true)) do
      [sides] ->
        {:ok, %{quantity: 1, sides: String.to_integer(sides), modifier: modifier}}

      [quantity | [sides]] ->
        {:ok,
         %{
           quantity: String.to_integer(quantity),
           sides: String.to_integer(sides),
           modifier: modifier
         }}

      _ ->
        {:error, %{message: "Unable to parse dice #{string}"}}
    end
  end

  defp get_parts({:error, opts}), do: {:error, opts}

  defp get_rolls({:ok, %{quantity: quantity, sides: sides, modifier: modifier}}) do
    case modifier do
      "+" ->
        {:ok,
         %{
           quantity: quantity,
           sides: sides,
           modifier: modifier,
           first: roll(quantity, sides),
           second: roll(quantity, sides)
         }}

      "-" ->
        {:ok,
         %{
           quantity: quantity,
           sides: sides,
           modifier: modifier,
           first: roll(quantity, sides),
           second: roll(quantity, sides)
         }}

      _ ->
        {:ok, %{quantity: quantity, sides: sides, result: roll(quantity, sides)}}
    end
  end

  defp get_rolls({:error, message}), do: {:error, message}

  defp roll(quantity, sides) do
    case quantity do
      1 ->
        Enum.random(1..sides)

      _ ->
        1..quantity
        |> Enum.map(fn _x ->
          Enum.random(1..sides)
        end)
        |> Enum.sum()
    end
  end
end
