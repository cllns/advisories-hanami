# frozen_string_literal: true

module AdvisoriesApp
  module Repos
    class SourceRepo < AdvisoriesApp::DB::Repo
      commands :create, update: :by_pk, delete: :by_pk
    end
  end
end
