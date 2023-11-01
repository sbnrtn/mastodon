# frozen_string_literal: true

class EmojiReactService < BaseService
  include Authorization
  include Payloadable

  # React a status with emoji and notify remote user
  # @param [Account] account
  # @param [Status] status
  # @param [string] name
  # @return [Favourite]
  def call(account, status, name)
    status = status.reblog if status.reblog? && !status.reblog.nil?
    authorize_with account, status, :emoji_reaction?

    emoji_reaction = nil

    emoji_reaction = EmojiReaction.find_by(account: account, status: status, name: name)
    raise Mastodon::ValidationError, I18n.t('reactions.errors.duplication') unless emoji_reaction.nil?

    shortcode, domain = name.split('@')
    domain = nil if TagManager.instance.local_domain?(domain)
    custom_emoji = CustomEmoji.find_by(shortcode: shortcode, domain: domain)
    return if domain.present? && !EmojiReaction.exists?(status: status, custom_emoji: custom_emoji)

    emoji_reaction = EmojiReaction.create!(account: account, status: status, name: shortcode, custom_emoji: custom_emoji)

    status.touch # rubocop:disable Rails/SkipsModelValidations

    raise Mastodon::ValidationError, I18n.t('reactions.errors.duplication') if emoji_reaction.nil?

    write_stream(emoji_reaction)

    emoji_reaction
  end

  private

  def write_stream(emoji_reaction)
    emoji_group = emoji_reaction.status.emoji_reactions_grouped_by_name(nil, force: true)
                                .find { |reaction_group| reaction_group['name'] == emoji_reaction.name && (!reaction_group.key?(:domain) || reaction_group['domain'] == emoji_reaction.custom_emoji&.domain) }
    emoji_group['status_id'] = emoji_reaction.status_id.to_s
    DeliveryEmojiReactionWorker.perform_async(render_emoji_reaction(emoji_group), emoji_reaction.status_id, emoji_reaction.account_id)
  end

  def render_emoji_reaction(emoji_group)
    # @rendered_emoji_reaction ||= InlineRenderer.render(HashObject.new(emoji_group), nil, :emoji_reaction)
    @render_emoji_reaction ||= Oj.dump(event: :emoji_reaction, payload: emoji_group.to_json)
  end
end
