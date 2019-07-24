json.extract! upload, :id, :booking_id, :original_file_name, :created_at, :updated_at
json.url upload_url(upload, format: :json)
