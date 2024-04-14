# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gallery do
  let(:account) { Fabricate(:account) }

  describe 'validations' do
    it 'is invalid without a name' do
      gallery = Fabricate.build(:gallery, name: nil)
      gallery.valid?
      expect(gallery).to model_have_error_on_field(:name)
    end

    it 'is invalid without a description' do
      gallery = Fabricate.build(:gallery, description: nil)
      gallery.valid?
      expect(gallery).to model_have_error_on_field(:description)
    end

    it 'is invalid without a account' do
      gallery = Fabricate.build(:gallery, account: nil)
      gallery.valid?
      expect(gallery).to model_have_error_on_field(:account)
    end

    it 'is not invalid without a image_url' do
      gallery = Fabricate.build(:gallery, image_url: nil)
      gallery.valid?
      expect(gallery).to_not model_have_error_on_field(:image_url)
    end

    it 'is not invalid url format image_url' do
      gallery = Fabricate.build(:gallery, image_url: 'https://example.com/test2.png')
      gallery.valid?
      expect(gallery).to_not model_have_error_on_field(:image_url)
    end

    it 'is invalid not url format image_url' do
      gallery = Fabricate.build(:gallery, image_url: 'test')
      gallery.valid?
      expect(gallery).to model_have_error_on_field(:image_url)
    end
  end
end
