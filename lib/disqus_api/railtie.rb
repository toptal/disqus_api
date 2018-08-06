module DisqusApi
  class Railtie < Rails::Railtie
    initializer 'disqus_api.initialize' do
      config_path = Rails.root.join('config', 'disqus_api.yml')

      if config_path.exist?
        DisqusApi.config = YAML.load(ERB.new(config_path.read).result)[Rails.env]
      else
        unless Rails.env.test?
          puts "WARNING: No config/disqus_api.yml provided for Disqus API. Make sure to set configuration manually."
        end
      end
    end
  end
end
