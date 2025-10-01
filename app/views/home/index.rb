# frozen_string_literal: true

module AdvisoriesApp
  module Views
    module Home
      class Index < AdvisoriesApp::View
        expose :recent_advisories, :advisory_count, :package_count

        def meta_title
          "Ecosyste.ms: Advisories"
        end

        def meta_description
          "Browse all Security Advisories"
        end
      end
    end
  end
end
