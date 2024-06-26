# frozen_string_literal: true

Fabricator(:gallery) do
  account { Fabricate.build(:account) }
  name 'name'
  description 'description'
  footer 'footer'
  image_url 'https://example.com/test.png'
end
