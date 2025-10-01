# frozen_string_literal: true

module AdvisoriesApp
  module Relations
    class Advisories < AdvisoriesApp::DB::Relation
      schema :advisories, infer: true

      def by_ecosystem(ecosystem)
        where(Sequel.lit("EXISTS (SELECT 1 FROM jsonb_array_elements(packages) AS p WHERE p->>'ecosystem' = ?)", ecosystem.downcase))
      end

      def by_package_name(package_name)
        where(
          Sequel.lit("EXISTS (SELECT 1 FROM jsonb_array_elements(packages) AS p WHERE LOWER(p->>'package_name') = LOWER(?))", package_name)
        )
      end

      def by_severity(severity)
        where(severity: severity)
      end

      def by_repository_url(repository_url)
        where(repository_url: repository_url)
      end

      def created_after(created_at)
        where(Sequel.lit('created_at > ?', created_at))
      end

      def updated_after(updated_at)
        where(Sequel.lit('updated_at > ?', updated_at))
      end

      def withdrawn
        where(Sequel.~(withdrawn_at: nil))
      end

      def not_withdrawn
        where(withdrawn_at: nil)
      end

      def with_source
        join(:sources, id: :source_id)
      end

      def ecosystems_list
        dataset.db[<<~SQL].all.map { |row| row[:ecosystem] }.compact.uniq
          SELECT DISTINCT package_element->>'ecosystem' as ecosystem
          FROM (
            SELECT jsonb_array_elements(packages) as package_element
            FROM (#{dataset.sql}) as scoped_advisories
          ) as package_elements
        SQL
      end

      def ecosystem_counts
        dataset.db[<<~SQL].all.map { |row| [row[:ecosystem], row[:count]] }
          SELECT
            package_element->>'ecosystem' as ecosystem,
            COUNT(*) as count
          FROM (
            SELECT jsonb_array_elements(packages) as package_element
            FROM (#{dataset.sql}) as scoped_advisories
          ) as package_elements
          GROUP BY package_element->>'ecosystem'
          ORDER BY count DESC
        SQL
      end

      def package_counts
        dataset.db[<<~SQL].all.map { |row| [row[:package], row[:count]] }
          SELECT
            jsonb_build_object(
              'ecosystem', package_element->>'ecosystem',
              'package_name', package_element->>'package_name'
            ) as package,
            COUNT(*) as count
          FROM (
            SELECT jsonb_array_elements(packages) as package_element
            FROM (#{dataset.sql}) as scoped_advisories
          ) as package_elements
          GROUP BY package_element->>'ecosystem', package_element->>'package_name'
          ORDER BY count DESC
        SQL
      end

      def repository_counts
        group(:repository_url).count
      end
    end
  end
end
