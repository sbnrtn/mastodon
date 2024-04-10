# frozen_string_literal: true

class CreateGalleries < ActiveRecord::Migration[7.0]
  def change
    create_table :galleries do |t|
      t.string :name, null: false, default: ''
      t.text :description, null: false, default: ''
      t.string :image_url, null: true
      t.references :account, foreign_key: true, null: false

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    create_table :gallery_categories do |t|
      t.string :name, null: false, default: ''
      t.text :description, null: true
      t.integer :order, null: false, default: 0
      t.integer :view_limit, null: false, default: 5
      t.integer :visibility, null: false, default: 0
      t.belongs_to :gallery, foreign_key: { on_delete: :cascade }
      t.belongs_to :tag

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
