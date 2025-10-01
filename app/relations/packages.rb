# frozen_string_literal: true

module AdvisoriesApp
  module Relations
    class Packages < AdvisoriesApp::DB::Relation
      schema :packages, infer: true
    end
  end
end
