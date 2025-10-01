# frozen_string_literal: true

RSpec.describe AdvisoriesApp::Actions::API::V1::Advisories::Lookup do
  let(:params) { { purl: "pkg:npm/express@4.16.0" } }

  it "works" do
    response = subject.call(params)
    expect(response).to be_successful
  end
end
