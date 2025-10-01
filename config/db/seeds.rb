# This seeds file should create the database records required to run the app.
#
# The code should be idempotent so that it can be executed at any time.
#
# To load the seeds, run `hanami db seed`. Seeds are also loaded as part of `hanami db prepare`.

# Get relations directly for seeding
sources = Hanami.app["relations.sources"]
registries = Hanami.app["relations.registries"]
advisories = Hanami.app["relations.advisories"]

# Create default sources
default_sources = [
  {
    name: 'GitHub Advisory Database',
    kind: 'github',
    url: 'https://github.com/advisories',
    metadata: "{}"
  },
  {
    name: 'OSV Database',
    kind: 'osv',
    url: 'https://osv.dev',
    metadata: "{}"
  },
  {
    name: 'CVE Database',
    kind: 'cve',
    url: 'https://cve.mitre.org',
    metadata: "{}"
  }
]

default_sources.each do |source_attrs|
  existing = sources.where(url: source_attrs[:url]).one
  unless existing
    sources.insert(source_attrs.merge(
      created_at: Time.now,
      updated_at: Time.now
    ))
    puts "Created source: #{source_attrs[:name]}"
  end
end

# Create default registries
default_registries = [
  {
    name: 'npmjs.org',
    url: 'https://www.npmjs.com',
    ecosystem: 'npm',
    default: true,
    github: 'npm/registry',
    metadata: "{}"
  },
  {
    name: 'rubygems.org',
    url: 'https://rubygems.org',
    ecosystem: 'rubygems',
    default: true,
    github: 'rubygems/rubygems.org',
    metadata: "{}"
  },
  {
    name: 'pypi.org',
    url: 'https://pypi.org',
    ecosystem: 'pypi',
    default: true,
    github: 'pypa/warehouse',
    metadata: "{}"
  },
  {
    name: 'crates.io',
    url: 'https://crates.io',
    ecosystem: 'cargo',
    default: true,
    github: 'rust-lang/crates.io',
    metadata: "{}"
  },
  {
    name: 'pkg.go.dev',
    url: 'https://pkg.go.dev',
    ecosystem: 'go',
    default: true,
    github: 'golang/pkgsite',
    metadata: "{}"
  },
  {
    name: 'nuget.org',
    url: 'https://www.nuget.org',
    ecosystem: 'nuget',
    default: true,
    github: 'NuGet/NuGetGallery',
    metadata: "{}"
  },
  {
    name: 'maven.org',
    url: 'https://central.sonatype.com',
    ecosystem: 'maven',
    default: true,
    github: 'sonatype/nexus-public',
    metadata: "{}"
  }
]

default_registries.each do |registry_attrs|
  existing = registries.where(name: registry_attrs[:name], ecosystem: registry_attrs[:ecosystem]).one
  unless existing
    registries.insert(registry_attrs.merge(
      created_at: Time.now,
      updated_at: Time.now
    ))
    puts "Created registry: #{registry_attrs[:name]} (#{registry_attrs[:ecosystem]})"
  end
end

# Create sample advisory
github_source = sources.where(kind: 'github').one
if github_source && advisories.count == 0
  advisories.insert({
    source_id: github_source[:id],
    uuid: 'GHSA-example-1234',
    url: 'https://github.com/advisories/GHSA-example-1234',
    title: 'Example Security Advisory',
    description: 'This is a sample security advisory for demonstration purposes.',
    origin: 'github',
    severity: 'high',
    published_at: Time.now - 30 * 24 * 60 * 60, # 30 days ago
    classification: 'malicious',
    cvss_score: 7.5,
    cvss_vector: 'CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N',
    references: "{https://example.com/advisory}",
    source_kind: 'github',
    identifiers: "{CVE-2023-12345,GHSA-example-1234}",
    packages: '[{"ecosystem":"npm","package_name":"example-package","versions":[{"vulnerable_version_range":"< 1.2.3","first_patched_version":"1.2.3"}]}]',
    created_at: Time.now,
    updated_at: Time.now
  })
  puts "Created sample advisory"
end

puts "Seeds completed successfully!"
