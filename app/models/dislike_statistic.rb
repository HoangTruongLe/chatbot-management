class DislikeStatistic < ApplicationRecord
  belongs_to :dislike, polymorphic: true
  belongs_to :session_statistic, optional: true
end
