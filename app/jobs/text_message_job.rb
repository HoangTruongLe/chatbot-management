class TextMessageJob < ApplicationJob
  def perform(copied_message, msg_cnt)
    tm = TextMessage.find_by_id(msg_cnt.content_id)
    copied_message.text_messages.build(tm.dup.attributes)
    copied_message.save
  end
end
