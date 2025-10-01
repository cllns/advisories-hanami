# frozen_string_literal: true

RSpec.describe AdvisoriesApp::Views::Advisories::Show do
  let(:advisory) do
    double(
      "Advisory",
      title: "SQL Injection in user_model gem",
      description: "A SQL injection vulnerability was found in user_model gem versions prior to 1.2.0"
    )
  end

  let(:view_class) do
    Class.new(AdvisoriesApp::Views::Advisories::Show) do
      attr_accessor :advisory
    end
  end

  let(:view) { view_class.new }

  before do
    view.advisory = advisory
  end

  describe "#meta_title" do
    it "returns advisory title with suffix" do
      expect(view.meta_title).to eq("SQL Injection in user_model gem | Security Advisories")
    end
  end

  describe "#meta_description" do
    it "returns advisory title and description" do
      expected = "SQL Injection in user_model gem. A SQL injection vulnerability was found in user_model gem versions prior to 1.2.0"
      expect(view.meta_description).to eq(expected)
    end
  end

  describe "exposed variables" do
    it "can access advisory" do
      expect(view.advisory).to eq(advisory)
    end
  end
end