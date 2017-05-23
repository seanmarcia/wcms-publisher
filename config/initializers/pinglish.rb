Wcms::Application.config.middleware.use Pinglish do |ping|
  ping.check :mongodb do
    Mongoid.default_client.command(ping: 1).documents.any?{|d| d == {'ok' => 1}}
  end

  ping.check :redis do
    Sidekiq.redis { |r| r.ping == 'PONG' }
  end

  ping.check :ws do
    BiolaWebServices.dirsvc.get_directories.map{|d| d['api'] }.compact.length > 0
  end

  ping.check :elasticsearch do
    Elasticsearch::Model.client.indices.exists index: Settings.elasticsearch.index_name
  end

  ping.check :smtp do
    smtp = Net::SMTP.new(ActionMailer::Base.smtp_settings[:address])
    smtp.start
    ok = smtp.started?
    smtp.finish

    ok
  end
end
