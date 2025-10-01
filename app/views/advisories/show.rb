# frozen_string_literal: true

module AdvisoriesApp
  module Views
    module Advisories
      class Show < AdvisoriesApp::View
        expose :advisory

        def meta_title
          "#{advisory.title} | Security Advisories"
        end

        def meta_description
          "#{advisory.title}. #{advisory.description}"
        end
      end
    end
  end
end
