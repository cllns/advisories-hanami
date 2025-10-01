# frozen_string_literal: true

RSpec.describe "Home page", type: :request do
  describe "GET /" do
    it "renders the home page successfully" do
      get "/"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Ecosyste.ms: Advisories")
      expect(last_response.body).to include("Essential vulnerability data")
      expect(last_response.body).to include("Advisories")
    end

    it "includes navigation elements" do
      get "/"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Advisories")
      expect(last_response.body).to include("header")
    end

    it "includes CSS and JavaScript assets" do
      get "/"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("stylesheet")
      expect(last_response.body).to include("chart.js")
    end
  end
end