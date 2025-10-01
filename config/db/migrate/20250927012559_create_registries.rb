# frozen_string_literal: true

ROM::SQL.migration do
  # Add your migration here.
  #
  # See https://guides.hanamirb.org/v2.2/database/migrations/ for details.
  change do
    create_table :registries do
      primary_key :id
      column :name, String
      column :url, String
      column :ecosystem, String
      column :default, TrueClass, default: false
      column :packages_count, Integer, default: 0
      column :github, String
      column :metadata, "jsonb", default: "{}"

      column :created_at, Time, null: false
      column :updated_at, Time, null: false
    end
  end
end
