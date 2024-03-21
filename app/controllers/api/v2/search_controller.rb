# frozen_string_literal: true

class Api::V2::SearchController < Api::BaseController
  include Authorization

  RESULTS_LIMIT = 20

  before_action -> { authorize_if_got_token! :read, :'read:search' }
  before_action :validate_search_params!

  def index
    @search = Search.new(search_results)
    render json: @search, serializer: REST::SearchSerializer
  rescue Mastodon::SyntaxError
    unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  private

  def validate_search_params!
    params.require(:q)

    return if user_signed_in?

    render json: { error: 'Search is not supported without authentication' }, status: 401 and return
  end

  def search_results
    SearchService.new.call(
      params[:q],
      current_account,
      limit_param(RESULTS_LIMIT),
      search_params.merge(resolve: truthy_param?(:resolve), exclude_unreviewed: truthy_param?(:exclude_unreviewed), following: truthy_param?(:following))
    )
  end

  def search_params
    params.permit(:type, :offset, :min_id, :max_id, :account_id, :following)
  end
end
