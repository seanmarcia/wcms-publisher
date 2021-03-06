# Globally set up elasticsearch client
Elasticsearch::Model.client =
  Elasticsearch::Client.new(
    hosts: Settings.elasticsearch.hosts,
    retry_on_failure: true
  )
