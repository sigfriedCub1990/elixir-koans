defmodule WithStatement do
  @moduledoc false
  use Koans

  @intro "The With Statement - Elegant error handling and happy path programming"

  koan "With lets you chain operations that might fail" do
    parse_and_add = fn str1, str2 ->
      with {a, ""} <- Integer.parse(str1),
           {b, ""} <- Integer.parse(str2) do
        {:ok, a + b}
      else
        :error -> {:error, :invalid_number}
      end
    end

    assert parse_and_add.("5", "4") == {:ok, 9}
    assert parse_and_add.("abc", "1") == {:error, :invalid_number}
  end

  koan "With short-circuits on the first non-matching pattern" do
    process_user = fn user_data ->
      with {:ok, name} <- Map.fetch(user_data, :name),
           {:ok, age} <- Map.fetch(user_data, :age),
           true <- age >= 18 do
        {:ok, "Adult user: #{name}"}
      else
        :error -> {:error, :missing_data}
        false -> {:error, :underage}
      end
    end

    assert process_user.(%{name: "Alice", age: 25}) == {:ok, "Adult user: Alice"}
    assert process_user.(%{name: "Bob", age: 16}) == {:error, :underage}
    assert process_user.(%{age: 25}) == {:error, :missing_data}
  end

  defp safe_divide(_, 0), do: {:error, :division_by_zero}
  defp safe_divide(x, y), do: {:ok, x / y}

  defp safe_sqrt(x) when x < 0, do: {:error, :negative_sqrt}
  defp safe_sqrt(x), do: {:ok, :math.sqrt(x)}

  koan "With can handle multiple different error patterns" do
    divide_and_sqrt = fn x, y ->
      with {:ok, division} <- safe_divide(x, y),
           {:ok, sqrt} <- safe_sqrt(division) do
        {:ok, sqrt}
      else
        {:error, :division_by_zero} -> {:error, "Cannot divide by zero"}
        {:error, :negative_sqrt} -> {:error, "Cannot take square root of negative number"}
      end
    end

    assert divide_and_sqrt.(16, 4) == {:ok, 2}
    assert divide_and_sqrt.(10, 0) == {:error, "Cannot divide by zero"}
    assert divide_and_sqrt.(-16, 4) == {:error, "Cannot take square root of negative number"}
  end

  koan "With works great for nested data extraction" do
    get_user_email = fn data ->
      with {:ok, user} <- Map.fetch(data, :user),
           {:ok, profile} <- Map.fetch(user, :profile),
           {:ok, email} <- Map.fetch(profile, :email),
           true <- String.contains?(email, "@") do
        {:ok, email}
      else
        :error -> {:error, :missing_data}
        false -> {:error, :invalid_email}
      end
    end

    valid_data = %{
      user: %{
        profile: %{
          email: "user@example.com"
        }
      }
    }

    invalid_email_data = %{
      user: %{
        profile: %{
          email: "notanemail"
        }
      }
    }

    assert get_user_email.(valid_data) == {:ok, "user@example.com"}
    assert get_user_email.(invalid_email_data) == {:error, :invalid_email}
    assert get_user_email.(%{}) == {:error, :missing_data}
  end

  koan "With can combine pattern matching with guards" do
    process_number = fn input ->
      with {num, ""} <- Integer.parse(input),
           true <- num > 0,
           result when result < 1000 <- num * 10 do
        {:ok, result}
      else
        :error -> {:error, :not_a_number}
        false -> {:error, :not_positive}
        result when result >= 100 -> {:error, :result_too_large}
      end
    end

    assert process_number.("5") == {:ok, 50}
    assert process_number.("-5") == {:error, :not_positive}
    assert process_number.("150") == {:error, :result_too_large}
    assert process_number.("abc") == {:error, :not_a_number}
  end

  koan "With clauses can have side effects and assignments" do
    register_user = fn user_data ->
      with {:ok, email} <- validate_email(user_data[:email]),
           {:ok, password} <- validate_password(user_data[:password]),
           hashed_password = hash_password(password),
           {:ok, user} <- save_user(email, hashed_password) do
        {:ok, user}
      else
        {:error, reason} -> {:error, reason}
      end
    end

    user_data = %{email: "test@example.com", password: "secure123"}
    assert {:ok, %{id: 1, email: "test@example.com", password: "hashed_secure123"}} = register_user.(user_data)
  end

  defp validate_email(email) when is_binary(email) and byte_size(email) > 0 do
    if String.contains?(email, "@"), do: {:ok, email}, else: {:error, :invalid_email}
  end

  defp validate_email(_), do: {:error, :invalid_email}

  defp validate_password(password) when is_binary(password) and byte_size(password) >= 6 do
    {:ok, password}
  end

  defp validate_password(_), do: {:error, :weak_password}

  defp hash_password(password), do: "hashed_" <> password

  defp save_user(email, hashed_password) do
    {:ok, %{id: 1, email: email, password: hashed_password}}
  end

  koan "With can be used without an else clause for simpler cases" do
    simple_calculation = fn x, y ->
      with num1 when is_number(num1) <- x,
           num2 when is_number(num2) <- y do
        num1 + num2
      end
    end

    assert simple_calculation.(5, 3) == 8
    # When pattern doesn't match and no else, returns the non-matching value
    assert simple_calculation.("5", 3) == "5"
  end

  koan "With can handle complex nested error scenarios" do
    complex_workflow = fn data ->
      with {:ok, step1} <- step_one(data),
           {:ok, step2} <- step_two(step1),
           {:ok, step3} <- step_three(step2) do
        {:ok, step3}
      else
        {:error, :step1_failed} -> {:error, "Failed at step 1: invalid input"}
        {:error, :step2_failed} -> {:error, "Failed at step 2: processing error"}
        {:error, :step3_failed} -> {:error, "Failed at step 3: final validation error"}
        other -> {:error, "Unexpected error: #{inspect(other)}"}
      end
    end

    assert complex_workflow.("valid") == {:ok, "step3_step2_step1_valid"}
    assert complex_workflow.("step1_fail") == {:error, "Failed at step 1: invalid input"}
    assert complex_workflow.("step2_fail") == {:error, "Failed at step 2: processing error"}
  end

  defp step_one("step1_fail"), do: {:error, :step1_failed}
  defp step_one(data), do: {:ok, "step1_" <> data}

  defp step_two("step1_step2_fail"), do: {:error, :step2_failed}
  defp step_two(data), do: {:ok, "step2_" <> data}

  defp step_three("step2_step1_step3_fail"), do: {:error, :step3_failed}
  defp step_three(data), do: {:ok, "step3_" <> data}
end
