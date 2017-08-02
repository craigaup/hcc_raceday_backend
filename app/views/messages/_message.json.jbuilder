json.extract! message, :id, :number, :to, :from, :message_time, :priority, :message, :displayed, :validtil, :user_id, :entered, :created_at, :updated_at
json.url message_url(message, format: :json)
