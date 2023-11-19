# frozen_string_literal: true

class DeliveryEmojiReactionWorker
  include Sidekiq::Worker
  include Redisable
  include AccountScope

  def perform(payload_json, status_id, reacted_account_id)
    status = Status.find(status_id)
    reacted_account = Account.find(reacted_account_id)

    if status.present?
      scope = scope_status(status)

      scope.select(:id).includes(:user).find_each do |account|
        next if account.user.present?
        next unless redis.exists?("subscribed:timeline:#{account.id}")
        next if !reacted_account.local? && account.excluded_from_timeline_domains.include?(reacted_account.domain)

        redis.publish("timeline:#{account.id}", payload_json)
      end
    end

    true
  rescue ActiveRecord::RecordNotFound
    true
  end
end
