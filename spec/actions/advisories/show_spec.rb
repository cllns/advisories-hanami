# frozen_string_literal: true

RSpec.describe AdvisoriesApp::Actions::Advisories::Show do
  let(:params) { { id: "nonexistent-uuid" } }

  it "returns 404 for nonexistent advisory" do
    response = subject.call(params)
    expect(response.status).to eq(404)
    expect(response.body).to eq(["[\"Advisory not found\"]"])
  end
end
