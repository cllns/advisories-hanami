# frozen_string_literal: true

RSpec.describe AdvisoriesApp::Views::Helpers do
  let(:view_class) do
    Class.new do
      include AdvisoriesApp::Views::Helpers
    end
  end
  let(:view) { view_class.new }

  describe "#meta_title" do
    it "returns the default app name" do
      expect(view.meta_title).to eq("Ecosyste.ms: Advisories")
    end
  end

  describe "#meta_description" do
    it "returns the app description" do
      expect(view.meta_description).to eq("Essential vulnerability data for your ecosystem")
    end
  end

  describe "#app_name" do
    it "returns the app name" do
      expect(view.app_name).to eq("Advisories")
    end
  end

  describe "#app_description" do
    it "returns the app description" do
      expect(view.app_description).to eq("Essential vulnerability data for your ecosystem")
    end
  end

  describe "#severity_class" do
    it "returns correct class for low severity" do
      expect(view.severity_class("low")).to eq("bg-success")
      expect(view.severity_class("LOW")).to eq("bg-success")
    end

    it "returns correct class for moderate severity" do
      expect(view.severity_class("moderate")).to eq("text-bg-warning")
      expect(view.severity_class("MODERATE")).to eq("text-bg-warning")
    end

    it "returns correct class for high severity" do
      expect(view.severity_class("high")).to eq("bg-danger")
      expect(view.severity_class("HIGH")).to eq("bg-danger")
    end

    it "returns correct class for critical severity" do
      expect(view.severity_class("critical")).to eq("bg-dark")
      expect(view.severity_class("CRITICAL")).to eq("bg-dark")
    end

    it "returns default class for unknown severity" do
      expect(view.severity_class("unknown")).to eq("text-bg-info")
      expect(view.severity_class(nil)).to eq("text-bg-info")
      expect(view.severity_class("")).to eq("text-bg-info")
    end
  end

  describe "#github_repo_name" do
    it "returns the repo name" do
      expect(view.github_repo_name).to eq("advisories")
    end
  end

  describe "#time_ago_in_words" do
    let(:now) { Time.parse("2023-01-01 12:00:00") }

    before { allow(Time).to receive(:now).and_return(now) }

    it "returns 'less than a minute ago' for recent times" do
      time = now - 30
      expect(view.time_ago_in_words(time)).to eq("less than a minute ago")
    end

    it "returns minutes for times under an hour" do
      time = now - (5 * 60)
      expect(view.time_ago_in_words(time)).to eq("5 minutes ago")
    end

    it "returns hours for times under a day" do
      time = now - (3 * 3600)
      expect(view.time_ago_in_words(time)).to eq("3 hours ago")
    end

    it "returns days for times under a month" do
      time = now - (5 * 86400)
      expect(view.time_ago_in_words(time)).to eq("5 days ago")
    end

    it "returns months for times under a year" do
      time = now - (3 * 2592000)
      expect(view.time_ago_in_words(time)).to eq("3 months ago")
    end

    it "returns years for times over a year" do
      time = now - (2 * 31536000)
      expect(view.time_ago_in_words(time)).to eq("2 years ago")
    end

    it "returns empty string for nil" do
      expect(view.time_ago_in_words(nil)).to eq("")
    end
  end

  describe "#number_with_delimiter" do
    it "formats numbers with commas" do
      expect(view.number_with_delimiter(1234)).to eq("1,234")
      expect(view.number_with_delimiter(1234567)).to eq("1,234,567")
      expect(view.number_with_delimiter(123)).to eq("123")
    end
  end

  describe "#render_markdown" do
    it "renders bold text" do
      result = view.render_markdown("**bold text**")
      expect(result).to include("<strong>bold text</strong>")
    end

    it "renders italic text" do
      result = view.render_markdown("*italic text*")
      expect(result).to include("<em>italic text</em>")
    end

    it "converts newlines to br tags" do
      result = view.render_markdown("line 1\nline 2")
      expect(result).to include("line 1<br>line 2")
    end

    it "returns empty string for nil" do
      expect(view.render_markdown(nil)).to eq("")
    end
  end

  describe "#ecosystems_services" do
    let(:services) { view.ecosystems_services }

    it "returns a hash with service categories" do
      expect(services).to be_a(Hash)
      expect(services.keys).to include("Data", "Tools", "Indexes", "Applications")
    end

    it "includes advisories in Data category" do
      data_services = services["Data"]
      advisories_service = data_services.find { |service| service[:name] == "Advisories" }
      expect(advisories_service).not_to be_nil
      expect(advisories_service[:url]).to eq("https://advisories.ecosyste.ms")
    end

    it "includes all expected data services" do
      data_services = services["Data"]
      service_names = data_services.map { |service| service[:name] }
      expect(service_names).to include("Packages", "Repositories", "Advisories")
    end

    it "includes all expected tool services" do
      tool_services = services["Tools"]
      service_names = tool_services.map { |service| service[:name] }
      expect(service_names).to include("Dependency Parser", "Resolver", "SBOM Parser", "Diff")
    end
  end
end