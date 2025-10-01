# frozen_string_literal: true

module AdvisoriesApp
  module Actions
    module API
      module V1
        module Advisories
          class Packages < AdvisoriesApp::Action
            include Deps["repos.advisory_repo"]

            format :html, :json

            def handle(request, response)
              # Set content type to JSON regardless of request Accept header
              response.headers["Content-Type"] = "application/json"
              packages = advisory_repo.packages
              response.body = packages.to_json
            end
          end
        end
      end
    end
  end
end
