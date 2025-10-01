# frozen_string_literal: true

require_relative '../../../../../lib/purl_parser'

module AdvisoriesApp
  module Actions
    module API
      module V1
        module Advisories
          class Lookup < AdvisoriesApp::Action
            include Deps["repos.advisory_repo"]

            format :html, :json

            def handle(request, response)
              # Set content type to JSON regardless of request Accept header
              response.headers["Content-Type"] = "application/json"
              purl = request.params[:purl]

              if purl.nil? || purl.empty?
                response.status = 400
                response.body = { error: 'PURL parameter is required' }.to_json
                return
              end

              parsed_purl = PurlParser.parse(purl)

              if parsed_purl.nil?
                response.status = 400
                response.body = { error: 'Invalid PURL format' }.to_json
                return
              end

              advisories_relation = advisory_repo.advisories
                .by_ecosystem(parsed_purl[:ecosystem])
                .by_package_name(parsed_purl[:package_name])

              advisories = advisories_relation.to_a.map do |advisory|
                advisory_hash = advisory.to_h
                advisory_hash[:source] = get_source_info(advisory.source_id) if advisory.source_id
                advisory_hash
              end

              result = {
                purl: purl,
                parsed_purl: parsed_purl,
                advisories: advisories
              }

              response.body = result.to_json
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
