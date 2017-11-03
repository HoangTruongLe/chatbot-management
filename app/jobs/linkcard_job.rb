class LinkcardJob < ApplicationJob
  def perform(copied_message, msg_cnt)
    lc = LinkCard.find_by_id(msg_cnt.content_id)
    copied_message.link_cards.build(lc.dup.attributes)
    copied_message.save
  end
end
