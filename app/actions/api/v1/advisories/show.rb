# frozen_string_literal: true

module AdvisoriesApp
  module Actions
    module API
      module V1
        module Advisories
          class Show < AdvisoriesApp::Action
            include Deps["repos.advisory_repo"]

            format :html, :json

            def handle(request, response)
              # Set content type to JSON regardless of request Accept header
              response.headers["Content-Type"] = "application/json"
              uuid = request.params[:id]

              unless uuid
                response.status = 400
                response.body = { error: "Advisory UUID is required" }.to_json
                return
              end

              advisory = advisory_repo.by_uuid(uuid)

              unless advisory
                response.status = 404
                response.body = { error: "Advisory not found" }.to_json
                return
              end

              # Convert to hash and add source information
              advisory_hash = advisory.to_h
              advisory_hash[:source] = get_source_info(advisory.source_id) if advisory.source_id

              response.body = advisory_hash.to_json
            end

            private

            def get_source_info(source_id)
              sources_relation = advisory_repo.advisories.dataset.db[:sources]
              source = sources_relation.where(id: source_id).first
              return nil unless source

              {
                id: source[:id],
                name: source[:name],
                kind: source[:kind],
                url: source[:url]
              }
            end
          end
        end
      end
    end
  end
end
