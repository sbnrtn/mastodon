# frozen_string_literal: true

class Gallery::CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :gallery

  layout 'gallery'

  def index
    @gallery_categories = @gallery.gallery_categories.order(order: :asc)
  end

  def new
    @gallery_category = @gallery.gallery_categories.build
  end

  def edit
    @gallery_category = @gallery.gallery_categories.find(params[:id])
  end

  def create
    @gallery_category = @gallery.gallery_categories.new(gallery_category_params)

    if @gallery_category.save
      redirect_to gallery_categories_path, notice: 'Category was successfully created.' # rubocop:disable Rails/I18nLocaleTexts
    else
      render :new
    end
  end

  def update
    @gallery_category = @gallery.gallery_categories.find(params[:id])

    if @gallery_category.update(gallery_category_params)
      redirect_to gallery_categories_path, notice: 'Category was successfully updated.' # rubocop:disable Rails/I18nLocaleTexts
    else
      render :edit
    end
  end

  def destroy
    @gallery_category = @gallery.gallery_categories.find(params[:id])

    if @gallery_category.destroy
      redirect_to gallery_categories_path, notice: 'Category was successfully deleted.' # rubocop:disable Rails/I18nLocaleTexts
    else
      redirect_to gallery_categories_path, notice: 'Category failed to delete.' # rubocop:disable Rails/I18nLocaleTexts
    end
  end

  private

  def gallery
    @account = current_account

    @gallery = Gallery.find_by(account: @account)
    redirect_to new_gallery_home_path if @gallery.nil?
  end

  def gallery_category_params
    params.require(:gallery_category).permit(:name, :description, :order, :view_limit, :visibility, :tag_id)
  end
end
