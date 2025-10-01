# frozen_string_literal: true

module AdvisoriesApp
  module Actions
    module Api
      module V1
        class Base < AdvisoriesApp::Action
          format :json

          before :set_cors_headers

          private

          def set_cors_headers
            response.headers["Access-Control-Allow-Origin"] = "*"
            response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
            response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
          end

          def render_json(data, status: 200)
            response.status = status
            response.body = data.to_json
          end

          def render_error(message, status: 400)
            render_json({ error: message }, status: status)
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
        end
      end
    end
  end
end