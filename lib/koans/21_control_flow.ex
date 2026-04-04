# credo:disable-for-this-file Credo.Check.Refactor.UnlessWithElse
# credo:disable-for-this-file Credo.Check.Refactor.CondStatements
defmodule ControlFlow do
  @moduledoc false
  use Koans

  @intro "Control Flow - Making decisions and choosing paths"

  koan "If statements evaluate conditions" do
    result = if true, do: "yes", else: "no"
    assert result == "yes"
  end

  koan "If can be written in block form" do
    result =
      if 1 + 1 == 2 do
        "math works"
      else
        "math is broken"
      end

    assert result == "math works"
  end

  koan "Unless is the opposite of if" do
    result = unless false, do: "will execute", else: "will not execute"
    assert result == "will execute"
  end

  koan "Nil and false are falsy, everything else is truthy" do
    assert if(nil, do: "truthy", else: "falsy") == "falsy"
    assert if(false, do: "truthy", else: "falsy") == "falsy"
    assert if(0, do: "truthy", else: "falsy") == "truthy"
    assert if("", do: "truthy", else: "falsy") == "truthy"
    assert if([], do: "truthy", else: "falsy") == "truthy"
  end

  koan "Case matches against patterns" do
    result =
      case {1, 2, 3} do
        {4, 5, 6} -> "no match"
        {1, x, 3} -> "matched with x = #{x}"
      end

    assert result == "matched with x = 2"
  end

  koan "Case can have multiple clauses with different patterns" do
    check_number = fn x ->
      case x do
        0 -> "zero"
        n when n > 0 -> "positive"
        n when n < 0 -> "negative"
      end
    end

    assert check_number.(5) == "positive"
    assert check_number.(0) == "zero"
    assert check_number.(-3) == "negative"
  end

  koan "Case clauses are tried in order until one matches" do
    check_list = fn list ->
      case list do
        [] -> "empty"
        [_] -> "one element"
        [_, _] -> "two elements"
        _ -> "many elements"
      end
    end

    assert check_list.([]) == "empty"
    assert check_list.([:a]) == "one element"
    assert check_list.([:a, :b]) == "two elements"
    assert check_list.([:a, :b, :c, :d]) == "many elements"
  end

  koan "Cond evaluates conditions until one is truthy" do
    temperature = 25

    weather =
      cond do
        temperature < 0 -> "freezing"
        temperature < 10 -> "cold"
        temperature < 25 -> "cool"
        temperature < 30 -> "warm"
        true -> "hot"
      end

    assert weather == "warm"
  end

  koan "Cond requires at least one clause to be true" do
    safe_divide = fn x, y ->
      cond do
        y == 0 -> {:error, "division by zero"}
        true -> {:ok, x / y}
      end
    end

    assert safe_divide.(10, 2) == {:ok, 5}
    assert safe_divide.(10, 0) == {:error, "division by zero"}
  end

  koan "Case can destructure complex patterns" do
    parse_response = fn response ->
      case response do
        {:ok, %{status: 200, body: body}} -> "Success: #{body}"
        {:ok, %{status: status}} when status >= 400 -> "Client error: #{status}"
        {:ok, %{status: status}} when status >= 500 -> "Server error: #{status}"
        {:error, reason} -> "Request failed: #{reason}"
      end
    end

    assert parse_response.({:ok, %{status: 200, body: "Hello"}}) == "Success: Hello"
    assert parse_response.({:ok, %{status: 404}}) == "Client error: 404"
    assert parse_response.({:error, :timeout}) == "Request failed: timeout"
  end

  koan "Guards in case can use complex expressions" do
    categorize = fn number ->
      case number do
        n when is_integer(n) and n > 0 and rem(n, 2) == 0 -> "positive even integer"
        n when is_integer(n) and n > 0 and rem(n, 2) == 1 -> "positive odd integer"
        n when is_integer(n) and n < 0 -> "negative integer"
        n when is_float(n) -> "float"
        _ -> "other"
      end
    end

    assert categorize.(4) == "positive even integer"
    assert categorize.(3) == "positive odd integer"
    assert categorize.(-5) == "negative integer"
    assert categorize.(3.14) == "float"
    assert categorize.("hello") == "other"
  end

  koan "Multiple conditions can be checked in sequence" do
    process_user = fn user ->
      if user.active do
        if user.verified do
          if user.premium do
            "premium verified active user"
          else
            "verified active user"
          end
        else
          "unverified active user"
        end
      else
        "inactive user"
      end
    end

    user = %{active: true, verified: true, premium: false}
    assert process_user.(user) == "verified active user"
  end
end
