# frozen_string_literal: true

class CreateEmojiReactions < ActiveRecord::Migration[6.1]
  def change
    create_table :emoji_reactions do |t|
      t.belongs_to :account, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :status, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false, default: ''
      t.belongs_to :custom_emoji, foreign_key: { on_delete: :cascade }
      t.string :uri
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    safety_assured do
      add_column :status_stats, :emoji_reactions, :string
      add_column :status_stats, :emoji_reactions_count, :integer, null: false, default: 0
      add_column :status_stats, :emoji_reaction_accounts_count, :integer, null: false, default: 0
    end
  end
end
