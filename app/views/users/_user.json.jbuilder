json.extract! user, :id, :username, :name, :encrypted_password, :salt, :created_at, :updated_at
json.url user_url(user, format: :json)
