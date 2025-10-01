# frozen_string_literal: true

module AdvisoriesApp
  module Actions
    module Advisories
      class Index < AdvisoriesApp::Action
        include Deps["repos.advisory_repo"]

        def handle(request, response)
          # Get severity counts
          severity_scope = advisory_repo.advisories.not_withdrawn
          severity_scope = severity_scope.by_ecosystem(request.params[:ecosystem]) if request.params[:ecosystem]
          severity_scope = severity_scope.by_package_name(request.params[:package_name]) if request.params[:package_name]
          severity_scope = severity_scope.by_repository_url(request.params[:repository_url]) if request.params[:repository_url]

          severity_ids = severity_scope.dataset.select(:id).map(:id)
          if severity_ids.any?
            response[:severities] = advisory_repo.advisories.dataset.db[:advisories]
              .where(id: severity_ids)
              .group(:severity)
              .select(:severity, Sequel.function(:count, Sequel.lit('*')).as(:count))
              .order(Sequel.desc(:count))
              .to_a
              .map { |row| [row[:severity], row[:count]] }
          else
            response[:severities] = []
          end

          # Get ecosystem counts (exclude ecosystem filter for sidebar)
          ecosystem_scope = advisory_repo.advisories.not_withdrawn
          ecosystem_scope = ecosystem_scope.by_severity(request.params[:severity]) if request.params[:severity]
          ecosystem_scope = ecosystem_scope.by_package_name(request.params[:package_name]) if request.params[:package_name]
          ecosystem_scope = ecosystem_scope.by_repository_url(request.params[:repository_url]) if request.params[:repository_url]
          response[:ecosystems] = ecosystem_scope.ecosystem_counts

          # Get package counts (exclude package_name filter for sidebar)
          package_scope = advisory_repo.advisories.not_withdrawn
          package_scope = package_scope.by_severity(request.params[:severity]) if request.params[:severity]
          package_scope = package_scope.by_repository_url(request.params[:repository_url]) if request.params[:repository_url]
          response[:packages] = package_scope.package_counts

          # Get repository URL counts
          repository_scope = advisory_repo.advisories.not_withdrawn
          repository_scope = repository_scope.by_severity(request.params[:severity]) if request.params[:severity]
          repository_scope = repository_scope.by_ecosystem(request.params[:ecosystem]) if request.params[:ecosystem]
          repository_scope = repository_scope.by_package_name(request.params[:package_name]) if request.params[:package_name]

          repository_ids = repository_scope.dataset.select(:id).map(:id)
          if repository_ids.any?
            response[:repository_urls] = advisory_repo.advisories.dataset.db[:advisories]
              .where(id: repository_ids)
              .where(Sequel.~(repository_url: nil))
              .group(:repository_url)
              .select(:repository_url, Sequel.function(:count, Sequel.lit('*')).as(:count))
              .order(Sequel.desc(:count))
              .to_a
              .map { |row| [row[:repository_url], row[:count]] }
          else
            response[:repository_urls] = []
          end

          # Build main result set with all filters
          scope = advisory_repo.advisories.not_withdrawn
          scope = scope.by_severity(request.params[:severity]) if request.params[:severity]
          scope = scope.by_ecosystem(request.params[:ecosystem]) if request.params[:ecosystem]
          scope = scope.by_package_name(request.params[:package_name]) if request.params[:package_name]
          scope = scope.by_repository_url(request.params[:repository_url]) if request.params[:repository_url]

          # Date filtering
          scope = scope.created_after(Time.parse(request.params[:created_after])) if request.params[:created_after]
          scope = scope.updated_after(Time.parse(request.params[:updated_after])) if request.params[:updated_after]

          # Sorting
          scope = apply_sorting(scope, request.params)

          # Simple pagination
          page = (request.params[:page] || 1).to_i
          page = 1 if page < 1
          items_per_page = 25
          offset = (page - 1) * items_per_page

          advisories = scope.limit(items_per_page).offset(offset).to_a
          total_count = scope.dataset.count

          pagination = {
            current_page: page,
            per_page: items_per_page,
            total_count: total_count,
            total_pages: (total_count.to_f / items_per_page).ceil
          }

          if request.accept?("text/html")
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            response.render view,
              advisories: advisories,
              severities: response[:severities],
              ecosystems: response[:ecosystems],
              packages: response[:packages],
              repository_urls: response[:repository_urls],
              pagination: pagination,
              severity: request.params[:severity],
              ecosystem: request.params[:ecosystem],
              package_name: request.params[:package_name],
              repository_url: request.params[:repository_url],
              sort: request.params[:sort],
              order: request.params[:order]
          else
            response[:pagination] = pagination
            response[:advisories] = advisories
            response[:params] = request.params
          end
        end

        private

        def apply_sorting(scope, params)
          return scope.order(Sequel.desc(:published_at)) unless params[:sort] || params[:order]

          sort = params[:sort] || 'created_at'
          order = params[:order] || 'desc'

          sort_columns = sort.split(',').map(&:strip)
          order_directions = order.split(',').map(&:strip)

          valid_columns = %w[id source_id uuid url title description origin severity published_at withdrawn_at
                           classification cvss_score cvss_vector repository_url blast_radius
                           epss_percentage epss_percentile created_at updated_at]

          orders = []
          sort_columns.zip(order_directions).each do |col, ord|
            if valid_columns.include?(col)
              direction = ord&.downcase == 'asc' ? :asc : :desc
              orders << Sequel.send(direction, col.to_sym)
            end
          end

          if orders.any?
            scope.order(*orders)
          else
            scope.order(Sequel.desc(:published_at))
          end
        end
      end
    end
  end
end