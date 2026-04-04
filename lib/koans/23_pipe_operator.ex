# credo:disable-for-this-file Credo.Check.Warning.IoInspect
# credo:disable-for-this-file Credo.Check.Refactor.MapJoin
defmodule PipeOperator do
  @moduledoc false
  use Koans

  @intro "The Pipe Operator - Making data transformation elegant and readable"

  koan "The pipe operator passes the result of one function to the next" do
    result =
      "hello world"
      |> String.upcase()
      |> String.split(" ")
      |> Enum.join("-")

    assert result == "HELLO-WORLD"
  end

  koan "Without pipes, nested function calls can be hard to read" do
    nested_result = Enum.join(String.split(String.downcase("Hello World"), " "), "_")
    piped_result = "Hello World" |> String.downcase() |> String.split(" ") |> Enum.join("_")

    assert nested_result == piped_result
    assert piped_result == "hello_world"
  end

  koan "Pipes pass the result as the first argument to the next function" do
    result =
      [1, 2, 3, 4, 5]
      |> Enum.filter(&(&1 > 2))
      |> Enum.map(&(&1 * 2))

    assert result == [6, 8, 10]
  end

  koan "Additional arguments can be passed to piped functions" do
    result =
      "hello world"
      |> String.split(" ")
      |> Enum.join(", ")

    assert result == "hello, world"
  end

  koan "Pipes work with anonymous functions too" do
    double = fn x -> x * 2 end
    add_ten = fn x -> x + 10 end

    result =
      5
      |> double.()
      |> add_ten.()

    assert result == 20
  end

  koan "You can pipe into function captures" do
    result =
      [1, 2, 3]
      |> Enum.map(&Integer.to_string/1)
      |> Enum.join("-")

    assert result == "1-2-3"
  end

  koan "Complex data transformations become readable with pipes" do
    users = [
      %{name: "Bob", age: 25, active: false},
      %{name: "Charlie", age: 35, active: true},
      %{name: "Alice", age: 30, active: true}
    ]

    active_names =
      users
      |> Enum.filter(& &1.active)
      |> Enum.map(& &1.name)
      |> Enum.sort()

    assert active_names == ["Alice", "Charlie"]
  end

  koan "Pipes can be split across multiple lines for readability" do
    result =
      "the quick brown fox jumps over the lazy dog"
      |> String.split(" ")
      |> Enum.filter(&(String.length(&1) > 3))
      |> Enum.map(&String.upcase/1)
      |> Enum.take(3)

    assert result == ["QUICK", "BROWN", "JUMPS"]
  end

  koan "The then/2 function is useful when you need to call a function that doesn't take the piped value as first argument" do
    result =
      [1, 2, 3]
      |> Enum.map(&(&1 * 2))
      |> then(&Enum.zip([:a, :b, :c], &1))

    assert result == [{:a, 2}, {:b, 4}, {:c, 6}]
  end

  koan "Pipes can be used with case statements" do
    process_number = fn x ->
      x
      |> Integer.parse()
      |> case do
        {num, ""} -> {:ok, num * 2}
        _ -> {:error, :invalid_number}
      end
    end

    assert process_number.("42") == {:ok, 84}
    assert process_number.("abc") == {:error, :invalid_number}
  end

  koan "Conditional pipes can use if/unless" do
    process_string = fn str, should_upcase ->
      str
      |> String.trim()
      |> then(&if should_upcase, do: String.upcase(&1), else: &1)
      |> String.split(" ")
    end

    assert process_string.("  hello world  ", true) == ["HELLO", "WORLD"]
    assert process_string.("  hello world  ", false) == ["hello", "world"]
  end

  koan "Pipes work great with Enum functions for data processing" do
    sales_data = [
      %{product: "Widget", amount: 100, month: "Jan"},
      %{product: "Gadget", amount: 200, month: "Jan"},
      %{product: "Widget", amount: 150, month: "Feb"},
      %{product: "Gadget", amount: 180, month: "Feb"}
    ]

    widget_total =
      sales_data
      |> Enum.filter(&(&1.product == "Widget"))
      |> Enum.map(& &1.amount)
      |> Enum.sum()

    assert widget_total == 250
  end

  koan "Tap lets you perform side effects without changing the pipeline" do
    result =
      [1, 2, 3]
      |> Enum.map(&(&1 * 2))
      |> tap(&IO.inspect(&1, label: "After doubling"))
      |> Enum.sum()

    assert result == 12
  end

  koan "Multiple transformations can be chained elegantly" do
    text = "The quick brown fox dumped over the lazy dog"

    word_stats =
      text
      |> String.downcase()
      |> String.split(" ")
      |> Enum.group_by(&String.first/1)
      |> Enum.map(fn {letter, words} -> {letter, length(words)} end)
      |> Enum.into(%{})

    assert word_stats["d"] == 2
    assert word_stats["t"] == 2
    assert word_stats["q"] == 1
  end

  koan "Pipes can be used in function definitions for clean APIs" do
    defmodule TextProcessor do
      @moduledoc false
      def clean_and_count(text) do
        text
        |> String.trim()
        |> String.downcase()
        |> String.replace(~r/[^\w\s]/, "")
        |> String.split()
        |> length()
      end
    end

    assert TextProcessor.clean_and_count("  Hello, World! How are you?  ") == 5
  end

  koan "Error handling can be integrated into pipelines" do
    safe_divide = fn
      {x, 0} -> {:error, :division_by_zero}
      {x, y} -> {:ok, x / y}
    end

    pipeline = fn x, y ->
      {x, y}
      |> safe_divide.()
      |> case do
        {:ok, result} -> "Result: #{result}"
        {:error, reason} -> "Error: #{reason}"
      end
    end

    assert pipeline.(10, 2) == "Result: 5.0"
    assert pipeline.(10, 0) == "Error: division_by_zero"
  end
end
