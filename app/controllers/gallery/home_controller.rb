# frozen_string_literal: true

class Gallery::HomeController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update]
  before_action :gallery, only: [:new, :create, :edit, :update]
  before_action :account, only: [:show, :show_category, :show_work]

  layout 'gallery'

  def show; end

  def show_category
    @gallery_category = @gallery.gallery_categories.find(params[:id])
    not_found if @gallery_category.private_visibility? && !user_signed_in?
  end

  def show_work
    @gallery_category = GalleryCategory.find(params[:category_id])
    return not_found if @gallery_category.private_visibility? && !user_signed_in?

    @work = @gallery_category.list_works.find(params[:id])

    not_found if @work.nil?
  end

  def new
    if Gallery.find_by(account: @account).present?
      redirect_to gallery_path(@account)
      return
    end

    @gallery = Gallery.new
    render :new
  end

  def edit
    @gallery = Gallery.find_by(account: @account)
  end

  def create
    @gallery = Gallery.new(gallery_params.merge(account: @account))

    if @gallery.save
      redirect_to gallery_path(@account), notice: 'Gallery was successfully created.' # rubocop:disable Rails/I18nLocaleTexts
    else
      render :new
    end
  end

  def update
    @gallery = Gallery.find_by(account: @account)

    if @gallery.update(gallery_params)
      redirect_to gallery_path(@account), notice: 'Gallery was successfully updated.' # rubocop:disable Rails/I18nLocaleTexts
    else
      render :edit
    end
  end

  private

  def account
    @account = Account.find_local!(params[:username])
    @gallery = Gallery.find_by(account: @account)

    return redirect_to new_gallery_home_path if @gallery.nil? && user_signed_in?

    not_found if @gallery.nil?
  end

  def gallery
    @account = current_account
  end

  def gallery_params
    params.require(:gallery).permit(:name, :description, :footer, :image_url)
  end
end
