# frozen_string_literal: true

Fabricator(:gallery) do
  account { Fabricate.build(:account) }
  name 'name'
  description 'description'
  image_url 'https://example.com/test.png'
end
