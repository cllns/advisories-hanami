# frozen_string_literal: true

module AdvisoriesApp
  module Actions
    module Advisories
      class Show < AdvisoriesApp::Action
        include Deps["repos.advisory_repo"]

        def handle(request, response)
          advisory = advisory_repo.by_uuid(request.params[:id])

          if advisory.nil?
            response.status = 404
            response.body = ["Advisory not found"]
            return
          end

          if request.accept?("text/html")
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            response.render view, advisory: advisory
          else
            response[:advisory] = advisory
          end
        end
      end
    end
  end
end
