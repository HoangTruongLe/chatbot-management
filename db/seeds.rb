# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if User.all.size  == 0
  User.create(email: 'user@example.com', password: '12345678', name: 'User')
  User.create(email: 'admin@example.com', password: '12345678', name: 'Admin').add_role(:admin)
end

# 100.times do
#   User.create(email: Faker::Internet.email, password: '12345678', name: Faker::DragonBall.character).add_role([:admin, :manager].sample)
# end

if ChatbotEmotion.all.size == 0
  ChatbotEmotion.create(:emotion => "普通")
  ChatbotEmotion.create(:emotion => "微笑み")
  ChatbotEmotion.create(:emotion => "怒り")
  ChatbotEmotion.create(:emotion => "疑問の顔")
end

if MasterCategory.all.size == 0
  MasterCategory.create!(name: Faker::LeagueOfLegends.champion, activity: true )
end

if Keyword.all.size == 0
  100.times do |n|
   Keyword.create!(name: Faker::DragonBall.character, activity: true, master_category_id: MasterCategory.order("RANDOM()").limit(1).first.id)
  end
end

if MasterCategory.all.size == 0
  100.times do |n|
    MasterCategory.create!(name: Faker::LeagueOfLegends.champion, activity: true, parent_id: MasterCategory.order("RANDOM()").limit(1).first.id )
  end
end

if Tag.all.size == 0
  100.times do |n|
    Tag.create!(name: Faker::LordOfTheRings.character, activity: true)
  end
end

Site.update_all(aibot_address: 'http://aichatbot.dev')

Setting.create!(meta_key: 'main_key_weight', meta_value: '1.0') if Setting.where(meta_key: 'main_key_weight').size == 0
Setting.create!(meta_key: 'relative_key_weight', meta_value: '0.6') if Setting.where(meta_key: 'relative_key_weight').size == 0

if Story.all.size == 0
  kw_ids = Keyword.pluck(:id)
  msg_ids_open = Message.published.open.pluck(:id)
  _msg_ids_middle = Message.published.middle.pluck(:id)
  msg_ids_close = Message.published.close.pluck(:id)
  100.times do |s|
    msg_ids_middle = rand(1.._msg_ids_middle.size).times.map { _msg_ids_middle.sample }
    Story.create!(start_keyword_id: kw_ids.sample, end_keyword_id: kw_ids.sample, display_number: rand(5..100), messages_list: [msg_ids_open.sample] + msg_ids_middle + [msg_ids_close.sample])
  end
end
