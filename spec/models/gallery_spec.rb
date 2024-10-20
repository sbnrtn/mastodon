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

  describe '#list_works' do
    let(:account) { Fabricate(:account) }
    let(:gallery) { Fabricate.build(:gallery, account: account, image_url: 'test') }
    let(:tag) { Fabricate(:tag) }
    let(:category) { Fabricate(:gallery_category, gallery: gallery, tag: tag) }

    let!(:public_status) { Fabricate(:status, account: account, visibility: :public) }
    let!(:unlisted_status) { Fabricate(:status, account: account, visibility: :unlisted) }
    let!(:private_status) { Fabricate(:status, account: account, visibility: :private) }
    let!(:limited_profile_status) { Fabricate(:status, account: account, visibility: :limitedprofile) }

    before do
      [public_status, unlisted_status, private_status, limited_profile_status].each do |status|
        status.tags << tag
        Fabricate(:media_attachment, status: status)
        status.update(ordered_media_attachment_ids: status.media_attachments.pluck(:id))
      end
    end

    context 'when not logged in' do
      it 'returns public, unlisted, and limited profile statuses' do
        results = category.list_works
        expect(results).to include(public_status, unlisted_status, limited_profile_status)
        expect(results).to_not include(private_status)
      end
    end

    context 'when logged in' do
      it 'returns all statuses' do
        results = category.list_works(logged_in: true)
        expect(results).to include(public_status, unlisted_status, private_status, limited_profile_status)
      end
    end

    context 'when category is public and not logged in' do
      before { category.update(visibility: :public) }

      it 'returns public, unlisted, and limited profile statuses' do
        results = category.list_works
        expect(results).to include(public_status, unlisted_status, limited_profile_status)
        expect(results).to_not include(private_status)
      end
    end

    context 'when category is private and not logged in' do
      before { category.update(visibility: :private) }

      it 'returns public, unlisted, and limited profile statuses' do
        results = category.list_works
        expect(results).to include(public_status, unlisted_status, limited_profile_status)
        expect(results).to_not include(private_status)
      end
    end

    context 'when category is public and logged in' do
      before { category.update(visibility: :public) }

      it 'returns all statuses' do
        results = category.list_works(logged_in: true)
        expect(results).to include(public_status, unlisted_status, private_status, limited_profile_status)
      end
    end

    context 'when category is private and logged in' do
      before { category.update(visibility: :private) }

      it 'returns all statuses' do
        results = category.list_works(logged_in: true)
        expect(results).to include(public_status, unlisted_status, private_status, limited_profile_status)
      end
    end

    context 'when status has no media attachments' do
      let!(:status_without_media) { Fabricate(:status, account: account, visibility: :public) }

      before do
        status_without_media.tags << tag
        status_without_media.update(ordered_media_attachment_ids: [])
      end

      it 'does not include statuses without media attachments' do
        results = category.list_works
        expect(results).to_not include(status_without_media)
      end
    end

    context 'when status belongs to a different account' do
      let(:other_account) { Fabricate(:account) }
      let!(:other_status) { Fabricate(:status, account: other_account, visibility: :public) }

      before do
        other_status.tags << tag
        Fabricate(:media_attachment, status: other_status)
        other_status.update(ordered_media_attachment_ids: other_status.media_attachments.pluck(:id))
      end

      it 'does not include statuses from other accounts' do
        results = category.list_works
        expect(results).to_not include(other_status)
      end
    end
  end
end
