Apipie.configure do |config|
  config.app_name = "Project API"
  config.api_base_url = "/api"
  config.doc_base_url = "/apipie"
  config.default_version = "1"
  config.validate = false
  config.api_controllers_matcher = File.join(Rails.root, "app", "controllers", "api", "v1", "**", "*.rb")
end
