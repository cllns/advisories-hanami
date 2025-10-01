# frozen_string_literal: true

require "hanami-sprockets"

module AdvisoriesApp
  module Assets
    # Configure Hanami::Sprockets for this application
    def self.config
      @config ||= Hanami::Assets::Config.new do |config|
        config.path_prefix = "/assets"
        config.digest = Hanami.env == :production
        config.compress = Hanami.env == :production
        config.subresource_integrity = [:sha256]
        config.asset_paths = []
        config.precompile = %w[
          app.scss
          app.js
          bootstrap.css
          bootstrap.js
          chart.js
          ecosystems.scss
          *.png
          *.jpg
          *.gif
          *.svg
        ]
      end
    end

    # Create the assets instance
    def self.instance
      @instance ||= Hanami::Assets.new(
        config: config,
        root: Hanami.app.root
      )
    end
  end
end