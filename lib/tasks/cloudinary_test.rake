namespace :cloudinary do
  desc 'Test Cloudinary configuration and image operations'
  task test: :environment do
    require 'open-uri'

    puts "🚀 Testing Cloudinary configuration..."
    
    # Test des credentials
    begin
      puts "\n1️⃣ Testing credentials..."
      result = Cloudinary::Api.ping
      puts "✅ Credentials are valid!"
    rescue => e
      puts "❌ Credentials test failed: #{e.message}"
      return
    end

    # Test d'upload
    begin
      puts "\n2️⃣ Testing image upload..."
      # Utilisation d'une image de test depuis Cloudinary
      test_image_url = "https://res.cloudinary.com/demo/image/upload/sample.jpg"
      uploaded = CloudinaryService.upload(URI.open(test_image_url))
      
      if uploaded
        puts "✅ Image uploaded successfully!"
        puts "📍 Image URL: #{uploaded}"
      else
        puts "❌ Image upload failed!"
        return
      end

      # Test des transformations
      puts "\n3️⃣ Testing image transformations..."
      
      transformations = {
        "Template Preview" => ImageTransformerService.template_preview(uploaded),
        "Template Background" => ImageTransformerService.template_background(uploaded),
        "Card Cover" => ImageTransformerService.card_cover(uploaded),
        "Card Thumbnail" => ImageTransformerService.card_thumbnail(uploaded)
      }

      transformations.each do |name, url|
        if url
          puts "✅ #{name} transformation successful!"
          puts "📍 Transformed URL: #{url}"
        else
          puts "❌ #{name} transformation failed!"
        end
      end

      # Test de suppression
      puts "\n4️⃣ Testing image deletion..."
      public_id = uploaded.split('/').last.split('.').first
      if CloudinaryService.destroy(public_id)
        puts "✅ Image deleted successfully!"
      else
        puts "❌ Image deletion failed!"
      end

    rescue => e
      puts "❌ Test failed with error: #{e.message}"
      puts e.backtrace
    end

    puts "\n✨ Test completed!"
  end
end
