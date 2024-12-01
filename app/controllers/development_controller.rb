class DevelopmentController < ApplicationController
  def serve_image
    return head :forbidden unless Rails.env.development?

    image_path = Rails.root.join('tmp', 'development', 'images', params[:filename])
    
    if File.exist?(image_path)
      send_file image_path, type: 'image/png', disposition: 'inline'
    else
      head :not_found
    end
  end
end
