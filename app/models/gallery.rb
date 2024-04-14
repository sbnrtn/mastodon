# frozen_string_literal: true

# == Schema Information
#
# Table name: galleries
#
#  id          :bigint(8)        not null, primary key
#  name        :string           default(""), not null
#  description :text             default(""), not null
#  image_url   :string
#  account_id  :bigint(8)        not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Gallery < ApplicationRecord
  belongs_to :account
  has_many :gallery_categories, dependent: :destroy

  validates :name, presence: true, length: { maximum: 60 }
  validates :description, presence: true, length: { maximum: 500 }
  validates :image_url, url: true, unless: -> { image_url.blank? }

  delegate :username, to: :account
end
