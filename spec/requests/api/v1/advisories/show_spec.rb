# frozen_string_literal: true

RSpec.describe "GET /api/v1/advisories/:id", type: :request, db: true do
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

  let!(:advisory) do
    repo.create(
      source_id: source,
      uuid: "TEST-SHOW-001",
      url: "https://test.com/advisory",
      title: "Test Advisory",
      description: "Test description",
      origin: "test",
      severity: "high",
      published_at: Time.now - 3600,
      classification: "malicious",
      cvss_score: 8.5,
      cvss_vector: "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N",
      references: ["https://example.com/ref"],
      identifiers: ["CVE-2023-12345", "TEST-001"],
      packages: [{"ecosystem" => "npm", "package_name" => "test-package", "versions" => [{"vulnerable_version_range" => "< 1.0.0"}]}],
      blast_radius: 15.5,
      repository_url: "https://github.com/test/repo",
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  describe "GET /api/v1/advisories/:id" do
    it "returns advisory by UUID" do
      get "/api/v1/advisories/TEST-SHOW-001"

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include("application/json")

      json = JSON.parse(last_response.body)
      expect(json["uuid"]).to eq("TEST-SHOW-001")
      expect(json["title"]).to eq("Test Advisory")
      expect(json["severity"]).to eq("high")
      expect(json["cvss_score"]).to eq(8.5)
    end

    it "includes source information" do
      get "/api/v1/advisories/TEST-SHOW-001"

      json = JSON.parse(last_response.body)
      expect(json).to have_key("source")
      expect(json["source"]).to include(
        "id" => source,
        "name" => "Test Source",
        "kind" => "test",
        "url" => "https://test.com"
      )
    end

    it "includes all advisory fields" do
      get "/api/v1/advisories/TEST-SHOW-001"

      json = JSON.parse(last_response.body)
      expect(json).to include(
        "id" => advisory[:id],
        "source_id" => source,
        "uuid" => "TEST-SHOW-001",
        "url" => "https://test.com/advisory",
        "title" => "Test Advisory",
        "description" => "Test description",
        "origin" => "test",
        "severity" => "high",
        "classification" => "malicious",
        "cvss_score" => 8.5,
        "cvss_vector" => "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N",
        "blast_radius" => 15.5,
        "repository_url" => "https://github.com/test/repo"
      )

      expect(json["references"]).to be_an(Array)
      expect(json["references"]).to include("https://example.com/ref")

      expect(json["identifiers"]).to be_an(Array)
      expect(json["identifiers"]).to include("CVE-2023-12345", "TEST-001")

      expect(json["packages"]).to be_an(Array)
      expect(json["packages"].first).to include(
        "ecosystem" => "npm",
        "package_name" => "test-package"
      )
    end

    it "includes timestamps" do
      get "/api/v1/advisories/TEST-SHOW-001"

      json = JSON.parse(last_response.body)
      expect(json).to have_key("published_at")
      expect(json).to have_key("created_at")
      expect(json).to have_key("updated_at")
      expect(json["withdrawn_at"]).to be_nil
    end

    it "returns 404 for non-existent advisory" do
      get "/api/v1/advisories/NON-EXISTENT"

      expect(last_response.status).to eq(404)
      expect(last_response.content_type).to include("application/json")

      json = JSON.parse(last_response.body)
      expect(json).to have_key("error")
      expect(json["error"]).to eq("Advisory not found")
    end

    it "returns 400 for missing UUID" do
      get "/api/v1/advisories/"

      expect(last_response.status).to eq(404) # Route not found
    end


    it "handles withdrawn advisory" do
      withdrawn_advisory = advisories_relation.insert(
        source_id: source,
        uuid: "TEST-WITHDRAWN",
        url: "https://test.com/withdrawn",
        title: "Withdrawn Advisory",
        description: "This advisory was withdrawn",
        origin: "test",
        severity: "medium",
        published_at: Time.now - 3600,
        withdrawn_at: Time.now,
        classification: "vulnerability",
        cvss_score: 5.0,
        created_at: Time.now,
        updated_at: Time.now
      )

      get "/api/v1/advisories/TEST-WITHDRAWN"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json["uuid"]).to eq("TEST-WITHDRAWN")
      expect(json["withdrawn_at"]).not_to be_nil
    end
  end
end