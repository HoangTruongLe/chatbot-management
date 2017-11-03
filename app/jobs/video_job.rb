class VideoJob < ApplicationJob
  def perform(copied_message, msg_cnt)
    vg = VideoGroup.find_by_id(msg_cnt.content_id)
    builded_video_group = copied_message.video_groups.build(vg.dup.attributes)
    builded_video_group.save
    message_videos = Video.where(video_group_id: vg.id)
    if message_videos.size > 0
      message_videos.each do |mp|
        new_video = mp.dup
        new_video.video_group_id = builded_video_group.id
        builded_video = copied_message.videos.build(new_video.attributes)
        builded_video.save
        if mp.video
          builded_video.video = mp.video
          builded_video.video.save
        end
      end
    end
  end
end
