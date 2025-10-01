# frozen_string_literal: true

ROM::SQL.migration do
  # Add your migration here.
  #
  # See https://guides.hanamirb.org/v2.2/database/migrations/ for details.
  change do
    create_table :packages do
      primary_key :id
      column :ecosystem, String
      column :name, String
      column :description, String
      column :registry_url, String
      column :last_synced_at, Time
      column :dependent_packages_count, Integer
      column :dependent_repos_count, Integer
      column :downloads, "bigint"
      column :downloads_period, String
      column :latest_release_number, String
      column :repository_url, String
      column :versions_count, Integer
      column :version_numbers, "text[]", default: "{}"
      column :advisories_count, Integer, default: 0
      column :etag, String
      column :last_modified, String

      column :created_at, Time, null: false
      column :updated_at, Time, null: false
    end
  end
end
