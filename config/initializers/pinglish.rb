Wcms::Application.config.middleware.use Pinglish do |ping|
  ping.check :mongodb do
    Mongoid.default_client.command(ping: 1).documents.any?{|d| d == {'ok' => 1}}
  end

  ping.check :redis do
    Sidekiq.redis { |r| r.ping == 'PONG' }
  end

  ping.check :elasticsearch do
    Elasticsearch::Model.client.indices.exists index: Settings.elasticsearch.index_name
  end
end
