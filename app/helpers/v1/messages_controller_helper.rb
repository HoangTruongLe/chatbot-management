module V1::MessagesControllerHelper
  def generate_new_cv_transaction(session_statistic_id, product_id)
    cv_transaction = CvTransaction.new(session_statistic_id: session_statistic_id, product_id: product_id)
    cv_transaction.save
    cv_transaction
  end
end
