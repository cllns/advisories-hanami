# frozen_string_literal: true

module AdvisoriesApp
  module Structs
    class Advisory < AdvisoriesApp::DB::Struct
      def withdrawn?
        !withdrawn_at.nil?
      end

      def ecosystems
        packages_data = packages || []
        packages_data = JSON.parse(packages_data) if packages_data.is_a?(String)
        packages_data.map { |p| p['ecosystem'] }.uniq.compact
      end

      def package_names
        packages_data = packages || []
        packages_data = JSON.parse(packages_data) if packages_data.is_a?(String)
        packages_data.map { |p| p['package_name'] }.uniq.compact
      end
    end
  end
end
