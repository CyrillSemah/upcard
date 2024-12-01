Cloudinary.config do |config|
  if ENV['CLOUDINARY_URL'].present?
    # La configuration sera automatiquement chargée depuis CLOUDINARY_URL
  else
    config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
    config.api_key = ENV['CLOUDINARY_API_KEY']
    config.api_secret = ENV['CLOUDINARY_API_SECRET']
  end
  
  # Configuration additionnelle
  config.secure = true # Forcer HTTPS
end
