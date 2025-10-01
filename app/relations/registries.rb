# frozen_string_literal: true

module AdvisoriesApp
  module Relations
    class Registries < AdvisoriesApp::DB::Relation
      schema :registries, infer: true
    end
  end
end
