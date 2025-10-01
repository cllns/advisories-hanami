# frozen_string_literal: true

module AdvisoriesApp
  class Routes < Hanami::Routes
    root to: "home.index"

    scope "api" do
      scope "v1" do
        get "/advisories", to: "api.v1.advisories.index"
        get "/advisories/packages", to: "api.v1.advisories.packages"
        get "/advisories/lookup", to: "api.v1.advisories.lookup"
        get "/advisories/:id", to: "api.v1.advisories.show"
      end
    end

    get "/advisories", to: "advisories.index"
    get "/advisories/:id", to: "advisories.show"
    get "/recent_advisories_data", to: "advisories.recent_advisories_data"

    get "/open-data", to: "exports.index"

    get "/404", to: "errors.not_found"
    get "/422", to: "errors.unprocessable"
    get "/500", to: "errors.internal"
  end
end
