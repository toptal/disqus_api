if defined?(Rails)
  module DisqusApi
    class Railtie < Rails::Railtie
      initializer 'disqus_api.initialize' do
        config_path = File.join(Rails.root, 'config', "disqus_api.yml")

        if File.exist?(config_path)
          DisqusApi.config = YAML.load_file(File.join(Rails.root, 'config', "disqus_api.yml"))[Rails.env]
        else
          unless Rails.env.test?
            puts "WARNING: No config/disqus_api.yml provided for Disqus API. Make sure to set configuration manually."
          end
        end
      end
    end
  end
end