BiolaWebServices.configure do |config|
  config.url          = Settings.ws.url
  config.cert_path    = Settings.ws.cert_path
  config.key_path     = Settings.ws.key_path
  config.key_password = Settings.ws.key_password
  config.verify_ssl   = Settings.ws.verify_ssl
end
