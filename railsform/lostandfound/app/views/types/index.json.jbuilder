json.array!(@types) do |type|
  json.extract! type, :id, :title, :description
  json.url type_url(type, format: :json)
end
