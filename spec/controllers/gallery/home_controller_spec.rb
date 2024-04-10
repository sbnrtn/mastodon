# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable  RSpec/RepeatedExampleGroupDescription
describe Gallery::HomeController do
  render_views

  let(:user) { Fabricate(:user) }
  let(:account) { Fabricate(:account) }

  describe 'GET #new' do
    context 'when gallery is nil' do
      it 'redirects to new gallery home path if user is signed in' do
        sign_in user, scope: :user
        get :show, params: { username: account.username }

        expect(response).to redirect_to(new_gallery_home_path)
      end

      it 'responds with 404 if user is not signed in' do
        sign_out user

        get :show, params: { username: account.username }

        expect(response).to have_http_status(404)
      end
    end

    context 'when gallery is not nil' do
      let(:gallery) { Fabricate.create(:gallery, account: account) }

      before do
        allow(controller).to receive(:gallery).and_return(gallery)
      end

      it 'returns http success' do
        get :show, params: { username: account.username }

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET #show_category' do
    context 'when gallery is nil' do
      it 'responds with 404' do
        get :show_category, params: { username: account.username, id: 1 }

        expect(response).to have_http_status(404)
      end
    end

    context 'when gallery category is private and user is not signed in' do
      let(:gallery) { Fabricate.create(:gallery, account: account) }
      let(:gallery_category) { Fabricate(:gallery_category, gallery: gallery, visibility: 2) }

      it 'responds with 404' do
        get :show_category, params: { username: account.username, id: gallery_category.id }

        expect(response).to have_http_status(404)
      end
    end

    context 'when gallery category is private and user is signed in' do
      let(:gallery) { Fabricate.create(:gallery, account: account) }
      let(:gallery_category) { Fabricate(:gallery_category, gallery: gallery, visibility: 2) }

      before do
        sign_in user, scope: :user
      end

      it 'responds http success' do
        get :show_category, params: { username: account.username, id: gallery_category.id }

        expect(response).to have_http_status(200)
      end
    end

    context 'when gallery is nil' do
      let(:gallery_category) { Fabricate(:gallery_category, visibility: 2) }

      before do
        allow(controller).to receive(:gallery).and_return(nil)
      end

      it 'responds with 404' do
        get :show_category, params: { username: account.username, id: gallery_category.id }

        expect(response).to have_http_status(404)
      end
    end

    context 'when gallery category is public' do
      let(:gallery) { Fabricate.create(:gallery, account: account) }
      let(:gallery_category) { Fabricate(:gallery_category, gallery: gallery, visibility: 0) }

      it 'returns http success' do
        get :show_category, params: { username: account.username, id: gallery_category.id }

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET #show_work' do
    let(:gallery) { Fabricate.create(:gallery, account: account) }
    let(:tag) { Fabricate(:tag) }
    let(:gallery_category) { Fabricate(:gallery_category, gallery: gallery, tag: tag, visibility: 2) }
    let(:status) { Fabricate(:status, account: account) }
    let!(:media_attachment) { Fabricate(:media_attachment, account: account, status: status, type: :image) } # rubocop:disable RSpec/LetSetup

    context 'when gallery is nil' do
      before do
        gallery.destroy!
      end

      it 'responds with 404' do
        get :show_work, params: { username: account.username, category_id: 1, id: 1 }

        expect(response).to have_http_status(404)
      end
    end

    context 'when gallery category is private and user is not signed in' do
      it 'responds with 404' do
        get :show_work, params: { username: account.username, category_id: gallery_category.id, id: status.id }

        expect(response).to have_http_status(404)
      end
    end

    context 'when gallery category is private and user is signed in' do
      before do
        sign_in user, scope: :user
        status.tags << tag
      end

      it 'responds http success' do
        get :show_work, params: { username: account.username, category_id: gallery_category.id, id: status.id }

        expect(response).to have_http_status(200)
      end
    end

    context 'when gallery category is public' do
      let(:gallery_category) { Fabricate(:gallery_category, gallery: gallery, tag: tag, visibility: 0) }

      before do
        status.tags << tag
      end

      it 'returns http success' do
        get :show_work, params: { username: account.username, category_id: gallery_category.id, id: status.id }

        expect(response).to have_http_status(200)
      end
    end
  end
end
# rubocop:enable RSpec/RepeatedExampleGroupDescription
