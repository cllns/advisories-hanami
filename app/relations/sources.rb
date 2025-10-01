# frozen_string_literal: true

module AdvisoriesApp
  module Relations
    class Sources < AdvisoriesApp::DB::Relation
      schema :sources, infer: true
    end
  end
end
