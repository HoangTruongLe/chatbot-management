class ClickStatistic < ApplicationRecord
  belongs_to :clicked, polymorphic: true
  belongs_to :session_statistic, optional: true
end
