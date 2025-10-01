# frozen_string_literal: true

RSpec.describe AdvisoriesApp::Structs::Advisory, type: :struct, db: true do
  let(:sources_relation) { Hanami.app["relations.sources"] }
  let(:advisory_repo) { Hanami.app["repos.advisory_repo"] }
  let(:advisory_relation) { Hanami.app["relations.advisories"] }

  let!(:source_id) do
    sources_relation.insert(
      name: "Test Source",
      kind: "test",
      url: "https://test.com",
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let!(:advisory_record) do
    advisory_repo.create(
      source_id: source_id,
      uuid: "STRUCT-TEST-001",
      url: "https://example.com/advisory",
      title: "Test Advisory",
      description: "Test description",
      origin: "test",
      severity: "high",
      published_at: Time.now,
      classification: "malicious",
      cvss_score: 8.5,
      cvss_vector: "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N",
      references: ["https://example.com/ref"],
      identifiers: ["CVE-2023-12345", "TEST-001"],
      packages: [{"ecosystem" => "npm", "package_name" => "test-package", "versions" => [{"vulnerable_version_range" => "< 1.0.0", "first_patched_version" => "1.0.0"}]}],
      blast_radius: 15.5,
      withdrawn_at: nil,
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let(:advisory) { advisory_record }

  describe "basic structure" do
    it "can be instantiated" do
      expect(AdvisoriesApp::Structs::Advisory).to be_a(Class)
    end

    it "has all expected attributes" do
      expect(advisory.uuid).to eq("STRUCT-TEST-001")
      expect(advisory.title).to eq("Test Advisory")
      expect(advisory.severity).to eq("high")
      expect(advisory.cvss_score).to eq(8.5)
    end
  end

  describe "data access" do
    it "provides access to all database fields" do
      expect(advisory.id).to be_a(Integer)
      expect(advisory.source_id).to eq(source_id)
      expect(advisory.origin).to eq("test")
      expect(advisory.classification).to eq("malicious")
    end

    it "handles JSONB and array fields" do
      expect(advisory.packages).to be_a(Array)
      expect(advisory.references).to be_a(Array)
      expect(advisory.identifiers).to be_a(Array)
    end

    it "handles timestamp fields" do
      expect(advisory.published_at).to be_a(Time)
      expect(advisory.created_at).to be_a(Time)
      expect(advisory.updated_at).to be_a(Time)
    end

    it "handles optional fields" do
      expect(advisory.withdrawn_at).to be_nil
      expect(advisory.blast_radius).to eq(15.5)
    end
  end

  describe "withdrawn status" do
    it "handles non-withdrawn advisory" do
      expect(advisory.withdrawn_at).to be_nil
    end

    it "handles withdrawn advisory" do
      withdrawn_advisory = advisory_repo.create(
        source_id: source_id,
        uuid: "WITHDRAWN-TEST",
        url: "https://example.com/withdrawn",
        title: "Withdrawn Advisory",
        description: "Withdrawn description",
        origin: "test",
        severity: "medium",
        published_at: Time.now,
        classification: "vulnerability",
        cvss_score: 5.0,
        withdrawn_at: Time.now,
        created_at: Time.now,
        updated_at: Time.now
      )
      expect(withdrawn_advisory.withdrawn_at).to be_a(Time)
    end
  end

  describe "array and JSON data" do
    it "can handle packages array data" do
      expect(advisory.packages).to be_a(Array)
      expect(advisory.packages.first["ecosystem"]).to eq("npm")
      expect(advisory.packages.first["package_name"]).to eq("test-package")
    end

    it "can handle references array data" do
      expect(advisory.references).to be_a(Array)
      expect(advisory.references).to include("https://example.com/ref")
    end

    it "can handle identifiers array data" do
      expect(advisory.identifiers).to be_a(Array)
      expect(advisory.identifiers).to include("CVE-2023-12345")
      expect(advisory.identifiers).to include("TEST-001")
    end
  end
end