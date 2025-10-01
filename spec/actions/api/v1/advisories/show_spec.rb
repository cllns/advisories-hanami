# frozen_string_literal: true

RSpec.describe AdvisoriesApp::Actions::API::V1::Advisories::Show, db: true do
  let(:sources_relation) { Hanami.app["relations.sources"] }
  let(:advisory_repo) { Hanami.app["repos.advisory_repo"] }

  let!(:source_id) do
    sources_relation.insert(
      name: "Test Source",
      kind: "test",
      url: "https://test.com",
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let!(:advisory) do
    advisory_repo.create(
      source_id: source_id,
      uuid: "TEST-SHOW-001",
      url: "https://test.com/advisory",
      title: "Test Advisory",
      description: "Test description",
      origin: "test",
      severity: "high",
      published_at: Time.now,
      classification: "malicious",
      cvss_score: 8.5,
      created_at: Time.now,
      updated_at: Time.now
    )
  end

  let(:params) { { id: "TEST-SHOW-001" } }

  it "works" do
    response = subject.call(params)
    expect(response).to be_successful
  end
end
