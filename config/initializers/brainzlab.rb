# config/initializers/brainzlab.rb
BrainzLab.configure do |config|
  config.secret_key = ENV["BRAINZLAB_SECRET_KEY"]
  config.app_name   = ENV.fetch("BRAINZLAB_APP_NAME", "fun-able")

  # Core Observability (Layer 2)
  config.recall_url = ENV["RECALL_URL"]   # Structured logging
  config.reflex_url = ENV["REFLEX_URL"]   # Error tracking
  config.pulse_url  = ENV["PULSE_URL"]    # APM & distributed tracing
  config.flux_url   = ENV["FLUX_URL"]     # Feature flags

  # Alerting & Secrets
  config.signal_url = ENV["SIGNAL_URL"]   # Alerting hub
  config.vault_url  = ENV["VAULT_URL"]    # Secrets management
end
