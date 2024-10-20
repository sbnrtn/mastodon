# frozen_string_literal: true

# == Schema Information
#
# Table name: gallery_categories
#
#  id          :bigint(8)        not null, primary key
#  name        :string           default(""), not null
#  description :text
#  order       :integer          default(0), not null
#  view_limit  :integer          default(5), not null
#  visibility  :integer          default("public"), not null
#  gallery_id  :bigint(8)
#  tag_id      :bigint(8)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class GalleryCategory < ApplicationRecord
  belongs_to :tag
  belongs_to :gallery, inverse_of: :gallery_categories

  enum visibility: { public: 0, private: 2 }, _suffix: :visibility

  validates :name, presence: true, length: { maximum: 60 }
  validates :description, length: { maximum: 500 }
  validates :order, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :sorted, -> { order(order: :asc) }

  def list_works
    account = gallery.account
    statuses = Status.joins(:tags).eager_load(:media_attachments)
                     .where(tags: { id: tag_id }, account: account)
                     .where.not(ordered_media_attachment_ids: '{}')

    if public_visibility?
      statuses = statuses.where(visibility: [Status.visibilities[:public], Status.visibilities[:unlisted], Status.visibilities[:limitedprofile]])
    elsif private_visibility?
      statuses = statuses.where(visibility: [Status.visibilities[:public], Status.visibilities[:unlisted], Status.visibilities[:limitedprofile], Status.visibilities[:private]])
    end

    statuses
  end

  class << self
    def selectable_visibilities
      visibilities.keys
    end
  end
end
