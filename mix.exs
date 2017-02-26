defmodule LoggerMulticastBackend.Mixfile do

  use Mix.Project

  @version "0.2.1"
  @github_url "https://github.com/ghitchens/logger_multicast_backend"

  def project do
    [app: :logger_multicast_backend,
     version: @version,
     elixir: "~> 1.4",
     description: description(),
     package: package(),
     deps: deps(),
     # info for docs
     source_url: @github_url,
     docs: [main: "LoggerMulticastBackend",
            extras: ["README.md", "CHANGELOG.md"]]]
  end

  defp description do
    "A Logger backend that logs via Multicast UDP"
  end

  defp package do
    [maintainers: ["Garth Hitchens"],
     licenses: ["MIT"],
     links: %{"GitHub" => @github_url}]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.15", only: :dev}]
  end
end
