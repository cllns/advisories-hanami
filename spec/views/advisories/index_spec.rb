# frozen_string_literal: true

RSpec.describe AdvisoriesApp::Views::Advisories::Index do
  let(:advisories) do
    [
      AdvisoriesApp::Structs::Advisory.new(
        id: 1,
        source_id: 1,
        uuid: "abc-123",
        title: "SQL Injection in user_model gem",
        description: "A SQL injection vulnerability",
        severity: "high",
        published_at: Time.parse("2023-01-01 10:00:00"),
        created_at: Time.parse("2023-01-01 10:00:00"),
        updated_at: Time.parse("2023-01-01 10:00:00"),
        packages: [{"ecosystem" => "rubygems", "name" => "user_model"}]
      ),
      AdvisoriesApp::Structs::Advisory.new(
        id: 2,
        source_id: 1,
        uuid: "def-456",
        title: "XSS in web_helpers",
        description: "Cross-site scripting vulnerability",
        severity: "medium",
        published_at: Time.parse("2023-01-02 10:00:00"),
        created_at: Time.parse("2023-01-02 10:00:00"),
        updated_at: Time.parse("2023-01-02 10:00:00"),
        packages: [{"ecosystem" => "npm", "name" => "web_helpers"}]
      )
    ]
  end

  let(:severities) { ["low", "medium", "high", "critical"] }
  let(:ecosystems) { ["rubygems", "npm", "pypi"] }
  let(:packages) { ["user_model", "web_helpers", "django"] }

  let(:view_class) do
    Class.new(AdvisoriesApp::Views::Advisories::Index) do
      include AdvisoriesApp::Views::Helpers
      attr_accessor :advisories, :severities, :ecosystems, :packages, :severity, :ecosystem, :package_name
    end
  end

  let(:view) { view_class.new }

  before do
    view.advisories = advisories
    view.severities = severities
    view.ecosystems = ecosystems
    view.packages = packages
    view.severity = nil
    view.ecosystem = nil
    view.package_name = nil
  end

  describe "#meta_title" do
    it "returns default title when no filters" do
      expect(view.meta_title).to eq("Ecosyste.ms: Advisories")
    end
  end

  describe "#meta_description" do
    it "returns default description when no filters" do
      expect(view.meta_description).to eq("Essential vulnerability data for your ecosystem")
    end
  end

  describe "exposed variables" do
    it "can access advisories" do
      expect(view.advisories).to eq(advisories)
    end

    it "can access filter options" do
      expect(view.severities).to eq(severities)
      expect(view.ecosystems).to eq(ecosystems)
      expect(view.packages).to eq(packages)
    end

    it "can access current filter values" do
      expect(view.severity).to be_nil
      expect(view.ecosystem).to be_nil
      expect(view.package_name).to be_nil
    end
  end
end