# frozen_string_literal: true

module AdvisoriesApp
  module Actions
    module API
      module V1
        module Advisories
          class Index < AdvisoriesApp::Action
            include Deps["repos.advisory_repo"]

            format :html, :json

            def handle(request, response)
              # Set content type to JSON regardless of request Accept header
              response.headers["Content-Type"] = "application/json"
              advisories_relation = build_filtered_relation(request.params)
              advisories_relation = apply_sorting(advisories_relation, request.params)

              page = request.params[:page] || 1
              per_page = request.params[:per_page] || 25

              result = paginate(advisories_relation, page: page, per_page: per_page)

              # Transform advisories to include source information
              result[:data] = result[:data].map do |advisory|
                advisory_hash = advisory.to_h
                advisory_hash[:source] = get_source_info(advisory.source_id) if advisory.source_id
                advisory_hash
              end

              response.body = result.to_json
            end

            private

            def build_filtered_relation(params)
              relation = advisory_repo.advisories

              # Apply filters
              relation = relation.by_severity(params[:severity]) if params[:severity]
              relation = relation.by_ecosystem(params[:ecosystem]) if params[:ecosystem]
              relation = relation.by_package_name(params[:package_name]) if params[:package_name]
              relation = relation.by_repository_url(params[:repository_url]) if params[:repository_url]
              if params[:created_after]
                begin
                  relation = relation.created_after(Time.parse(params[:created_after]))
                rescue ArgumentError
                  halt 400, JSON.generate(error: "Invalid date format for created_after")
                end
              end
              if params[:updated_after]
                begin
                  relation = relation.updated_after(Time.parse(params[:updated_after]))
                rescue ArgumentError
                  halt 400, JSON.generate(error: "Invalid date format for updated_after")
                end
              end

              relation
            end

            def apply_sorting(relation, params)
              return relation unless params[:sort] || params[:order]

              sort_field = params[:sort] || 'published_at'
              order_direction = params[:order] || 'desc'

              case order_direction.downcase
              when 'asc'
                relation.order(Sequel.asc(sort_field.to_sym))
              else
                relation.order(Sequel.desc(sort_field.to_sym))
              end
            end

            def paginate(relation, page: 1, per_page: 25)
              page = [page.to_i, 1].max
              per_page = [[per_page.to_i, 100].min, 1].max

              offset = (page - 1) * per_page

              total_count = relation.count
              items = relation.offset(offset).limit(per_page).to_a

              {
                data: items,
                pagination: {
                  current_page: page,
                  per_page: per_page,
                  total_count: total_count,
                  total_pages: (total_count.to_f / per_page).ceil
                }
              }
            end

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
