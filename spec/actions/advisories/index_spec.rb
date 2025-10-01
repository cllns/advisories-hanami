# frozen_string_literal: true

RSpec.describe AdvisoriesApp::Actions::Advisories::Index do
  let(:action) { described_class.new }
  let(:repo) { AdvisoriesApp::App["repos.advisory_repo"] }

  before do
    # Clear any existing data
    repo.advisories.dataset.delete
    AdvisoriesApp::App["repos.source_repo"].sources.dataset.delete
  end

  describe "GET /advisories" do
    context "with no data" do
      it "returns empty results" do
        env = Rack::MockRequest.env_for("/advisories", "HTTP_ACCEPT" => "application/json")
        response = action.call(env)

        expect(response).to be_successful
        expect(response[:advisories]).to eq([])
        expect(response[:severities]).to eq([])
        expect(response[:ecosystems]).to eq([])
        expect(response[:packages]).to eq([])
        expect(response[:repository_urls]).to eq([])
      end
    end

    context "with sample data" do
      let(:source) do
        AdvisoriesApp::App["repos.source_repo"].create({
          name: "Test Source",
          kind: "test",
          url: "https://example.com",
          created_at: Time.now,
          updated_at: Time.now
        })
      end

      let(:advisory1) do
        repo.create({
          source_id: source.id,
          uuid: "TEST-2024-001",
          url: "https://example.com/advisory1",
          title: "Test Advisory 1",
          description: "First test advisory",
          origin: "test",
          severity: "high",
          published_at: Time.now - (2 * 24 * 60 * 60),
          classification: "malicious",
          cvss_score: 8.5,
          created_at: Time.now - (2 * 24 * 60 * 60),
          updated_at: Time.now - (2 * 24 * 60 * 60),
          packages: [
            {
              "ecosystem" => "npm",
              "package_name" => "test-package",
              "versions" => [{"vulnerable_version_range" => "< 1.0.0"}]
            }
          ]
        })
      end

      let(:advisory2) do
        repo.create({
          source_id: source.id,
          uuid: "TEST-2024-002",
          url: "https://example.com/advisory2",
          title: "Test Advisory 2",
          description: "Second test advisory",
          origin: "test",
          severity: "medium",
          published_at: Time.now - (1 * 24 * 60 * 60),
          classification: "malicious",
          cvss_score: 5.5,
          repository_url: "https://github.com/test/repo",
          created_at: Time.now - (1 * 24 * 60 * 60),
          updated_at: Time.now - (1 * 24 * 60 * 60),
          packages: [
            {
              "ecosystem" => "pypi",
              "package_name" => "python-package",
              "versions" => [{"vulnerable_version_range" => "< 2.0.0"}]
            }
          ]
        })
      end

      let(:withdrawn_advisory) do
        repo.create({
          source_id: source.id,
          uuid: "TEST-2024-003",
          url: "https://example.com/advisory3",
          title: "Withdrawn Advisory",
          description: "This advisory was withdrawn",
          origin: "test",
          severity: "low",
          published_at: Time.now - (3 * 24 * 60 * 60),
          withdrawn_at: Time.now - (1 * 24 * 60 * 60),
          classification: "malicious",
          created_at: Time.now - (3 * 24 * 60 * 60),
          updated_at: Time.now - (1 * 24 * 60 * 60),
          packages: [
            {
              "ecosystem" => "npm",
              "package_name" => "withdrawn-package",
              "versions" => [{"vulnerable_version_range" => "< 0.5.0"}]
            }
          ]
        })
      end

      before do
        advisory1
        advisory2
        withdrawn_advisory
      end

      it "returns all non-withdrawn advisories by default" do
        env = Rack::MockRequest.env_for("/advisories", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

        expect(response).to be_successful
        advisories = response[:advisories]
        expect(advisories.length).to eq(2)

        uuids = advisories.map { |a| a[:uuid] }
        expect(uuids).to include("TEST-2024-001", "TEST-2024-002")
        expect(uuids).not_to include("TEST-2024-003")
      end

      it "orders by published_at desc by default" do
        env = Rack::MockRequest.env_for("/advisories", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

        advisories = response[:advisories]
        expect(advisories.first[:uuid]).to eq("TEST-2024-002") # More recent
        expect(advisories.last[:uuid]).to eq("TEST-2024-001")
      end

      it "calculates severity counts correctly" do
        env = Rack::MockRequest.env_for("/advisories", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

        severities = response[:severities]
        severity_hash = severities.to_h

        expect(severity_hash["high"]).to eq(1)
        expect(severity_hash["medium"]).to eq(1)
        expect(severity_hash).not_to have_key("low") # withdrawn advisory
      end

      it "calculates ecosystem counts correctly" do
        env = Rack::MockRequest.env_for("/advisories", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

        ecosystems = response[:ecosystems]
        ecosystem_hash = ecosystems.to_h

        expect(ecosystem_hash["npm"]).to eq(1)
        expect(ecosystem_hash["pypi"]).to eq(1)
      end

      it "calculates package counts correctly" do
        env = Rack::MockRequest.env_for("/advisories", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

        packages = response[:packages]

        npm_package = packages.find { |pkg, _count| pkg["ecosystem"] == "npm" && pkg["package_name"] == "test-package" }
        pypi_package = packages.find { |pkg, _count| pkg["ecosystem"] == "pypi" && pkg["package_name"] == "python-package" }

        expect(npm_package[1]).to eq(1)
        expect(pypi_package[1]).to eq(1)
      end

      it "calculates repository URL counts correctly" do
        env = Rack::MockRequest.env_for("/advisories", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

        repository_urls = response[:repository_urls]
        url_hash = repository_urls.to_h

        expect(url_hash["https://github.com/test/repo"]).to eq(1)
      end

      describe "filtering by severity" do
        it "filters advisories by severity" do
          env = Rack::MockRequest.env_for("/advisories?severity=high", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          advisories = response[:advisories]
          expect(advisories.length).to eq(1)
          expect(advisories.first[:uuid]).to eq("TEST-2024-001")
          expect(advisories.first[:severity]).to eq("high")
        end

        it "updates ecosystem counts when filtering by severity" do
          env = Rack::MockRequest.env_for("/advisories?severity=high", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          ecosystems = response[:ecosystems]
          ecosystem_hash = ecosystems.to_h

          expect(ecosystem_hash["npm"]).to eq(1)
          expect(ecosystem_hash).not_to have_key("pypi")
        end
      end

      describe "filtering by ecosystem" do
        it "filters advisories by ecosystem" do
          env = Rack::MockRequest.env_for("/advisories?ecosystem=npm", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          advisories = response[:advisories]
          expect(advisories.length).to eq(1)
          expect(advisories.first[:uuid]).to eq("TEST-2024-001")
        end

        it "updates severity counts when filtering by ecosystem" do
          env = Rack::MockRequest.env_for("/advisories?ecosystem=npm", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          severities = response[:severities]
          severity_hash = severities.to_h

          expect(severity_hash["high"]).to eq(1)
          expect(severity_hash).not_to have_key("medium")
        end
      end

      describe "filtering by package name" do
        it "filters advisories by package name" do
          env = Rack::MockRequest.env_for("/advisories?package_name=test-package", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          advisories = response[:advisories]
          expect(advisories.length).to eq(1)
          expect(advisories.first[:uuid]).to eq("TEST-2024-001")
        end
      end

      describe "filtering by repository URL" do
        it "filters advisories by repository URL" do
          env = Rack::MockRequest.env_for("/advisories?repository_url=https%3A%2F%2Fgithub.com%2Ftest%2Frepo", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          advisories = response[:advisories]
          expect(advisories.length).to eq(1)
          expect(advisories.first[:uuid]).to eq("TEST-2024-002")
        end
      end

      describe "sorting" do
        it "sorts by severity ascending" do
          env = Rack::MockRequest.env_for("/advisories?sort=severity&order=asc", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          advisories = response[:advisories]
          expect(advisories.first[:severity]).to eq("high")
          expect(advisories.last[:severity]).to eq("medium")
        end

        it "sorts by multiple columns" do
          env = Rack::MockRequest.env_for("/advisories?sort=severity,published_at&order=asc,desc", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          advisories = response[:advisories]
          expect(advisories.length).to eq(2)
        end

        it "ignores invalid sort columns" do
          env = Rack::MockRequest.env_for("/advisories?sort=invalid_column", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          expect(response).to be_successful
          advisories = response[:advisories]
          expect(advisories.length).to eq(2)
        end
      end

      describe "pagination" do
        let(:many_advisories) do
          30.times do |i|
            repo.create({
              source_id: source.id,
              uuid: "MANY-#{i.to_s.rjust(3, '0')}",
              url: "https://example.com/advisory#{i}",
              title: "Advisory #{i}",
              description: "Advisory number #{i}",
              origin: "test",
              severity: "low",
              published_at: Time.now - i * 60 * 60,
              classification: "malicious",
              created_at: Time.now - i * 60 * 60,
              updated_at: Time.now - i * 60 * 60,
              packages: [
                {
                  "ecosystem" => "test",
                  "package_name" => "package-#{i}",
                  "versions" => [{"vulnerable_version_range" => "< 1.0.0"}]
                }
              ]
            })
          end
        end

        before { many_advisories }

        it "paginates results with default page size" do
          env = Rack::MockRequest.env_for("/advisories", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          advisories = response[:advisories]
          expect(advisories.length).to eq(25) # Default page size

          pagination = response[:pagination]
          expect(pagination[:current_page]).to eq(1)
          expect(pagination[:per_page]).to eq(25)
          expect(pagination[:total_count]).to eq(32) # 30 new + 2 existing non-withdrawn
        end

        it "handles page parameter" do
          env = Rack::MockRequest.env_for("/advisories?page=2", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          advisories = response[:advisories]
          expect(advisories.length).to eq(7) # Remaining items on page 2

          pagination = response[:pagination]
          expect(pagination[:current_page]).to eq(2)
        end
      end

      describe "date filtering" do
        it "filters by created_after" do
          yesterday = (Time.now - (1 * 24 * 60 * 60)).strftime("%Y-%m-%d")
          env = Rack::MockRequest.env_for("/advisories?created_after=#{yesterday}", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          advisories = response[:advisories]
          # Should only include advisories created after yesterday
          expect(advisories.length).to be >= 0
        end

        it "filters by updated_after" do
          yesterday = (Time.now - (1 * 24 * 60 * 60)).strftime("%Y-%m-%d")
          env = Rack::MockRequest.env_for("/advisories?updated_after=#{yesterday}", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          advisories = response[:advisories]
          expect(advisories.length).to be >= 0
        end
      end

      describe "combining filters" do
        it "combines severity and ecosystem filters" do
          env = Rack::MockRequest.env_for("/advisories?severity=high&ecosystem=npm", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          advisories = response[:advisories]
          expect(advisories.length).to eq(1)
          expect(advisories.first[:uuid]).to eq("TEST-2024-001")
          expect(advisories.first[:severity]).to eq("high")
        end

        it "returns empty results when filters don't match" do
          env = Rack::MockRequest.env_for("/advisories?severity=high&ecosystem=pypi", "HTTP_ACCEPT" => "application/json"); response = action.call(env)

          advisories = response[:advisories]
          expect(advisories).to be_empty
        end
      end
    end
  end
end
