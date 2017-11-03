class QuoteJob < ApplicationJob
  def perform(copied_message, msg_cnt)
    quote = Quote.find_by_id(msg_cnt.content_id)
    copied_message.quotes.build(quote.dup.attributes)
    copied_message.save
  end
end
