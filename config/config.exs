import Config

if Mix.env() == :test do
  config :phoenix, :json_library, Jason
end
