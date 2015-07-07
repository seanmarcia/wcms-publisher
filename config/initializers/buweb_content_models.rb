BuwebContentModels.configure do |config|
  config.elasticsearch_index = Settings.elasticsearch.index_name
  config.urn_namespaces = Settings.urn_namespaces
  config.roz_api_base_url = Settings.roz.api_base_url
  config.roz_files_base_url = Settings.roz.files_base_url
  config.roz_access_id = Settings.roz.access_id
  config.roz_secret_key = Settings.roz.secret_key
end
