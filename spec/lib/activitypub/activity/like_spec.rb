# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::Like do
  let(:sender)    { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/') }
  let(:recipient) { Fabricate(:account) }
  let(:status)    { Fabricate(:status, account: recipient) }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Like',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: ActivityPub::TagManager.instance.uri_for(status),
    }.with_indifferent_access
  end
  let(:original_emoji) do
    {
      id: 'https://example.com/aaa',
      type: 'Emoji',
      icon: {
        url: 'http://example.com/emoji.png',
      },
      name: 'tinking',
    }
  end
  let(:original_invalid_emoji) do
    {
      id: 'https://example.com/invalid',
      type: 'Emoji',
      icon: {
        url: 'http://example.com/emoji.png',
      },
      name: 'other',
    }
  end

  describe '#perform' do
    subject { described_class.new(json, sender) }

    before do
      subject.perform
    end

    it 'creates a favourite from sender to status' do
      expect(sender.favourited?(status)).to be true
    end
  end

  describe '#perform when receive emoji reaction' do
    subject do
      described_class.new(json, sender).perform
      EmojiReaction.where(status: status)
    end

    before do
      stub_request(:get, 'http://example.com/emoji.png').to_return(body: attachment_fixture('emojo.png'))
      stub_request(:get, 'http://foo.bar/emoji2.png').to_return(body: attachment_fixture('emojo.png'))
      stub_request(:get, 'https://example.com/aaa').to_return(status: 200, body: Oj.dump(original_emoji), headers: { 'Content-Type': 'application/activity+json' })
      stub_request(:get, 'https://example.com/invalid').to_return(status: 200, body: Oj.dump(original_invalid_emoji), headers: { 'Content-Type': 'application/activity+json' })
    end

    let(:json) do
      {
        '@context': 'https://www.w3.org/ns/activitystreams',
        id: 'foo',
        type: 'Like',
        actor: ActivityPub::TagManager.instance.uri_for(sender),
        object: ActivityPub::TagManager.instance.uri_for(status),
        content: content,
        tag: tag,
      }.with_indifferent_access
    end
    let(:content) { nil }
    let(:tag) { nil }

    context 'with unicode emoji' do
      let(:content) { '😀' }

      it 'create emoji reaction' do
        expect(subject.count).to eq 1
        expect(subject.first.name).to eq '😀'
        expect(subject.first.account).to eq sender
        expect(sender.favourited?(status)).to be false
      end
    end

    context 'with custom emoji' do
      let(:content) { ':tinking:' }
      let(:tag) do
        {
          id: 'https://example.com/aaa',
          type: 'Emoji',
          icon: {
            url: 'http://example.com/emoji.png',
          },
          name: 'tinking',
        }
      end

      it 'create emoji reaction' do
        expect(subject.count).to eq 1
        expect(subject.first.name).to eq 'tinking'
        expect(subject.first.account).to eq sender
        expect(subject.first.custom_emoji).to_not be_nil
        expect(subject.first.custom_emoji.shortcode).to eq 'tinking'
        expect(subject.first.custom_emoji.domain).to eq 'example.com'
        expect(sender.favourited?(status)).to be false
      end
    end

    context 'with custom emoji but that is existing on local server' do
      let(:content) { ':tinking:' }
      let(:tag) do
        {
          id: 'https://example.com/aaa',
          type: 'Emoji',
          icon: {
            url: 'http://example.com/emoji.png',
          },
          name: 'tinking',
        }
      end

      before do
        Fabricate(:custom_emoji, domain: 'example.com', uri: 'https://example.com/aaa', image_remote_url: 'http://example.com/emoji.png', shortcode: 'tinking')
      end

      it 'create emoji reaction' do
        expect(subject.count).to eq 1
        expect(subject.first.name).to eq 'tinking'
        expect(subject.first.account).to eq sender
        expect(subject.first.custom_emoji).to_not be_nil
        expect(subject.first.custom_emoji.shortcode).to eq 'tinking'
        expect(subject.first.custom_emoji.domain).to eq 'example.com'
        expect(sender.favourited?(status)).to be false
      end
    end

    context 'with custom emoji from non-original server account' do
      let(:content) { ':tinking:' }
      let(:tag) do
        {
          id: 'https://example.com/aaa',
          type: 'Emoji',
          icon: {
            url: 'http://example.com/emoji.png',
          },
          name: 'tinking',
        }
      end

      before do
        sender.update(domain: 'ohagi.com')
        Fabricate(:custom_emoji, domain: 'example.com', uri: 'https://example.com/aaa', shortcode: 'tinking')
      end

      it 'create emoji reaction' do
        expect(subject.count).to eq 1
        expect(subject.first.name).to eq 'tinking'
        expect(subject.first.account).to eq sender
        expect(subject.first.custom_emoji).to_not be_nil
        expect(subject.first.custom_emoji.shortcode).to eq 'tinking'
        expect(subject.first.custom_emoji.domain).to eq 'example.com'
        expect(sender.favourited?(status)).to be false
      end
    end

    context 'with custom emoji but icon url is not valid' do
      let(:content) { ':tinking:' }
      let(:tag) do
        {
          id: 'https://example.com/aaa',
          type: 'Emoji',
          icon: {
            url: 'http://foo.bar/emoji.png',
          },
          name: 'tinking',
        }
      end

      before do
        sender.update(domain: 'ohagi.com')
        Fabricate(:custom_emoji, domain: 'example.com', uri: 'https://example.com/aaa', shortcode: 'tinking', image_remote_url: 'http://example.com/emoji.png')
      end

      it 'create emoji reaction' do
        expect(subject.count).to eq 1
        expect(subject.first.custom_emoji.image_remote_url).to eq 'http://example.com/emoji.png'
      end
    end

    context 'with custom emoji but uri is not valid' do
      let(:content) { ':tinking:' }
      let(:tag) do
        {
          id: 'https://example.com/invalid',
          type: 'Emoji',
          icon: {
            url: 'http://foo.bar/emoji2.png',
          },
          name: 'tinking',
        }
      end

      before do
        sender.update(domain: 'ohagi.com')
        Fabricate(:custom_emoji, domain: 'example.com', uri: 'https://example.com/aaa', shortcode: 'tinking', image_remote_url: 'http://example.com/emoji.png')
      end

      it 'create emoji reaction' do
        expect(subject.count).to eq 0
      end
    end

    context 'with custom emoji but invalid id' do
      let(:content) { ':tinking:' }
      let(:tag) do
        {
          id: 'aaa',
          type: 'Emoji',
          icon: {
            url: 'http://example.com/emoji.png',
          },
          name: 'tinking',
        }
      end

      it 'create emoji reaction' do
        expect(subject.count).to eq 1
        expect(subject.first.name).to eq 'tinking'
        expect(subject.first.account).to eq sender
        expect(subject.first.custom_emoji).to_not be_nil
        expect(subject.first.custom_emoji.shortcode).to eq 'tinking'
        expect(subject.first.custom_emoji.domain).to eq 'example.com'
        expect(sender.favourited?(status)).to be false
      end
    end

    context 'with custom emoji but local domain' do
      let(:content) { ':tinking:' }
      let(:tag) do
        {
          id: 'https://cb6e6126.ngrok.io/aaa',
          type: 'Emoji',
          domain: Rails.configuration.x.local_domain,
          icon: {
            url: 'http://example.com/emoji.png',
          },
          name: 'tinking',
        }
      end

      before do
        Fabricate(:custom_emoji, domain: nil, shortcode: 'tinking')
      end

      it 'create emoji reaction' do
        expect(subject.count).to eq 1
        expect(subject.first.name).to eq 'tinking'
        expect(subject.first.account).to eq sender
        expect(subject.first.custom_emoji).to_not be_nil
        expect(subject.first.custom_emoji.shortcode).to eq 'tinking'
        expect(subject.first.custom_emoji.domain).to be_nil
        expect(sender.favourited?(status)).to be false
      end
    end

    context 'with unicode emoji and reject_media enabled' do
      let(:content) { '😀' }

      before do
        Fabricate(:domain_block, domain: 'example.com', severity: :noop, reject_media: true)
      end

      it 'create emoji reaction' do
        expect(subject.count).to eq 1
        expect(subject.first.name).to eq '😀'
        expect(subject.first.account).to eq sender
        expect(sender.favourited?(status)).to be false
      end
    end

    context 'with custom emoji and reject_media enabled' do
      let(:content) { ':tinking:' }
      let(:tag) do
        {
          id: 'https://example.com/aaa',
          type: 'Emoji',
          icon: {
            url: 'http://example.com/emoji.png',
          },
          name: 'tinking',
        }
      end

      before do
        Fabricate(:domain_block, domain: 'example.com', severity: :noop, reject_media: true)
      end

      it 'create emoji reaction' do
        expect(subject.count).to eq 0
        expect(sender.favourited?(status)).to be false
      end
    end
  end

  describe '#perform when normal domain_block' do
    subject { described_class.new(json, sender) }

    before do
      Fabricate(:domain_block, domain: 'example.com', severity: :suspend)
      subject.perform
    end

    it 'does not create a favourite from sender to status' do
      expect(sender.favourited?(status)).to be false
    end
  end
end
