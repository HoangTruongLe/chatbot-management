class MessageStatistic < ApplicationRecord
  belongs_to :message
  belongs_to :conversation_status
end
