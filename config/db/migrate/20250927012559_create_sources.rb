# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :sources do
      primary_key :id
      column :name, String
      column :kind, String
      column :url, String
      column :advisories_count, Integer, default: 0
      column :metadata, "jsonb", default: "{}"

      column :created_at, Time, null: false
      column :updated_at, Time, null: false
    end
  end
end
