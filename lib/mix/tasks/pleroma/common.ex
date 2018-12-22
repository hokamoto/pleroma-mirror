defmodule Mix.Tasks.Pleroma.Common do
  defdelegate mix?, to: Pleroma.Application

  @doc "Common functions to be reused in mix tasks"
  def start_pleroma do
    Application.ensure_all_started(:pleroma)
  end

  def get_option(options, opt, prompt, defval \\ nil, defname \\ nil) do
    Keyword.get(options, opt) || shell_prompt(options, opt, prompt, defval, defname)
  end

  def shell_prompt(options, opt, prompt, defval \\ nil, defname \\ nil) do
    if mix?() do
      case Mix.shell().prompt("#{prompt} [#{defname || defval}]") do
        "\n" ->
          case defval do
            nil -> shell_prompt(options, opt, prompt, defval)
            defval -> defval
          end

        opt ->
          opt |> String.trim()
      end
    end
  end

  def shell_yes?(message) do
    if mix?(), do: Mix.shell().yes?(message)
  end

  def shell_info(message) do
    if mix?(), do: Mix.shell().info(message)
  end

  def shell_error(message) do
    if mix?(), do: Mix.shell().error(message)
  end

  def escape_sh_path(path) do
    ~S(') <> String.replace(path, ~S('), ~S(\')) <> ~S(')
  end
end
