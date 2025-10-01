# frozen_string_literal: true

module AdvisoriesApp
  module Relations
    class Exports < AdvisoriesApp::DB::Relation
      schema :exports, infer: true
    end
  end
end
