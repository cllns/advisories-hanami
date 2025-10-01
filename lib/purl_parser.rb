# frozen_string_literal: true

require 'purl'

class PurlParser
  ECOSYSTEM_MAPPING = {
    'npm' => 'npm',
    'pypi' => 'pypi',
    'gem' => 'rubygems',
    'maven' => 'maven',
    'nuget' => 'nuget',
    'golang' => 'go',
    'go' => 'go',
    'cargo' => 'cargo'
  }.freeze

  def self.parse(purl_string)
    return nil if purl_string.nil? || purl_string.empty?

    begin
      parsed = Purl.parse(purl_string)
      ecosystem = map_ecosystem(parsed.type)
      return nil if ecosystem.nil?

      {
        ecosystem: ecosystem,
        package_name: parsed.name,
        namespace: parsed.namespace,
        version: parsed.version,
        original_purl: purl_string
      }
    rescue => e
      puts "Failed to parse PURL '#{purl_string}': #{e.message}"
      nil
    end
  end

  def self.map_ecosystem(purl_type)
    ECOSYSTEM_MAPPING[purl_type&.downcase]
  end

  def self.generate_purl(ecosystem:, package_name:, version: nil, namespace: nil)
    purl_type = reverse_map_ecosystem(ecosystem)
    return nil if purl_type.nil?

    begin
      Purl::PackageURL.new(
        type: purl_type,
        name: package_name,
        version: version,
        namespace: namespace
      ).to_s
    rescue => e
      puts "Failed to generate PURL for #{ecosystem}/#{package_name}: #{e.message}"
      nil
    end
  end

  def self.reverse_map_ecosystem(ecosystem)
    case ecosystem&.downcase
    when 'npm' then 'npm'
    when 'pypi' then 'pypi'
    when 'rubygems' then 'gem'
    when 'maven' then 'maven'
    when 'nuget' then 'nuget'
    when 'go' then 'golang'
    when 'cargo' then 'cargo'
    else nil
    end
  end
end