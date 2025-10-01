# frozen_string_literal: true

RSpec.describe "End-to-end user workflows", type: :request do
  describe "User browsing advisories workflow" do
    it "can navigate from home page to advisories index" do
      # Start at home page
      get "/"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Advisories")

      # Navigate to advisories index
      get "/advisories"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Advisories")
      expect(last_response.body).to include("Filter")
    end

    it "can apply filters on advisories index page" do
      # Visit advisories page
      get "/advisories"
      expect(last_response.status).to eq(200)

      # Apply severity filter
      get "/advisories?severity=high"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Advisories")

      # Apply ecosystem filter
      get "/advisories?ecosystem=rubygems"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Advisories")

      # Apply multiple filters
      get "/advisories?severity=high&ecosystem=rubygems"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Advisories")
    end

    it "handles invalid advisory lookup gracefully" do
      # Try to access non-existent advisory
      get "/advisories/invalid-uuid-123"
      expect(last_response.status).to eq(404)
    end
  end

  describe "Navigation and layout consistency" do
    let(:pages) { ["/", "/advisories"] }

    it "includes consistent header navigation across all pages" do
      pages.each do |page|
        get page
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("ecosyste.ms")
        expect(last_response.body).to include("Advisories")
      end
    end

    it "includes consistent footer across all pages" do
      pages.each do |page|
        get page
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("footer")
        expect(last_response.body).to include("Github")
      end
    end

    it "includes meta tags for SEO across all pages" do
      pages.each do |page|
        get page
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('<meta name="description"')
        expect(last_response.body).to include('<title>')
      end
    end
  end

  describe "Asset loading and performance" do
    it "serves CSS assets successfully" do
      get "/"
      expect(last_response.status).to eq(200)

      # Extract CSS file path from HTML
      css_match = last_response.body.match(/href="([^"]+\.css)"/)
      expect(css_match).not_to be_nil

      css_path = css_match[1]
      get css_path
      expect(last_response.status).to eq(200)
      expect(last_response.headers["Content-Type"]).to include("text/css")
    end

    it "serves JavaScript assets successfully" do
      get "/"
      expect(last_response.status).to eq(200)

      # Extract JS file path from HTML (only check app.js, not chart.js)
      js_match = last_response.body.match(/src="([^"]+app[^"]*\.js)"/)
      expect(js_match).not_to be_nil

      js_path = js_match[1]
      get js_path
      expect(last_response.status).to eq(200)
      expect(last_response.headers["Content-Type"]).to include("javascript")
    end

    it "serves favicon successfully" do
      get "/"
      expect(last_response.status).to eq(200)

      # Extract favicon path from HTML
      favicon_match = last_response.body.match(/href="([^"]+\.ico)"/)
      expect(favicon_match).not_to be_nil

      favicon_path = favicon_match[1]
      get favicon_path
      expect(last_response.status).to eq(200)
      expect(last_response.headers["Content-Type"]).to include("image")
    end
  end

  describe "Error handling workflows" do
    it "provides user-friendly 404 error pages" do
      get "/advisories/nonexistent-advisory"
      expect(last_response.status).to eq(404)
    end

    it "handles invalid filter parameters gracefully" do
      get "/advisories?severity=invalid&ecosystem=&package_name="
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Advisories")
    end
  end

  describe "Responsive design and accessibility" do
    it "includes viewport meta tag for mobile responsiveness" do
      ["/", "/advisories"].each do |page|
        get page
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('<meta name="viewport"')
      end
    end

    it "includes Bootstrap CSS classes for responsive design" do
      ["/", "/advisories"].each do |page|
        get page
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("container")
        expect(last_response.body).to include("row")
        expect(last_response.body).to include("col")
      end
    end
  end
end