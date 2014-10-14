defmodule LoggerMulticastBackend.Mixfile do

  use Mix.Project
 
  def project, do: [
    app: :logger_multicast_backend,
    version: "0.0.1",
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

  defp deps, do: []

end

