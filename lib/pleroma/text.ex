defmodule Pleroma.Text do
  @at ?@
  @whitespace 32

  @mention_starters [@at]
  @mention_stoppers [@whitespace]

  @type parsed_text :: [String.t() | {:mention, String.t()} | {:mention, String.t(), String.t()}]

  @spec extract(String.t()) :: parsed_text
  def extract(text) do
    text
    |> String.to_charlist()
    |> run_extract()
    |> List.flatten()
    |> Enum.reduce([], fn
      {:mention, mention}, acc ->
        [{:mention, list_to_string(mention)} | acc]

      {:mention_host, mention, host}, acc ->
        [{:mention, list_to_string(mention), list_to_idna_ascii(host)} | acc]

      string, [list | acc] when is_list(list) ->
        [[string | list] | acc]

      string, acc ->
        [[string] | acc]
    end)
    |> Enum.reverse()
    |> Enum.reduce([], fn
      [x | _], acc when is_list(x) -> [List.to_string(x) | acc]
      x, acc when is_list(x) -> [List.to_string(x) | acc]
      x, acc -> [x | acc]
    end)
    |> List.flatten()
  end

  @spec mentions(parsed_text) :: [String.t()]
  def mentions(textlist) do
    Enum.reduce(textlist, [], fn
      {:mention, mention}, acc -> [mention | acc]
      {:mention, mention, host}, acc -> [mention <> "@" <> host | acc]
      _, acc -> acc
    end)
    |> Enum.reverse()
  end

  @spec username(String.t()) :: String.t()
  @doc "Converts an username to IDNA"
  def username("@" <> string) do
    "@" <> username(string)
  end

  def username(string) do
    if Keyword.get(Application.get_env(:pleroma, :instance), :enable_idna) do
      case String.split(string, "@", parts: 2) do
        [user, domain] ->
          domain = domain |> to_charlist() |> :idna.from_ascii() |> to_string()
          user <> "@" <> domain

        [user] ->
          user
      end
    else
      string
    end
  end

  defp run_extract(text), do: extract(:text, text, [])

  # Start mention mode
  defp extract(:text, [char | rest], acc) when char in @mention_starters do
    extract({:mention, []}, rest, acc)
  end

  # @ in a mention, switch to mention_host
  defp extract({:mention, mention}, [char | rest], acc) when char in @mention_starters do
    extract({:mention_host, mention, []}, rest, acc)
  end

  # Grab chars for a mention
  defp extract({:mention, mention}, [char | rest], acc)
       when (char >= ?a and char <= ?z) or (char >= ?0 and char <= ?9) do
    extract({:mention, [char | mention]}, rest, acc)
  end

  # No more match for a mention, mention acc is empty
  defp extract({:mention, mention}, [char | rest], acc) when length(mention) <= 1 do
    extract(:text, [char | rest], [mention | acc])
  end

  # No more match for a mention.
  defp extract({:mention, mention}, rest, acc) do
    extract(:text, rest, [{:mention, mention} | acc])
  end

  # No more match for a mention-hostname.
  defp extract({:mention_host, mention, host}, [], acc) do
    extract(:text, [], [{:mention_host, mention, host} | acc])
  end

  # Start mention-hostname mode
  defp extract({:mention_host, mention, host}, [char | rest], acc) do
    if valid_hostname?([char | host]) do
      extract({:mention_host, mention, [char | host]}, rest, acc)
    else
      extract(:text, [char | rest], [{:mention_host, mention, host} | acc])
    end
  end

  # Default
  defp extract(_, [], acc) do
    acc
  end

  defp extract(:text, [char | rest], acc) do
    extract(:text, rest, [char | acc])
  end

  defp valid_hostname?(hostname) do
    hostname
    |> Enum.reverse()
    |> :idna.to_ascii()
    |> valid_hostname?([])
  end

  defp valid_hostname?([], acc), do: true

  defp valid_hostname?([char | rest], acc)
       when (char >= ?a and char <= ?z) or (char >= ?0 and char <= ?9) or char in [?., ?-] do
    valid_hostname?(rest, acc)
  end

  defp valid_hostname?(_, _), do: false

  defp list_to_string(list) do
    list
    |> Enum.reverse()
    |> List.to_string()
  end

  defp list_to_idna_ascii(list) do
    list
    |> Enum.reverse()
    |> :idna.to_ascii()
    |> List.to_string()
  end
end
