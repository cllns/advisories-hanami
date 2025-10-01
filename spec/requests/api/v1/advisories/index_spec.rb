# frozen_string_literal: true

RSpec.describe "GET /api/v1/advisories", type: :request, db: true do
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
      uuid: "TEST-API-001",
      url: "https://test.com/advisory1",
      title: "High Severity Advisory",
      description: "High severity test advisory",
      origin: "test",
      severity: "high",
      published_at: Time.now - 3600,
      classification: "malicious",
      cvss_score: 8.5,
      packages: [{"ecosystem" => "npm", "package_name" => "test-package-1"}],
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let!(:advisory2) do
    repo.create(
      source_id: source,
      uuid: "TEST-API-002",
      url: "https://test.com/advisory2",
      title: "Medium Severity Advisory",
      description: "Medium severity test advisory",
      origin: "test",
      severity: "medium",
      published_at: Time.now - 7200,
      classification: "vulnerability",
      cvss_score: 5.0,
      packages: [{"ecosystem" => "rubygems", "package_name" => "test-package-2"}],
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let!(:advisory3) do
    repo.create(
      source_id: source,
      uuid: "TEST-API-003",
      url: "https://test.com/advisory3",
      title: "Withdrawn Advisory",
      description: "Withdrawn test advisory",
      origin: "test",
      severity: "low",
      published_at: Time.now - 10800,
      classification: "vulnerability",
      cvss_score: 3.0,
      packages: [{"ecosystem" => "npm", "package_name" => "test-package-3"}],
      withdrawn_at: Time.now,
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  describe "GET /api/v1/advisories" do
    it "returns all advisories with pagination" do
      get "/api/v1/advisories"

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include("application/json")

      json = JSON.parse(last_response.body)
      expect(json).to have_key("data")
      expect(json).to have_key("pagination")

      expect(json["data"]).to be_an(Array)
      expect(json["data"].size).to eq(3)

      expect(json["pagination"]).to include(
        "current_page" => 1,
        "per_page" => 25,
        "total_count" => 3,
        "total_pages" => 1
      )
    end

    it "includes source information in response" do
      get "/api/v1/advisories"

      json = JSON.parse(last_response.body)
      advisory = json["data"].first

      expect(advisory).to have_key("source")
      expect(advisory["source"]).to include(
        "id" => source,
        "name" => "Test Source",
        "kind" => "test",
        "url" => "https://test.com"
      )
    end

    it "supports pagination parameters" do
      get "/api/v1/advisories?page=1&per_page=2"

      json = JSON.parse(last_response.body)
      expect(json["data"].size).to eq(2)
      expect(json["pagination"]["per_page"]).to eq(2)
      expect(json["pagination"]["current_page"]).to eq(1)
    end

    it "filters by severity" do
      get "/api/v1/advisories?severity=high"

      json = JSON.parse(last_response.body)
      expect(json["data"].size).to eq(1)
      expect(json["data"].first["severity"]).to eq("high")
      expect(json["data"].first["uuid"]).to eq("TEST-API-001")
    end

    it "filters by ecosystem" do
      get "/api/v1/advisories?ecosystem=npm"

      json = JSON.parse(last_response.body)
      expect(json["data"].size).to eq(2)
      json["data"].each do |advisory|
        packages = advisory["packages"]
        expect(packages.any? { |p| p["ecosystem"] == "npm" }).to be true
      end
    end

    it "filters by package name" do
      get "/api/v1/advisories?package_name=test-package-1"

      json = JSON.parse(last_response.body)
      expect(json["data"].size).to eq(1)
      expect(json["data"].first["uuid"]).to eq("TEST-API-001")
    end

    it "supports sorting by published_at desc (default)" do
      get "/api/v1/advisories"

      json = JSON.parse(last_response.body)
      uuids = json["data"].map { |a| a["uuid"] }
      expect(uuids).to eq(["TEST-API-001", "TEST-API-002", "TEST-API-003"])
    end

    it "supports sorting by published_at asc" do
      get "/api/v1/advisories?sort=published_at&order=asc"

      json = JSON.parse(last_response.body)
      uuids = json["data"].map { |a| a["uuid"] }
      expect(uuids).to eq(["TEST-API-003", "TEST-API-002", "TEST-API-001"])
    end

    it "supports sorting by severity desc" do
      get "/api/v1/advisories?sort=severity&order=desc"

      json = JSON.parse(last_response.body)
      severities = json["data"].map { |a| a["severity"] }
      expect(severities.first).to eq("medium")  # Alphabetically last
    end

    it "filters by created_after" do
      timestamp = (Time.now - 1800).iso8601  # 30 minutes ago
      get "/api/v1/advisories?created_after=#{timestamp}"

      json = JSON.parse(last_response.body)
      expect(json["data"].size).to eq(3)  # All created recently
    end

    it "filters by updated_after" do
      timestamp = (Time.now + 3600).iso8601  # 1 hour in future
      get "/api/v1/advisories?updated_after=#{timestamp}"

      json = JSON.parse(last_response.body)
      expect(json["data"].size).to eq(0)  # None updated in future
    end

    it "handles invalid date format gracefully" do
      get "/api/v1/advisories?created_after=invalid-date"

      expect(last_response.status).to be >= 400
    end

    it "limits per_page to maximum of 100" do
      get "/api/v1/advisories?per_page=200"

      json = JSON.parse(last_response.body)
      expect(json["pagination"]["per_page"]).to eq(100)
    end

    it "handles empty results" do
      get "/api/v1/advisories?severity=critical"

      json = JSON.parse(last_response.body)
      expect(json["data"]).to be_empty
      expect(json["pagination"]["total_count"]).to eq(0)
    end
  end
end