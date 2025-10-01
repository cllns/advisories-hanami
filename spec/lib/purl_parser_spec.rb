# frozen_string_literal: true

require_relative '../../lib/purl_parser'

RSpec.describe PurlParser do
  describe ".parse" do
    it "parses valid npm PURL" do
      result = PurlParser.parse("pkg:npm/express@4.17.1")

      expect(result).to eq({
        ecosystem: "npm",
        package_name: "express",
        namespace: nil,
        version: "4.17.1",
        original_purl: "pkg:npm/express@4.17.1"
      })
    end

    it "parses npm PURL with namespace" do
      result = PurlParser.parse("pkg:npm/@types/node@16.0.0")

      expect(result).to eq({
        ecosystem: "npm",
        package_name: "node",
        namespace: "@types",
        version: "16.0.0",
        original_purl: "pkg:npm/@types/node@16.0.0"
      })
    end

    it "parses PURL without version" do
      result = PurlParser.parse("pkg:npm/express")

      expect(result).to eq({
        ecosystem: "npm",
        package_name: "express",
        namespace: nil,
        version: nil,
        original_purl: "pkg:npm/express"
      })
    end

    it "parses rubygems PURL (gem type)" do
      result = PurlParser.parse("pkg:gem/rails@6.1.4")

      expect(result).to eq({
        ecosystem: "rubygems",
        package_name: "rails",
        namespace: nil,
        version: "6.1.4",
        original_purl: "pkg:gem/rails@6.1.4"
      })
    end

    it "parses pypi PURL" do
      result = PurlParser.parse("pkg:pypi/django@3.2.0")

      expect(result).to eq({
        ecosystem: "pypi",
        package_name: "django",
        namespace: nil,
        version: "3.2.0",
        original_purl: "pkg:pypi/django@3.2.0"
      })
    end

    it "parses maven PURL" do
      result = PurlParser.parse("pkg:maven/com.example/my-package@1.0.0")

      expect(result).to eq({
        ecosystem: "maven",
        package_name: "my-package",
        namespace: "com.example",
        version: "1.0.0",
        original_purl: "pkg:maven/com.example/my-package@1.0.0"
      })
    end

    it "parses nuget PURL" do
      result = PurlParser.parse("pkg:nuget/Newtonsoft.Json@13.0.1")

      expect(result).to eq({
        ecosystem: "nuget",
        package_name: "Newtonsoft.Json",
        namespace: nil,
        version: "13.0.1",
        original_purl: "pkg:nuget/Newtonsoft.Json@13.0.1"
      })
    end

    it "parses golang PURL" do
      result = PurlParser.parse("pkg:golang/github.com/gin-gonic/gin@1.7.0")

      expect(result).to eq({
        ecosystem: "go",
        package_name: "gin",
        namespace: "github.com/gin-gonic",
        version: "1.7.0",
        original_purl: "pkg:golang/github.com/gin-gonic/gin@1.7.0"
      })
    end

    it "parses go PURL" do
      result = PurlParser.parse("pkg:go/github.com/gorilla/mux@1.8.0")

      expect(result).to eq({
        ecosystem: "go",
        package_name: "mux",
        namespace: "github.com/gorilla",
        version: "1.8.0",
        original_purl: "pkg:go/github.com/gorilla/mux@1.8.0"
      })
    end

    it "parses cargo PURL" do
      result = PurlParser.parse("pkg:cargo/serde@1.0.0")

      expect(result).to eq({
        ecosystem: "cargo",
        package_name: "serde",
        namespace: nil,
        version: "1.0.0",
        original_purl: "pkg:cargo/serde@1.0.0"
      })
    end

    it "returns nil for invalid PURL format" do
      result = PurlParser.parse("invalid-purl")
      expect(result).to be_nil
    end

    it "returns nil for empty string" do
      result = PurlParser.parse("")
      expect(result).to be_nil
    end

    it "returns nil for nil input" do
      result = PurlParser.parse(nil)
      expect(result).to be_nil
    end

    it "returns nil for unsupported ecosystem" do
      result = PurlParser.parse("pkg:unsupported/package@1.0.0")
      expect(result).to be_nil
    end

    it "handles case insensitive ecosystem mapping" do
      result = PurlParser.parse("pkg:NPM/express@4.17.1")

      expect(result).to eq({
        ecosystem: "npm",
        package_name: "express",
        namespace: nil,
        version: "4.17.1",
        original_purl: "pkg:NPM/express@4.17.1"
      })
    end

    it "handles PURL with qualifiers (ignores them)" do
      result = PurlParser.parse("pkg:npm/express@4.17.1?arch=x64&os=linux")

      expect(result).to eq({
        ecosystem: "npm",
        package_name: "express",
        namespace: nil,
        version: "4.17.1",
        original_purl: "pkg:npm/express@4.17.1?arch=x64&os=linux"
      })
    end

    it "handles PURL with subpath (ignores it)" do
      result = PurlParser.parse("pkg:npm/express@4.17.1#lib/router.js")

      expect(result).to eq({
        ecosystem: "npm",
        package_name: "express",
        namespace: nil,
        version: "4.17.1",
        original_purl: "pkg:npm/express@4.17.1#lib/router.js"
      })
    end
  end

  describe ".map_ecosystem" do
    it "maps npm correctly" do
      expect(PurlParser.map_ecosystem("npm")).to eq("npm")
    end

    it "maps gem to rubygems" do
      expect(PurlParser.map_ecosystem("gem")).to eq("rubygems")
    end

    it "maps golang to go" do
      expect(PurlParser.map_ecosystem("golang")).to eq("go")
    end

    it "handles case insensitive mapping" do
      expect(PurlParser.map_ecosystem("NPM")).to eq("npm")
      expect(PurlParser.map_ecosystem("GEM")).to eq("rubygems")
    end

    it "returns nil for unsupported ecosystem" do
      expect(PurlParser.map_ecosystem("unsupported")).to be_nil
    end
  end

  describe ".generate_purl" do
    it "generates npm PURL" do
      result = PurlParser.generate_purl(
        ecosystem: "npm",
        package_name: "express",
        version: "4.17.1"
      )

      expect(result).to eq("pkg:npm/express@4.17.1")
    end

    it "generates npm PURL with namespace" do
      result = PurlParser.generate_purl(
        ecosystem: "npm",
        package_name: "node",
        namespace: "@types",
        version: "16.0.0"
      )

      expect(result).to eq("pkg:npm/%40types/node@16.0.0")
    end

    it "generates PURL without version" do
      result = PurlParser.generate_purl(
        ecosystem: "npm",
        package_name: "express"
      )

      expect(result).to eq("pkg:npm/express")
    end

    it "generates rubygems PURL" do
      result = PurlParser.generate_purl(
        ecosystem: "rubygems",
        package_name: "rails",
        version: "6.1.4"
      )

      expect(result).to eq("pkg:gem/rails@6.1.4")
    end

    it "returns nil for unsupported ecosystem" do
      result = PurlParser.generate_purl(
        ecosystem: "unsupported",
        package_name: "package"
      )

      expect(result).to be_nil
    end
  end

  describe ".reverse_map_ecosystem" do
    it "reverse maps npm correctly" do
      expect(PurlParser.reverse_map_ecosystem("npm")).to eq("npm")
    end

    it "reverse maps rubygems to gem" do
      expect(PurlParser.reverse_map_ecosystem("rubygems")).to eq("gem")
    end

    it "reverse maps go to golang" do
      expect(PurlParser.reverse_map_ecosystem("go")).to eq("golang")
    end

    it "returns nil for unmapped ecosystem" do
      expect(PurlParser.reverse_map_ecosystem("unknown")).to be_nil
    end
  end
end