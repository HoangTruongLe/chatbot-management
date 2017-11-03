if @message
  # json.keyword @message.keyword
  # json.tags @message.tags
  json.id @message.id
  json.message_contents do
    json.array! @message.message_contents.order(:row_order) do |mc|
      # Exceptions
      next if mc.content_type == "PhotoGroup" and mc.content.photos.blank?
      next if mc.content_type == "VideoGroup" and mc.content.videos.blank?

      # Data
      json.id mc.id
      json.row_order mc.row_order
      json.content_type mc.content_type
      json.message_id mc.message_id
      json.content do
        if mc.content_type == "TextMessage"
          json.id mc.content.id
          json.content mc.content.content
          json.chatbot_emotion mc.content.chatbot_emotion.emotion
          json.message_id mc.content.message_id
        end
        if mc.content_type == "Question"
          json.id mc.content.id
          json.content mc.content.content
          json.chatbot_emotion mc.content.chatbot_emotion.emotion
          json.message_id mc.content.message_id
          json.answers do
            json.array! mc.content.answers do |ans|
              json.id ans.id
              json.keyword ans.keyword
              json.message_id ans.message_id
              json.content ans.content
              json.question_id ans.question_id
              json.message_id ans.message_id
            end
          end
        end
        if mc.content_type == "LinkCard"
          json.id mc.content.id
          json.url mc.content.url
          json.title mc.content.title
          json.description mc.content.description
          json.image_url mc.content.image_url
          json.content_type mc.content.content_type
          json.content_id mc.content.content_id
          json.message_id mc.content.message_id
        end
        if mc.content_type == "ProductMessage"
          product_cv = generate_new_cv_transaction(@session_statistic.id, mc.content.product.id)
          json.id mc.content.id
          json.product do
            json.id mc.content.product.id
            json.name mc.content.product.name
            json.category mc.content.product.category.name
            json.product_url mc.content.product.product_url + "&option=" + product_cv.cv_transaction_key
            json.product_cv product_cv.cv_transaction_key
            json.slug mc.content.product.slug
            json.catch_copy mc.content.product.catch_copy
            json.price number_to_currency(mc.content.product.price, :unit => "¥")
            json.campaign number_to_currency(mc.content.product.campaign.to_i, :unit => "¥")
            json.image_1_url mc.content.product.image_1_url ? mc.content.product.image_1_url.split(",") : []
            json.image_2_url mc.content.product.image_2_url ? mc.content.product.image_2_url.split(",") : []
            json.image_3_url mc.content.product.image_3_url ? mc.content.product.image_3_url.split(",") : []
            json.image_4_url mc.content.product.image_4_url ? mc.content.product.image_4_url.split(",") : []
            json.image_5_url mc.content.product.image_5_url ? mc.content.product.image_5_url.split(",") : []
            json.tags mc.content.product.tags
            json.description mc.content.product.description
            json.site do
              json.id mc.content.product.site.id
              json.name mc.content.product.site.name
              json.site_url mc.content.product.site.site_url
            end
          end
          json.message_id mc.content.message_id
        end
        if mc.content_type == "PhotoGroup"
          json.id mc.content.id
          json.content_type mc.content.content_type
          json.content_id mc.content.content_id
          json.message_id mc.content.message_id
          json.photos do
            json.array! mc.content.photos do |pt|
              json.id pt.id
              json.message_id pt.message_id
              json.photo_file_name pt.photo_file_name
              json.photo_content_type pt.photo_content_type
              json.photo_file_size pt.photo_file_size
              json.photo_updated_at pt.photo_updated_at
              json.photo_url pt.photo.expiring_url
            end
          end
        end
        if mc.content_type == "VideoGroup"
          json.id mc.content.id
          # json.videos do
          #   json.array! mc.content.videos do |v|
          #     json.id v.id
          #     json.message_id v.message_id
          #     json.video_meta v.video_meta
          #     json.video_file_name v.video_file_name
          #     json.video_content_type v.video_content_type
          #     json.video_updated_at v.video_updated_at
          #     json.video_file_size v.video_file_size
          #     json.video_type v.video_type
          #     json.youtube_url v.youtube_url
          #     json.video_url v.video.url
          #   end
          # end
          json.video do
            json.id mc.content.videos.last.id
            json.message_id mc.content.videos.last.message_id
            json.video_meta mc.content.videos.last.video_meta
            json.video_file_name mc.content.videos.last.video_file_name
            json.video_content_type mc.content.videos.last.video_content_type
            json.video_updated_at mc.content.videos.last.video_updated_at
            json.video_file_size mc.content.videos.last.video_file_size
            json.video_type mc.content.videos.last.video_type
            json.youtube_url mc.content.videos.last.youtube_url
            json.video_url mc.content.videos.last.video.expiring_url
          end
          json.content_type mc.content.content_type
          json.content_id mc.content.content_id
          json.message_id mc.content.message_id
        end
        if mc.content_type == "Quote"
          json.id mc.content.id
          json.content mc.content.content
          json.quote_url mc.content.quote_url
          json.quote_source mc.content.quote_source
          json.referral_comment mc.content.referral_comment
          json.message_id mc.content.message_id
        end
      end
    end
  end
end
