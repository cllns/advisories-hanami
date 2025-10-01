# frozen_string_literal: true

RSpec.describe "Advisories HTML pages", type: :request do
  describe "GET /advisories" do
    context "when no advisories exist" do
      it "renders the index page successfully" do
        get "/advisories"

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Advisories")
        expect(last_response.body).to include("Essential vulnerability data")
      end
    end

    context "with filter parameters" do
      it "handles severity filter" do
        get "/advisories?severity=high"

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Advisories")
      end

      it "handles ecosystem filter" do
        get "/advisories?ecosystem=rubygems"

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Advisories")
      end

      it "handles package filter" do
        get "/advisories?package_name=rails"

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Advisories")
      end
    end
  end

  describe "GET /advisories/:uuid" do
    context "when advisory does not exist" do
      it "returns 404" do
        get "/advisories/nonexistent-uuid"

        expect(last_response.status).to eq(404)
      end
    end
  end
end