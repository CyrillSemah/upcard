class CloudinaryService
  class << self
    def upload(file_path, options = {})
      return nil unless file_path && File.exist?(file_path)

      begin
        response = Cloudinary::Uploader.upload(file_path, {
          resource_type: "auto",
          folder: Rails.env
        }.merge(options))
        
        response["secure_url"]
      rescue => e
        Rails.logger.error "Cloudinary upload failed: #{e.message}"
        nil
      end
    end

    def destroy(public_id)
      return unless public_id

      begin
        Cloudinary::Uploader.destroy(public_id)
        true
      rescue => e
        Rails.logger.error "Cloudinary destroy failed: #{e.message}"
        false
      end
    end
  end
end
