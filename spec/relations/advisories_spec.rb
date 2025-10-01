# frozen_string_literal: true

RSpec.describe AdvisoriesApp::Relations::Advisories, type: :relation, db: true do
  let(:relation) { Hanami.app["relations.advisories"] }
  let(:sources_relation) { Hanami.app["relations.sources"] }
  let(:repo) { Hanami.app["repos.advisory_repo"] }

  before do
    # Clear any existing data
    relation.dataset.delete
    sources_relation.dataset.delete

    # Create a test source
    @source = sources_relation.insert(
      name: "Test Source",
      kind: "test",
      url: "https://test.example.com",
      created_at: Time.now,
      updated_at: Time.now
    )

    # Create test advisories
    @advisory1 = repo.create(
      source_id: @source,
      uuid: "TEST-2023-001",
      url: "https://test.example.com/advisory1",
      title: "Test Advisory 1",
      description: "Test description 1",
      origin: "test",
      severity: "high",
      published_at: Time.now - 3600,
      classification: "malicious",
      cvss_score: 8.5,
      packages: [{"ecosystem" => "npm", "package_name" => "test-package", "versions" => [{"vulnerable_version_range" => "< 1.0.0"}]}],
      created_at: Time.now,
      updated_at: Time.now
    )

    @advisory2 = repo.create(
      source_id: @source,
      uuid: "TEST-2023-002",
      url: "https://test.example.com/advisory2",
      title: "Test Advisory 2",
      description: "Test description 2",
      origin: "test",
      severity: "medium",
      published_at: Time.now - 7200,
      classification: "vulnerability",
      cvss_score: 5.0,
      packages: [{"ecosystem" => "rubygems", "package_name" => "another-package", "versions" => [{"vulnerable_version_range" => "< 2.0.0"}]}],
      withdrawn_at: Time.now,
      created_at: Time.now,
      updated_at: Time.now
    )

    @advisory3 = repo.create(
      source_id: @source,
      uuid: "TEST-2023-003",
      url: "https://test.example.com/advisory3",
      title: "Test Advisory 3",
      description: "Test description 3",
      origin: "test",
      severity: "low",
      published_at: Time.now - 10800,
      classification: "vulnerability",
      cvss_score: 3.0,
      packages: [{"ecosystem" => "npm", "package_name" => "test-PACKAGE", "versions" => [{"vulnerable_version_range" => "< 3.0.0"}]}],
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  describe "#by_ecosystem" do
    it "filters advisories by ecosystem" do
      npm_advisories = relation.by_ecosystem("npm").to_a
      expect(npm_advisories.size).to eq(2)
      expect(npm_advisories.map { |a| a[:uuid] }).to include("TEST-2023-001", "TEST-2023-003")
    end

    it "filters advisories by ecosystem case insensitively" do
      npm_advisories = relation.by_ecosystem("NPM").to_a
      expect(npm_advisories.size).to eq(2)
    end
  end

  describe "#by_package_name" do
    it "filters advisories by package name (case insensitive)" do
      results = relation.by_package_name("test-package").to_a
      expect(results.size).to eq(2)
      expect(results.map { |a| a[:uuid] }).to include("TEST-2023-001", "TEST-2023-003")
    end

    it "filters advisories by case insensitive package name" do
      results = relation.by_package_name("TEST-PACKAGE").to_a
      expect(results.size).to eq(2)
      expect(results.map { |a| a[:uuid] }).to include("TEST-2023-001", "TEST-2023-003")
    end
  end

  describe "#by_severity" do
    it "filters advisories by severity" do
      high_advisories = relation.by_severity("high").to_a
      expect(high_advisories.size).to eq(1)
      expect(high_advisories.first[:uuid]).to eq("TEST-2023-001")
    end
  end

  describe "#created_after" do
    it "filters advisories created after a given time" do
      recent_time = Time.now - 1800 # 30 minutes ago
      recent_advisories = relation.created_after(recent_time).to_a
      expect(recent_advisories.size).to eq(3) # All were created recently
    end
  end

  describe "#withdrawn" do
    it "returns only withdrawn advisories" do
      withdrawn_advisories = relation.withdrawn.to_a
      expect(withdrawn_advisories.size).to eq(1)
      expect(withdrawn_advisories.first[:uuid]).to eq("TEST-2023-002")
    end
  end

  describe "#not_withdrawn" do
    it "returns only non-withdrawn advisories" do
      active_advisories = relation.not_withdrawn.to_a
      expect(active_advisories.size).to eq(2)
      expect(active_advisories.map { |a| a[:uuid] }).to include("TEST-2023-001", "TEST-2023-003")
    end
  end

  describe "#ecosystem_counts" do
    it "returns ecosystem counts" do
      counts = relation.ecosystem_counts
      expect(counts).to be_a(Array)
      expect(counts.find { |ecosystem, count| ecosystem == "npm" }[1]).to eq(2)
      expect(counts.find { |ecosystem, count| ecosystem == "rubygems" }[1]).to eq(1)
    end
  end

  describe "#package_counts" do
    it "returns package counts" do
      counts = relation.package_counts
      expect(counts).to be_a(Array)
      expect(counts.size).to eq(3) # 3 unique packages
    end
  end

  describe "chaining scopes" do
    it "can chain multiple scopes" do
      results = relation.by_ecosystem("npm").not_withdrawn.to_a
      expect(results.size).to eq(2)
      expect(results.map { |a| a[:uuid] }).to include("TEST-2023-001", "TEST-2023-003")
    end
  end
end