class V1::ClickStatisticController < V1::BaseController
  before_action :session_interaction

  def create
    @click_statistic =
      if click_statistic_params[:type] && click_statistic_params[:type] == 'Product'
        Product.find_by_id(click_statistic_params[:id])
      elsif  click_statistic_params[:type] && click_statistic_params[:type] == 'Category'
        Category.find_by_id(click_statistic_params[:id])
      end

    clicked = ClickStatistic.where(clicked_type: click_statistic_params[:type],
                                    clicked_id: click_statistic_params[:id],
                                    session_statistic_id: @session_statistic.try(:id))
    if @click_statistic && clicked.blank?
      if @click_statistic.click_statistics.build(session_statistic_id: @session_statistic.try(:id)).save

        @session_statistic.conversation_status.increment(:click_closing)

        m_statistic = @session_statistic.conversation_status.message_statistics.where(message_id: click_statistic_params[:message_id]).first

        if m_statistic
          m_statistic.increment(:click_closing)
          m_statistic.save
        else
          @session_statistic.conversation_status.message_statistics.build(message_id: click_statistic_params[:message_id], click_closing: 1)
        end

        @session_statistic.conversation_status.save

        render json: { status: 'ok' }
      else
        render json: { status: 'fail' }
      end
      return
    end
    render json: { status: '' }
  end

  private

  def click_statistic_params
    params.permit(:type, :id, :message_id)
  end
end
