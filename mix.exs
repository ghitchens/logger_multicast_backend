defmodule LoggerMulticastBackend.Mixfile do

  use Mix.Project

  def project, do: [
    app: :logger_multicast_backend,
    version: version,
    elixir: "~> 1.0",
    description: description,
    package: package,
    deps: deps
  ]

  defp description, do: "Logger backend using Multicast UDP"

  defp package, do: [
    contributors: ["Garth Hitchens"],
    licenses: ["MIT"],
    links: %{"GitHub" => "https://github.com/ghitchens/logger_file_backend"}
  ]

  def application, do: [ applications: [:logger] ]

  defp deps, do: [
    {:earmark, "~> 0.1", only: :dev},
    {:ex_doc, "~> 0.7", only: :dev}
  ]

  defp version do
    case File.read("VERSION") do
      {:ok, ver} -> String.strip ver
      _ -> "0.0.0-dev"
    end
  end
end
