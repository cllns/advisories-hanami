# frozen_string_literal: true

module AdvisoriesApp
  module Actions
    module Home
      class Index < AdvisoriesApp::Action
        include Deps["repos.advisory_repo"]

        def handle(request, response)
          response.headers["Content-Type"] = "text/html; charset=utf-8"

          recent_advisories = advisory_repo.recent_advisories(limit: 10)
          advisory_count = advisory_repo.count
          package_count = advisory_repo.package_count

          response.render view, recent_advisories: recent_advisories,
                                advisory_count: advisory_count,
                                package_count: package_count
        end
      end
    end
  end
end
