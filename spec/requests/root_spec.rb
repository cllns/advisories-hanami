# frozen_string_literal: true

RSpec.describe "Root", type: :request do
  it "returns the home page" do
    get "/"

    expect(last_response.status).to be(200)
  end
end
