# auto_register: false
# frozen_string_literal: true

module AdvisoriesApp
  module Views
    module Helpers
      include Hanami::Assets::Helpers
      # Meta and App Information
      def meta_title
        'Ecosyste.ms: Advisories'
      end

      def meta_description
        app_description
      end

      def app_name
        "Advisories"
      end

      def app_description
        "Essential vulnerability data for your ecosystem"
      end

      # Severity Badge Helper
      def severity_class(severity)
        case severity&.downcase
        when 'low'
          'bg-success'
        when 'moderate'
          'text-bg-warning'
        when 'high'
          'bg-danger'
        when 'critical'
          'bg-dark'
        else
          'text-bg-info'
        end
      end

      # GitHub Integration
      def github_repo_name
        "advisories"
      end

      # Time Helper
      def time_ago_in_words(time)
        return "" unless time

        diff = Time.now - time
        case diff
        when 0..59
          "less than a minute ago"
        when 60..3599
          "#{(diff / 60).round} minutes ago"
        when 3600..86399
          "#{(diff / 3600).round} hours ago"
        when 86400..2591999
          "#{(diff / 86400).round} days ago"
        when 2592000..31535999
          "#{(diff / 2592000).round} months ago"
        else
          "#{(diff / 31536000).round} years ago"
        end
      end

      # Number Helper
      def number_with_delimiter(number)
        number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      end

      # Markdown Rendering (simple fallback without CommonMarker)
      def render_markdown(str)
        return "" unless str
        # Simple markdown-like rendering for now
        html = str.gsub(/\*\*(.*?)\*\*/, '<strong>\1</strong>')
        html = html.gsub(/\*(.*?)\*/, '<em>\1</em>')
        html = html.gsub(/\n/, '<br>')
        html.html_safe
      end

      # Ecosystem Services Menu
      def ecosystems_services
        {
          "Data" => [
            { name: "Packages", url: "https://packages.ecosyste.ms" },
            { name: "Repositories", url: "https://repos.ecosyste.ms" },
            { name: "Advisories", url: "https://advisories.ecosyste.ms" }
          ],
          "Tools" => [
            { name: "Dependency Parser", url: "https://parser.ecosyste.ms" },
            { name: "Resolver", url: "https://resolver.ecosyste.ms" },
            { name: "SBOM Parser", url: "https://sbom.ecosyste.ms" },
            { name: "Diff", url: "https://diff.ecosyste.ms" }
          ],
          "Indexes" => [
            { name: "Timeline", url: "https://timeline.ecosyste.ms" },
            { name: "Commits", url: "https://commits.ecosyste.ms" },
            { name: "Issues", url: "https://issues.ecosyste.ms" }
          ],
          "Applications" => [
            { name: "Funds", url: "https://funds.ecosyste.ms" },
            { name: "Dashboards", url: "https://dashboard.ecosyste.ms" }
          ]
        }
      end

      # Safe param access - returns empty hash if params not available
      def params
        @params ||= {}
      end

      # URL helper for building query parameter URLs
      def url_for(new_params = {})
        query_params = params.merge(new_params).compact
        query_string = query_params.empty? ? "" : "?" + query_params.to_query
        request.path + query_string
      rescue
        "/"
      end


      # String helpers
      def humanize(str)
        return "" unless str
        str.to_s.gsub(/[-_]/, ' ').split.map(&:capitalize).join(' ')
      end

      private

      # Provide assets instance for hanami-sprockets helpers
      def hanami_assets
        AdvisoriesApp::Assets.instance
      end
    end
  end
end
