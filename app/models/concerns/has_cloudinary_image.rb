module HasCloudinaryImage
  extend ActiveSupport::Concern

  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      attr_accessor :preview_image_url, :background_image_url
    end
  end

  module ClassMethods
    def has_cloudinary_image(*attributes)
      attributes.each do |attribute|
        define_method "#{attribute}_url" do
          if Rails.env.development?
            # En développement, on utilise l'URL stockée ou on génère une URL pour l'attachement
            instance_variable_get("@#{attribute}_url") || 
              (send(attribute).attached? ? Rails.application.routes.url_helpers.rails_blob_path(send(attribute), only_path: true) : nil)
          else
            # En production, on utilise l'URL Cloudinary
            send(attribute)&.url
          end
        end

        define_method "#{attribute}_blob" do
          send(attribute)&.blob
        end

        define_method "upload_#{attribute}" do |file, **options|
          return unless file.present?

          if Rails.env.development?
            # En développement, on sauvegarde localement
            save_development_image(file, attribute)
          else
            # En production, on utilise Cloudinary avec retry
            max_retries = 3
            retry_count = 0
            begin
              url = CloudinaryService.upload(file, options)
              return unless url.present?

              filename = if file.respond_to?(:original_filename)
                          file.original_filename
                        elsif file.respond_to?(:path)
                          File.basename(file.path)
                        else
                          "#{attribute}.jpg"
                        end

              send(attribute).attach(
                io: URI.open(url),
                filename: filename
              )
            rescue Cloudinary::Api::RateLimited => e
              retry_count += 1
              if retry_count <= max_retries
                # Attendre de manière exponentielle entre les tentatives
                sleep(2 ** retry_count)
                retry
              else
                Rails.logger.error("Cloudinary rate limit exceeded after #{max_retries} retries: #{e.message}")
                raise
              end
            rescue StandardError => e
              Rails.logger.error("Error uploading to Cloudinary: #{e.message}")
              raise
            end
          end
        end

        define_method "destroy_#{attribute}" do
          if Rails.env.development?
            send(attribute).purge
            instance_variable_set("@#{attribute}_url", nil)
            true
          else
            blob = send("#{attribute}_blob")
            return unless blob&.present?

            public_id = blob.filename.base
            if CloudinaryService.destroy(public_id)
              send(attribute).purge
              true
            else
              false
            end
          end
        end
      end
    end
  end

  private

  def save_development_image(file, type)
    return unless file.present?

    # Création du dossier de développement s'il n'existe pas
    dev_dir = Rails.root.join('tmp', 'development', 'images')
    FileUtils.mkdir_p(dev_dir) unless File.directory?(dev_dir)

    # Génération d'un nom de fichier unique
    filename = "#{SecureRandom.hex(8)}_#{type}.png"
    filepath = dev_dir.join(filename)

    # Copie du fichier
    FileUtils.cp(file.path, filepath)

    # Attacher le fichier localement
    send(type).attach(
      io: File.open(filepath),
      filename: filename
    )

    # Générer l'URL pour l'accès via le navigateur
    url = "/images/development/#{filename}"
    instance_variable_set("@#{type}_url", url)
    
    url
  end
end
