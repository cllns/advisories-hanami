# frozen_string_literal: true

require "hanami/boot"
require_relative "config/assets"

# Add assets middleware for development
use Hanami::Assets::Middleware, AdvisoriesApp::Assets.instance

run Hanami.app
