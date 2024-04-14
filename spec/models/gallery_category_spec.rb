# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/RepeatedDescription
RSpec.describe GalleryCategory do
  let(:gallery) { Fabricate(:gallery) }

  describe 'validations' do
    it 'is invalid without a name' do
      category = Fabricate.build(:gallery_category, name: nil)
      category.valid?
      expect(category).to model_have_error_on_field(:name)
    end

    it 'is invalid without a order' do
      category = Fabricate.build(:gallery_category, order: nil)
      category.valid?
      expect(category).to model_have_error_on_field(:order)
    end

    it 'is invalid order' do
      category = Fabricate.build(:gallery_category, order: 'abc')
      category.valid?
      expect(category).to model_have_error_on_field(:order)
    end

    it 'is invalid order' do
      category = Fabricate.build(:gallery_category, order: -1)
      category.valid?
      expect(category).to model_have_error_on_field(:order)
    end

    it 'is invalid without a gallery' do
      gallery = Fabricate.build(:gallery_category, gallery: nil)
      gallery.valid?
      expect(gallery).to model_have_error_on_field(:gallery)
    end
  end
end
# rubocop:enable RSpec/RepeatedDescription
