class ImageTransformerService
  class << self
    def template_preview(url, width: 300, height: 200)
      transform_image(url,
        width: width,
        height: height,
        crop: :fill,
        quality: :auto,
        fetch_format: :auto
      )
    end

    def template_background(url, width: 1200)
      transform_image(url,
        width: width,
        crop: :scale,
        quality: :auto,
        fetch_format: :auto
      )
    end

    def card_cover(url, width: 800)
      transform_image(url,
        width: width,
        crop: :scale,
        quality: :auto,
        fetch_format: :auto,
        effect: "auto_contrast"
      )
    end

    def card_thumbnail(url, width: 200, height: 150)
      transform_image(url,
        width: width,
        height: height,
        crop: :thumb,
        gravity: :auto,
        quality: :auto,
        fetch_format: :auto
      )
    end

    private

    def transform_image(url, transformations = {})
      return nil unless url.present?

      # Si l'URL est déjà une URL Cloudinary
      if url.include?('cloudinary.com')
        Cloudinary::Utils.cloudinary_url(
          public_id_from_url(url),
          transformations
        )
      else
        Cloudinary::Utils.cloudinary_url(url, transformations)
      end
    end

    def public_id_from_url(url)
      # Extrait le public_id d'une URL Cloudinary
      uri = URI.parse(url)
      path = uri.path
      version_regex = /v\d+/
      path.gsub(/^\/#{ENV['CLOUDINARY_CLOUD_NAME']}\/image\/upload\//, '')
          .gsub(version_regex, '')
          .gsub(/\.[^.]+$/, '') # Retire l'extension
          .gsub(/^\//, '') # Retire le slash initial s'il existe
    end
  end
end
