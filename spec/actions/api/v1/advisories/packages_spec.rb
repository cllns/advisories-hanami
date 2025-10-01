# frozen_string_literal: true

RSpec.describe AdvisoriesApp::Actions::API::V1::Advisories::Packages do
  let(:params) { Hash[] }

  it "works" do
    response = subject.call(params)
    expect(response).to be_successful
  end
end
