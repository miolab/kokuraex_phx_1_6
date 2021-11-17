defmodule KokuraexWeb.DatetimeFunctionTest do
  use KokuraexWeb.ConnCase
  import KokuraexWeb.DatetimeFunction

  test "test_日時文字列「2021-01-01T00:00:00+09:00」形式を{:ok, ~N[2021-01-01 00:00:00]}形式に置換できる" do
    actual = datetime_from_iso8601("2021-01-01T00:00:00+09:00")
    assert actual === {:ok, ~N[2021-01-01 00:00:00]}
  end

  test "test_異常系_ISO8601形式に該当しない日時文字列を{:error, :....}形式に置換できる" do
    invalid_format = datetime_from_iso8601("021-01-01T00:00:00+09:00")
    assert invalid_format === {:error, :invalid_format}

    unexpected_format = datetime_from_iso8601("12345678")
    assert unexpected_format === {:error, :invalid_format}
  end

  test "test_JST日時{:ok, ~N[2021-01-01 00:00:00]}形式を文字列「2021-01-01 00:00(JST)」形式に置換できる" do
    actual =
      {:ok, ~N[2021-01-01 00:00:00]}
      |> return_datetime()

    assert actual === "2021-01-01 00:00(JST)"
  end

  test "test_{:error, _}形式を文字列「0000-00-00 00:00(JST)」形式に置換できる" do
    actual =
      {:error, :invalid_format}
      |> return_datetime()

    assert actual === "0000-00-00 00:00(JST)"
  end
end
