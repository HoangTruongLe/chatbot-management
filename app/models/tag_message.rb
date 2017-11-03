class TagMessage < ApplicationRecord
  belongs_to :message
  belongs_to :tag
end
