# frozen_string_literal: true

RSpec.describe AdvisoriesApp::Repos::AdvisoryRepo, type: :repo, db: true do
  let(:repo) { Hanami.app["repos.advisory_repo"] }
  let(:sources_relation) { Hanami.app["relations.sources"] }

  before do
    # Clear any existing data
    repo.advisories.dataset.delete
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
    @advisory_attrs1 = {
      source_id: @source,
      uuid: "REPO-TEST-001",
      url: "https://test.example.com/advisory1",
      title: "Repo Test Advisory 1",
      description: "Repo test description 1",
      origin: "test",
      severity: "high",
      published_at: Time.now - 3600,
      classification: "malicious",
      cvss_score: 8.5,
      packages: [{"ecosystem" => "npm", "package_name" => "repo-test-package", "versions" => [{"vulnerable_version_range" => "< 1.0.0"}]}],
      created_at: Time.now,
      updated_at: Time.now
    }

    @advisory_attrs2 = {
      source_id: @source,
      uuid: "REPO-TEST-002",
      url: "https://test.example.com/advisory2",
      title: "Repo Test Advisory 2",
      description: "Repo test description 2",
      origin: "test",
      severity: "medium",
      published_at: Time.now - 7200,
      classification: "vulnerability",
      cvss_score: 5.0,
      packages: [{"ecosystem" => "rubygems", "package_name" => "repo-another-package", "versions" => [{"vulnerable_version_range" => "< 2.0.0"}]}],
      withdrawn_at: Time.now,
      created_at: Time.now,
      updated_at: Time.now
    }

    @advisory1 = repo.create(@advisory_attrs1)
    @advisory2 = repo.create(@advisory_attrs2)
  end

  describe "#create" do
    it "creates a new advisory" do
      new_attrs = {
        source_id: @source,
        uuid: "REPO-NEW-001",
        url: "https://test.example.com/new",
        title: "New Advisory",
        description: "New description",
        origin: "test",
        severity: "critical",
        published_at: Time.now,
        classification: "malicious",
        cvss_score: 9.0,
        packages: [{"ecosystem" => "pypi", "package_name" => "new-package", "versions" => [{"vulnerable_version_range" => "< 1.0.0"}]}],
        created_at: Time.now,
        updated_at: Time.now
      }

      advisory = repo.create(new_attrs)
      expect(advisory.uuid).to eq("REPO-NEW-001")
      expect(advisory.severity).to eq("critical")
    end
  end

  describe "#by_uuid" do
    it "finds advisory by uuid" do
      advisory = repo.by_uuid("REPO-TEST-001")
      expect(advisory).not_to be_nil
      expect(advisory.title).to eq("Repo Test Advisory 1")
    end

    it "returns nil for non-existent uuid" do
      advisory = repo.by_uuid("NON-EXISTENT")
      expect(advisory).to be_nil
    end
  end

  describe "scope methods" do
    it "#by_ecosystem returns filtered results" do
      results = repo.by_ecosystem("npm").to_a
      expect(results.size).to eq(1)
      expect(results.first.uuid).to eq("REPO-TEST-001")
    end

    it "#by_severity returns filtered results" do
      results = repo.by_severity("high").to_a
      expect(results.size).to eq(1)
      expect(results.first.uuid).to eq("REPO-TEST-001")
    end

    it "#withdrawn returns only withdrawn advisories" do
      results = repo.withdrawn.to_a
      expect(results.size).to eq(1)
      expect(results.first.uuid).to eq("REPO-TEST-002")
    end

    it "#not_withdrawn returns only non-withdrawn advisories" do
      results = repo.not_withdrawn.to_a
      expect(results.size).to eq(1)
      expect(results.first.uuid).to eq("REPO-TEST-001")
    end
  end

  describe "aggregate methods" do
    it "#ecosystems returns list of ecosystems" do
      ecosystems = repo.ecosystems
      expect(ecosystems).to include("npm", "rubygems")
    end

    it "#ecosystem_counts returns ecosystem counts" do
      counts = repo.ecosystem_counts
      expect(counts).to be_a(Array)
      npm_count = counts.find { |ecosystem, count| ecosystem == "npm" }
      expect(npm_count[1]).to eq(1)
    end

    it "#package_counts returns package counts" do
      counts = repo.package_counts
      expect(counts).to be_a(Array)
      expect(counts.size).to eq(2) # 2 unique packages
    end

    it "#packages returns unique packages without versions" do
      packages = repo.packages
      expect(packages).to be_a(Array)
      expect(packages.size).to eq(2)

      npm_package = packages.find { |p| p["ecosystem"] == "npm" }
      expect(npm_package["package_name"]).to eq("repo-test-package")
      expect(npm_package).not_to have_key("versions")
    end
  end

  describe "#update_blast_radius" do
    it "updates the blast radius for an advisory" do
      original_blast_radius = @advisory1.blast_radius
      repo.update_blast_radius(@advisory1.id)

      updated_advisory = repo.by_uuid("REPO-TEST-001")
      expect(updated_advisory.blast_radius).not_to eq(original_blast_radius)
      expect(updated_advisory.blast_radius).to be > 0
    end
  end

  describe "update and delete operations" do
    it "updates an advisory" do
      updated_advisory = repo.update(@advisory1.id, severity: "critical", title: "Updated Title")
      expect(updated_advisory.severity).to eq("critical")
      expect(updated_advisory.title).to eq("Updated Title")
    end

    it "deletes an advisory" do
      repo.delete(@advisory1.id)
      deleted_advisory = repo.by_uuid("REPO-TEST-001")
      expect(deleted_advisory).to be_nil
    end
  end
end