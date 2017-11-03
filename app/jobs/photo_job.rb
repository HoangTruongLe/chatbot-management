class PhotoJob < ApplicationJob
  def perform(copied_message, msg_cnt)
    pg = PhotoGroup.find_by_id(msg_cnt.content_id)
    builded_photo_group = copied_message.photo_groups.build(pg.dup.attributes)
    builded_photo_group.save
    message_photos = Photo.where(photo_group_id: pg.id)
    if message_photos.size > 0
      message_photos.each do |mp|
        new_photo = mp.dup
        new_photo.photo_group_id = builded_photo_group.id
        built_photo = copied_message.photos.build(new_photo.attributes)
        built_photo.save
        built_photo.photo = mp.photo
        built_photo.photo.save
      end
    end
  end
end
