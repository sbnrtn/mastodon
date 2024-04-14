# frozen_string_literal: true

Fabricator(:gallery_category) do
  gallery { Fabricate.build(:gallery) }
  tag { Fabricate.build(:tag) }
  name 'name'
  description 'description'
  order 1
  visibility 0
end
