defmodule KokuraexWeb.EventFunction do
  def get_connpass_events(keyword, count) do
    "https://connpass.com/api/v1/event/?keyword=#{keyword}&order=2&count=#{count}"
    |> HTTPoison.get()
  end

  def handle_httpoison_result(res) do
    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> body
      {:ok, %HTTPoison.Response{status_code: 404}} -> :httpoison_notfound
      {:error, %HTTPoison.Error{reason: _}} -> :httpoison_error
      _ -> :httpoison_unknown
    end
  end

  def connpass_events(keyword, count) do
    res =
      get_connpass_events(keyword, count)
      |> handle_httpoison_result()

    case res do
      :httpoison_notfound ->
        [
          default_events_map()
        ]

      :httpoison_error ->
        [
          %{default_events_map() | title: "Fetch Error"}
        ]

      :httpoison_unknown ->
        [
          %{default_events_map() | title: "Unknown Error"}
        ]

      _ ->
        res_decoded_events =
          res
          |> Jason.decode!()
          |> Map.get("events")

        cond do
          res_decoded_events |> Enum.empty?() ->
            [
              %{default_events_map() | title: "No events found"}
            ]

          true ->
            res_decoded_events
            |> Enum.map(
              &%{
                default_events_map()
                | title: &1["title"],
                  started_at: &1["started_at"],
                  ended_at: &1["ended_at"],
                  catch: &1["catch"],
                  address: &1["address"],
                  event_url: &1["event_url"]
              }
            )
        end
    end
  end

  def kokuraex_connpass_events() do
    connpass_events(
      "kokura_ex",
      "5"
    )
  end

  def pelemay_connpass_events() do
    [
      pelemay_simd_meetup(),
      pelemay_beam_otp_meetup(),
      pelemay_history_meetup()
    ]
    |> Enum.concat()
    |> Enum.sort_by(& &1.started_at, :desc)
    |> Enum.take(5)
  end

  def pelemay_simd_meetup() do
    connpass_events(
      "Pelemay Meetup SIMD勉強会",
      "3"
    )
  end

  def pelemay_beam_otp_meetup() do
    connpass_events(
      "「BEAM/OTP対話」",
      "3"
    )
  end

  def pelemay_history_meetup() do
    connpass_events(
      "Pelemayの歴史を振り返る会",
      "2"
    )
  end

  def default_events_map() do
    %{
      title: "Not Found",
      started_at: "-",
      ended_at: "-",
      catch: "-",
      address: "-",
      event_url: "https://kokura-ex.herokuapp.com/"
    }
  end
end