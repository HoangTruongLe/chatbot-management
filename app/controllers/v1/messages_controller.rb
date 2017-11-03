class V1::MessagesController < V1::BaseController
  before_action :session_interaction

  def existed_open_keyword
    meta_keywords = (params[:meta_keywords] && !params[:meta_keywords].blank?) ? params[:meta_keywords] : "*"
    new_keywords = meta_keywords.split(',').map{ |key| key.strip }
    @messages = Message.published.open_middle.joins(:keyword).where('keywords.name IN (?)', new_keywords)
    @text_message = @messages.first.message_contents.where(content_type: 'TextMessage').order(:row_order).first.content.content unless @messages.blank?
  end

  def get_message
    answer_keyword = params[:answer_keyword] || nil
    message_type = params[:message_type] || nil
    answer_id = params[:answer_id] || nil

    keywords =  if message_type == 'open'
                  (params[:meta_keywords] && !params[:meta_keywords].blank?) ? params[:meta_keywords].split(',') : ["*"]
                else
                  answer_keyword = params[:answer_keyword].split(',')
                  get_keywords_from_ids(answer_keyword)
                end
    best_keywords, second_keywords = get_the_best_keyword(keywords)
    # first choice
    @message = get_message_from_keywords(best_keywords, message_type)
    # second choice
    @message = get_message_from_keywords(second_keywords, message_type) if @message.blank?
    # last choice when don't get any next message
    # @message = get_message_from_keyword_max_cpc(message_type) if @message.blank?
    @message
  end

  # def get_message_from_keyword_max_cpc message_type
  #   messages =
  #     if message_type == 'open'
  #       Message.published.open
  #     else
  #       Message.published.close
  #     end
  #   get_message_max_weight(messages)
  # end

  # def get_message_max_weight messages
  #   mw = messages.map(&:weight).max
  #   mw_messages = messages.select { |w| w.weight == mw }
  #   message = mw_messages[rand(mw_messages.size) - 1]
  #   message
  # end

  def get_message_from_keywords keywords, message_type
    messages = []
    keywords.each do |key|
      messages =
        if message_type == 'open'
          key.messages.published.open_middle.order(priority: :desc) # + key.messages_relative.published.open_middle
        else
          key.messages.published.middle_close.order(priority: :desc) # + key.messages_relative.published.middle_close
        end
      # Remove messages that displayed / Exclude messages rendered
      messages = messages.select { |m| get_message_stack_chatting.exclude?(m.id) }

      break unless messages.blank?
    end
    # get_message_max_weight(messages)
    choice_best_message(messages)
  end

  def choice_best_message messages
    if messages.count > 1
      max_priority = messages.first.priority
      new_messages = messages.select { |msg| msg.priority = max_priority }
      if new_messages.count > 1

        # messages_display_number_filter
        new_messages = messages_display_number_filter(new_messages)

        m_rel_key_msgs = new_messages
        max_rel_cpc = 0
        new_messages.each do |msg|
          msg.relative_keywords.each do |rel_key|
            if max_rel_cpc < rel_key.keyword.cpc
              m_rel_key_msgs = []
              max_rel_cpc = rel_key.keyword.cpc
            end
            if max_rel_cpc == rel_key.keyword.cpc
              m_rel_key_msgs << msg
            end
          end
        end
        return m_rel_key_msgs[rand(m_rel_key_msgs.size) - 1]
      else
        return new_messages.first
      end
    else
      messages.first
    end
  end

  def get_the_best_keyword keywords
    new_keyword = keywords.join(' ')
    best_keywords = Keyword.where(name: keywords)
    # second_keywords = Keyword.search new_keyword, match: :phrase, order: { cpc: :desc }
    second_keywords = Keyword.search new_keyword, operator: 'or', fields: [:name], order: { cpc: :desc }
    return best_keywords, second_keywords
  end

  # backup
  def get_message_aa
    answer_keyword = params[:answer_keyword] || nil
    message_type = params[:message_type] || nil
    if message_type == 'open'
      meta_keywords = params[:meta_keywords].split(',')
      messages = Message.published.open
      @message = get_max_cpc_keyword(messages, meta_keywords, true)
    else
      answer_keyword = params[:answer_keyword].split(',')
      messages = Message.published.middle_close
      @message = get_max_cpc_keyword(messages, answer_keyword, false)
    end
    @message
  end

  private

  # Solution 1
  # =============================================
  def get_max_cpc_keyword messages, keywords_param, is_open
    # get all keywords from messages
    keywords = get_keywords_from_messages(messages)
    kw_cpc = []
    # when middle, get keywords from id (answer)
    keywords_param = get_keywords_from_ids(keywords_param) unless is_open
    # when  keywords_param == nil?
    keywords_param.each do |m|
      keywords.each do |k|
        next if k.cpc.nil?
        if chk_substr(m, k.name)
          kw_cpc << k
        end
      end
    end
    max_cpc = kw_cpc.map(&:cpc).max
    max_kw_cpc = kw_cpc.select { |k| k.cpc = max_cpc }
    # If not exist any keyword
    if max_kw_cpc.blank?
      mw = messages.map(&:weight).max
      mw_messages = messages.select { |w| w.weight == mw }
      mw_messages[rand(mw_messages.size - 1)]
    else
      get_message_from_keyword(max_kw_cpc[rand(max_kw_cpc.size - 1)], is_open)
    end
  end

  def get_keywords_from_messages messages
    keywords = []
    messages.each do |m|
      keywords << m.keyword
      m.relative_keywords.each do |rk|
        keywords << rk.keyword
      end
    end
    keywords.uniq
  end

  def get_message_from_keyword keyword, is_open
    if is_open
      mk = keyword.try(:messages).try(:published).try(:open)
      rk = keyword.try(:messages_relative).try(:published).try(:open)
    else
      mk = keyword.try(:messages).try(:published).try(:middle_close)
      rk = keyword.try(:messages_relative).try(:published).try(:middle_close)
    end
    messages = (mk + rk).uniq
    # Exclude messages rendered
    messages = messages.select { |m| get_message_stack_chatting.exclude?(m.id) }

    mw = messages.map(&:weight).max
    mw_messages = messages.select { |w| w.weight == mw }
    # Choose middle if messages have both middle and close
    if mw_messages.detect { |c| c.message_type == "middle" }
      mw_messages = mw_messages.reject { |c| c.message_type == "close" }
    end

    mw_messages[rand(mw_messages.size) - 1]
  end

  def chk_substr strA, strB
    (strA =~ /#{strB}/i).nil? && (strB =~ /#{strA}/i).nil? ? false : true
  end

  def get_keywords_from_ids ids
    ids = ids.reject(&:blank?).map { |id| id.to_i }
    keywords = []
    ids.each { |id| keywords << Keyword.select([:id, :name, :cpc]).activity.find_by_id(id) }
    keywords.reject(&:nil?).pluck(:name).reject(&:nil?)
  end

  # get last ConversationStatus::MESSAGE_STACK_LENGTH
  def get_message_stack_chatting
    max_stack = ConversationStatus::MESSAGE_STACK_LENGTH
    status = @session_statistic.conversation_status.try(:status)
    unless status.blank?
      status.size <= max_stack ? status : status.last(max_stack)
    else
      []
    end
  end

  def messages_display_number_filter messages
    rate = Settings.messages_filter.messages_display_number_filter
    display_number = Array.new(rate, 'display_number')
    digest_number = Array.new((100 - rate), 'digest_number')
    array = display_number + digest_number
    choose_messages_by_number(messages, array[rand(array.size - 1)])
  end

  def choose_messages_by_number msgs, type
    number_array = []
    messages = []
    if type == 'digest_number'
      max = 0
      msgs.each { |msg| number_array << { id: msg.id, digest_number: get_digestion_number(msg.id) } }
      max = number_array.map { |o| o[:digest_number] }.max
      number_array.each { |d| messages << msgs.detect { |m| m.id == d[:id] } if d[:digest_number] == max }
    else
      min = 0
      msgs.each { |msg| number_array << { id: msg.id, display_number: get_display_number(msg.id) } }
      min = number_array.map { |o| o[:display_number] }.min
      number_array.each { |d| messages << msgs.detect { |m| m.id == d[:id] } if d[:display_number] == min }
    end
    messages
  end

  def get_digestion_number message_id
    stories = Story.where('? = ANY(messages_list)', message_id)
    stories.where("array_position(messages_list, ?) != array_length(messages_list, 1)", message_id).count
  end

  def get_display_number message_id
    stories = Story.where('? = ANY(messages_list)', message_id)
    stories.sum(:display_number)
  end

end
