# frozen_string_literal: true

RSpec.describe "Shared partials rendering", type: :request do
  describe "Header partial" do
    let(:pages_with_header) { ["/", "/advisories"] }

    it "renders the header with ecosyste.ms logo" do
      pages_with_header.each do |page|
        get page
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("ecosyste.ms")
        expect(last_response.body).to include("site-logo")
      end
    end

    it "includes the global navigation menu" do
      pages_with_header.each do |page|
        get page
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("All services")
        expect(last_response.body).to include("header__global__menu")
      end
    end

    it "includes service categories in the menu" do
      pages_with_header.each do |page|
        get page
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Data")
        expect(last_response.body).to include("Tools")
        expect(last_response.body).to include("Indexes")
        expect(last_response.body).to include("Applications")
      end
    end

    it "includes links to other ecosyste.ms services" do
      pages_with_header.each do |page|
        get page
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("packages.ecosyste.ms")
        expect(last_response.body).to include("repos.ecosyste.ms")
        expect(last_response.body).to include("advisories.ecosyste.ms")
      end
    end
  end

  describe "Footer partial" do
    let(:pages_with_footer) { ["/", "/advisories"] }

    it "renders the footer with branding" do
      pages_with_footer.each do |page|
        get page
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("<footer")
        expect(last_response.body).to include("ecosyste.ms")
      end
    end

    it "includes social media links" do
      pages_with_footer.each do |page|
        get page
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("github.com/ecosyste-ms")
        expect(last_response.body).to include("mastodon.social/@ecosystems")
        expect(last_response.body).to include("opencollective.com/ecosystems")
      end
    end

    it "includes sponsor information" do
      pages_with_footer.each do |page|
        get page
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Supported by")
        expect(last_response.body).to include("Schmidt Futures")
        expect(last_response.body).to include("Open Source Collective")
      end
    end

    it "includes navigation links" do
      pages_with_footer.each do |page|
        get page
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("About")
        expect(last_response.body).to include("Blog")
        expect(last_response.body).to include("Privacy")
        expect(last_response.body).to include("Terms")
      end
    end
  end

  describe "Menu partial" do
    it "renders the ecosystems services menu with correct structure" do
      get "/"
      expect(last_response.status).to eq(200)

      # Check for Data category services
      expect(last_response.body).to include("Packages")
      expect(last_response.body).to include("Repositories")
      expect(last_response.body).to include("Advisories")

      # Check for Tools category services
      expect(last_response.body).to include("Dependency Parser")
      expect(last_response.body).to include("Resolver")
      expect(last_response.body).to include("SBOM Parser")
      expect(last_response.body).to include("Diff")

      # Check for Indexes category services
      expect(last_response.body).to include("Timeline")
      expect(last_response.body).to include("Commits")

      # Check for Applications category services
      expect(last_response.body).to include("Funds")
    end

    it "includes proper Bootstrap collapse functionality" do
      get "/"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('data-bs-toggle="collapse"')
      expect(last_response.body).to include('aria-expanded="false"')
      expect(last_response.body).to include('id="header__global__menu"')
    end
  end

  describe "Cross-page consistency" do
    it "maintains consistent header structure across all pages" do
      header_elements = ["header__global", "site-logo", "header__global__menu"]

      ["/", "/advisories"].each do |page|
        get page
        expect(last_response.status).to eq(200)

        header_elements.each do |element|
          expect(last_response.body).to include(element)
        end
      end
    end

    it "maintains consistent footer structure across all pages" do
      footer_elements = ["footer", "footer-links", "footer-icons"]

      ["/", "/advisories"].each do |page|
        get page
        expect(last_response.status).to eq(200)

        footer_elements.each do |element|
          expect(last_response.body).to include(element)
        end
      end
    end
  end
end