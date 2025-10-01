# frozen_string_literal: true

RSpec.describe "GET /api/v1/advisories/packages", type: :request, db: true do
  let(:sources_relation) { Hanami.app["relations.sources"] }
  let(:advisories_relation) { Hanami.app["relations.advisories"] }
  let(:repo) { Hanami.app["repos.advisory_repo"] }

  let!(:source) do
    sources_relation.insert(
      name: "Test Source",
      kind: "test",
      url: "https://test.com",
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let!(:advisory1) do
    repo.create(
      source_id: source,
      uuid: "TEST-PKG-001",
      url: "https://test.com/advisory1",
      title: "NPM Advisory",
      description: "NPM package advisory",
      origin: "test",
      severity: "high",
      published_at: Time.now,
      classification: "malicious",
      cvss_score: 8.5,
      packages: [
        {
          "ecosystem" => "npm",
          "package_name" => "express",
          "versions" => [{"vulnerable_version_range" => "< 4.0.0"}]
        }
      ],
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let!(:advisory2) do
    repo.create(
      source_id: source,
      uuid: "TEST-PKG-002",
      url: "https://test.com/advisory2",
      title: "RubyGems Advisory",
      description: "RubyGems package advisory",
      origin: "test",
      severity: "medium",
      published_at: Time.now,
      classification: "vulnerability",
      cvss_score: 5.0,
      packages: [
        {
          "ecosystem" => "rubygems",
          "package_name" => "rails",
          "versions" => [{"vulnerable_version_range" => "< 6.0.0"}]
        }
      ],
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let!(:advisory3) do
    repo.create(
      source_id: source,
      uuid: "TEST-PKG-003",
      url: "https://test.com/advisory3",
      title: "Multi-package Advisory",
      description: "Advisory affecting multiple packages",
      origin: "test",
      severity: "medium",
      published_at: Time.now,
      classification: "vulnerability",
      cvss_score: 6.0,
      packages: [
        {
          "ecosystem" => "npm",
          "package_name" => "lodash",
          "versions" => [{"vulnerable_version_range" => "< 4.17.21"}]
        },
        {
          "ecosystem" => "pypi",
          "package_name" => "django",
          "versions" => [{"vulnerable_version_range" => "< 3.2.0"}]
        }
      ],
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  describe "GET /api/v1/advisories/packages" do
    it "returns all unique packages without versions" do
      get "/api/v1/advisories/packages"

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include("application/json")

      json = JSON.parse(last_response.body)
      expect(json).to be_an(Array)
      expect(json.size).to eq(4) # express, rails, lodash, django
    end

    it "excludes version information from packages" do
      get "/api/v1/advisories/packages"

      json = JSON.parse(last_response.body)
      json.each do |package|
        expect(package).to have_key("ecosystem")
        expect(package).to have_key("package_name")
        expect(package).not_to have_key("versions")
      end
    end

    it "returns correct package information" do
      get "/api/v1/advisories/packages"

      json = JSON.parse(last_response.body)

      express_package = json.find { |p| p["package_name"] == "express" }
      expect(express_package).to include(
        "ecosystem" => "npm",
        "package_name" => "express"
      )

      rails_package = json.find { |p| p["package_name"] == "rails" }
      expect(rails_package).to include(
        "ecosystem" => "rubygems",
        "package_name" => "rails"
      )

      lodash_package = json.find { |p| p["package_name"] == "lodash" }
      expect(lodash_package).to include(
        "ecosystem" => "npm",
        "package_name" => "lodash"
      )

      django_package = json.find { |p| p["package_name"] == "django" }
      expect(django_package).to include(
        "ecosystem" => "pypi",
        "package_name" => "django"
      )
    end

    it "handles duplicate packages correctly" do
      # Create another advisory with the same package
      repo.create(
        source_id: source,
        uuid: "TEST-PKG-004",
        url: "https://test.com/advisory4",
        title: "Another Express Advisory",
        description: "Another advisory for express",
        origin: "test",
        severity: "low",
        published_at: Time.now,
        classification: "vulnerability",
        cvss_score: 3.0,
        packages: [
          {
            "ecosystem" => "npm",
            "package_name" => "express",
            "versions" => [{"vulnerable_version_range" => "< 4.5.0"}]
          }
        ],
        created_at: Time.now,
        updated_at: Time.now
      )

      get "/api/v1/advisories/packages"

      json = JSON.parse(last_response.body)
      express_packages = json.select { |p| p["package_name"] == "express" }
      expect(express_packages.size).to eq(1) # Should be unique
    end

    it "handles advisories with no packages" do
      repo.create(
        source_id: source,
        uuid: "TEST-PKG-005",
        url: "https://test.com/advisory5",
        title: "No Package Advisory",
        description: "Advisory with no packages",
        origin: "test",
        severity: "low",
        published_at: Time.now,
        classification: "informational",
        packages: [],
        created_at: Time.now,
        updated_at: Time.now
      )

      get "/api/v1/advisories/packages"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to be_an(Array)
      expect(json.size).to eq(4) # Still the same 4 packages
    end

    it "handles advisories with null packages field" do
      repo.create(
        source_id: source,
        uuid: "TEST-PKG-006",
        url: "https://test.com/advisory6",
        title: "Null Package Advisory",
        description: "Advisory with null packages",
        origin: "test",
        severity: "low",
        published_at: Time.now,
        classification: "informational",
        packages: nil,
        created_at: Time.now,
        updated_at: Time.now
      )

      get "/api/v1/advisories/packages"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to be_an(Array)
    end

    it "returns empty array when no advisories exist" do
      # Clean up all test data
      advisories_relation.dataset.delete

      get "/api/v1/advisories/packages"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to eq([])
    end
  end
end