# frozen_string_literal: true

module AdvisoriesApp
  module Repos
    class AdvisoryRepo < AdvisoriesApp::DB::Repo
      commands :create, update: :by_pk, delete: :by_pk

      def by_uuid(uuid)
        advisories.where(uuid: uuid).one
      end

      def by_ecosystem(ecosystem)
        advisories.by_ecosystem(ecosystem)
      end

      def by_package_name(package_name)
        advisories.by_package_name(package_name)
      end

      def by_severity(severity)
        advisories.by_severity(severity)
      end

      def by_repository_url(repository_url)
        advisories.by_repository_url(repository_url)
      end

      def created_after(created_at)
        advisories.created_after(created_at)
      end

      def updated_after(updated_at)
        advisories.updated_after(updated_at)
      end

      def withdrawn
        advisories.withdrawn
      end

      def not_withdrawn
        advisories.not_withdrawn
      end

      def with_source
        advisories.with_source
      end

      def ecosystems
        advisories.ecosystems_list
      end

      def ecosystem_counts
        advisories.ecosystem_counts
      end

      def package_counts
        advisories.package_counts
      end

      def repository_counts
        advisories.repository_counts
      end

      def packages
        advisories.to_a.flat_map do |advisory|
          packages_data = advisory.packages || []
          packages_data = JSON.parse(packages_data) if packages_data.is_a?(String)
          packages_data.map { |p| p.except("versions") }
        end.uniq
      end

      def recent_advisories(limit: 10)
        advisories.order { created_at.desc }.limit(limit).to_a
      end

      def count
        advisories.count
      end

      def package_count
        advisories.to_a.flat_map do |advisory|
          packages_data = advisory.packages || []
          packages_data = JSON.parse(packages_data) if packages_data.is_a?(String)
          packages_data.map { |p| p.except("versions") }
        end.uniq.count
      end

      def update_blast_radius(id)
        advisory = advisories.by_pk(id).one!
        blast_radius = calculate_blast_radius_for(advisory)
        advisories.by_pk(id).update(blast_radius: blast_radius)
      end

      private

      def calculate_blast_radius_for(advisory)
        packages_data = advisory.packages || []
        ecosystems = packages_data.map { |p| p['ecosystem'] }.uniq

        ecosystems.map do |ecosystem|
          ecosystem_packages = packages_data.select { |p| p['ecosystem'] == ecosystem }
          # In a real implementation, you'd look up package records here
          # For now, return a default calculation
          cvss_score = advisory.cvss_score || 5.0
          Math.log10(1000) * cvss_score # placeholder calculation
        end.sum
      end
    end
  end
end
