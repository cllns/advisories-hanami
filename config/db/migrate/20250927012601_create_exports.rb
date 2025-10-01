# frozen_string_literal: true

ROM::SQL.migration do
  # Add your migration here.
  #
  # See https://guides.hanamirb.org/v2.2/database/migrations/ for details.
  change do
    create_table :exports do
      primary_key :id
      column :date, String
      column :bucket_name, String
      column :advisories_count, Integer

      column :created_at, Time, null: false
      column :updated_at, Time, null: false
    end
  end
end
