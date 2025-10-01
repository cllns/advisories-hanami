# frozen_string_literal: true

ROM::SQL.migration do
  # Add your migration here.
  #
  # See https://guides.hanamirb.org/v2.2/database/migrations/ for details.
  change do
    create_table :advisories do
      primary_key :id
      foreign_key :source_id, :sources, null: false
      column :uuid, String
      column :url, String
      column :title, String
      column :description, "text"
      column :origin, String
      column :severity, String
      column :published_at, Time
      column :withdrawn_at, Time
      column :classification, String
      column :cvss_score, Float
      column :cvss_vector, String
      column :references, "text[]", default: "{}"
      column :source_kind, String
      column :identifiers, "text[]", default: "{}"
      column :repository_url, String
      column :blast_radius, Float
      column :epss_percentage, Float
      column :epss_percentile, Float

      column :packages, "jsonb", default: "[]"
      column :created_at, Time, null: false
      column :updated_at, Time, null: false
    end
  end
end
