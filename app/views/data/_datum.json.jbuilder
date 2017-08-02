json.extract! datum, :id, :key, :data, :time, :user_id, :created_at, :updated_at
json.url datum_url(datum, format: :json)
