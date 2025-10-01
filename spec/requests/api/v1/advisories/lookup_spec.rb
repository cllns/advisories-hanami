# frozen_string_literal: true

RSpec.describe "GET /api/v1/advisories/lookup", type: :request, db: true do
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

  let!(:npm_advisory) do
    repo.create(
      source_id: source,
      uuid: "TEST-LOOKUP-001",
      url: "https://test.com/advisory1",
      title: "Express Vulnerability",
      description: "Critical vulnerability in Express",
      origin: "test",
      severity: "critical",
      published_at: Time.now,
      classification: "malicious",
      cvss_score: 9.0,
      packages: [
        {
          "ecosystem" => "npm",
          "package_name" => "express",
          "versions" => [{"vulnerable_version_range" => "< 4.17.1"}]
        }
      ],
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let!(:rubygems_advisory) do
    repo.create(
      source_id: source,
      uuid: "TEST-LOOKUP-002",
      url: "https://test.com/advisory2",
      title: "Rails Vulnerability",
      description: "Security issue in Rails",
      origin: "test",
      severity: "high",
      published_at: Time.now,
      classification: "vulnerability",
      cvss_score: 7.5,
      packages: [
        {
          "ecosystem" => "rubygems",
          "package_name" => "rails",
          "versions" => [{"vulnerable_version_range" => "< 6.1.4"}]
        }
      ],
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let!(:case_sensitive_advisory) do
    repo.create(
      source_id: source,
      uuid: "TEST-LOOKUP-003",
      url: "https://test.com/advisory3",
      title: "Case Sensitive Package",
      description: "Package with mixed case name",
      origin: "test",
      severity: "medium",
      published_at: Time.now,
      classification: "vulnerability",
      cvss_score: 5.0,
      packages: [
        {
          "ecosystem" => "npm",
          "package_name" => "Express-Utils",
          "versions" => [{"vulnerable_version_range" => "< 1.0.0"}]
        }
      ],
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  describe "GET /api/v1/advisories/lookup" do
    it "returns advisories for valid npm PURL" do
      get "/api/v1/advisories/lookup?purl=pkg:npm/express@4.16.0"

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include("application/json")

      json = JSON.parse(last_response.body)
      expect(json).to have_key("purl")
      expect(json).to have_key("parsed_purl")
      expect(json).to have_key("advisories")

      expect(json["purl"]).to eq("pkg:npm/express@4.16.0")
      expect(json["parsed_purl"]).to include(
        "ecosystem" => "npm",
        "package_name" => "express",
        "version" => "4.16.0"
      )

      expect(json["advisories"]).to be_an(Array)
      expect(json["advisories"].size).to eq(1)
      expect(json["advisories"].first["uuid"]).to eq("TEST-LOOKUP-001")
    end

    it "returns advisories for valid rubygems PURL" do
      get "/api/v1/advisories/lookup?purl=pkg:gem/rails@6.0.0"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json["parsed_purl"]).to include(
        "ecosystem" => "rubygems",
        "package_name" => "rails",
        "version" => "6.0.0"
      )

      expect(json["advisories"].size).to eq(1)
      expect(json["advisories"].first["uuid"]).to eq("TEST-LOOKUP-002")
    end

    it "includes source information in advisory results" do
      get "/api/v1/advisories/lookup?purl=pkg:npm/express@4.16.0"

      json = JSON.parse(last_response.body)
      advisory = json["advisories"].first

      expect(advisory).to have_key("source")
      expect(advisory["source"]).to include(
        "id" => source,
        "name" => "Test Source",
        "kind" => "test",
        "url" => "https://test.com"
      )
    end

    it "handles PURL without version" do
      get "/api/v1/advisories/lookup?purl=pkg:npm/express"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json["parsed_purl"]["version"]).to be_nil
      expect(json["advisories"].size).to eq(1)
    end

    it "handles PURL with namespace" do
      get "/api/v1/advisories/lookup?purl=pkg:npm/@types/express@4.16.0"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json["parsed_purl"]).to include(
        "ecosystem" => "npm",
        "namespace" => "@types",
        "package_name" => "express",
        "version" => "4.16.0"
      )
    end

    it "returns empty results for non-existent package" do
      get "/api/v1/advisories/lookup?purl=pkg:npm/non-existent-package@1.0.0"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json["advisories"]).to be_empty
    end

    it "handles case-insensitive package name matching" do
      get "/api/v1/advisories/lookup?purl=pkg:npm/express-utils@0.5.0"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json["advisories"].size).to eq(1)
      expect(json["advisories"].first["uuid"]).to eq("TEST-LOOKUP-003")
    end

    it "returns 400 for missing PURL parameter" do
      get "/api/v1/advisories/lookup"

      expect(last_response.status).to eq(400)
      json = JSON.parse(last_response.body)
      expect(json["error"]).to eq("PURL parameter is required")
    end

    it "returns 400 for empty PURL parameter" do
      get "/api/v1/advisories/lookup?purl="

      expect(last_response.status).to eq(400)
      json = JSON.parse(last_response.body)
      expect(json["error"]).to eq("PURL parameter is required")
    end

    it "returns 400 for invalid PURL format" do
      get "/api/v1/advisories/lookup?purl=invalid-purl-format"

      expect(last_response.status).to eq(400)
      json = JSON.parse(last_response.body)
      expect(json["error"]).to eq("Invalid PURL format")
    end

    it "returns 400 for PURL with unsupported ecosystem" do
      get "/api/v1/advisories/lookup?purl=pkg:unsupported/package@1.0.0"

      expect(last_response.status).to eq(400)
      json = JSON.parse(last_response.body)
      expect(json["error"]).to eq("Invalid PURL format")
    end

    it "handles multiple advisories for same package" do
      # Create another advisory for the same package
      repo.create(
        source_id: source,
        uuid: "TEST-LOOKUP-004",
        url: "https://test.com/advisory4",
        title: "Another Express Vulnerability",
        description: "Another critical vulnerability in Express",
        origin: "test",
        severity: "high",
        published_at: Time.now - 3600,
        classification: "vulnerability",
        cvss_score: 8.0,
        packages: [
          {
            "ecosystem" => "npm",
            "package_name" => "express",
            "versions" => [{"vulnerable_version_range" => "< 4.18.0"}]
          }
        ],
        created_at: Time.now,
        updated_at: Time.now
      )

      get "/api/v1/advisories/lookup?purl=pkg:npm/express@4.16.0"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json["advisories"].size).to eq(2)
      uuids = json["advisories"].map { |a| a["uuid"] }
      expect(uuids).to include("TEST-LOOKUP-001", "TEST-LOOKUP-004")
    end

    it "supports various ecosystem mappings" do
      ecosystems = [
        ["pkg:npm/package", "npm"],
        ["pkg:pypi/package", "pypi"],
        ["pkg:gem/package", "rubygems"],
        ["pkg:maven/com.example/package", "maven"],
        ["pkg:nuget/package", "nuget"],
        ["pkg:golang/package", "go"],
        ["pkg:go/package", "go"],
        ["pkg:cargo/package", "cargo"]
      ]

      ecosystems.each do |purl_prefix, expected_ecosystem|
        get "/api/v1/advisories/lookup?purl=#{purl_prefix}@1.0.0"

        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json["parsed_purl"]["ecosystem"]).to eq(expected_ecosystem)
      end
    end
  end
end