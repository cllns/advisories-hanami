# frozen_string_literal: true

module AdvisoriesApp
  module Views
    module Advisories
      class Index < AdvisoriesApp::View
        expose :advisories, :severities, :ecosystems, :packages, :repository_urls, :pagination
        expose :severity, :ecosystem, :package_name, :repository_url, :sort, :order

        def meta_title
          parts = ["Security Advisories"]
          parts << humanize(severity) if severity
          parts << ecosystem if ecosystem
          parts << package_name if package_name
          parts << "Ecosyste.ms: Advisories"
          parts.join(" | ")
        end

        def meta_description
          desc = "Browse"
          desc += " #{humanize(severity)}" if severity
          desc += " Security Advisories"
          desc += " for #{package_name}" if package_name
          desc += " for #{repository_url}" if repository_url
          desc += " in #{ecosystem}" if ecosystem
          desc
        end
      end
    end
  end
end
