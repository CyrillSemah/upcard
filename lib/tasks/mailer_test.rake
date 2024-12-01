namespace :mailer do
  desc 'Test email templates by previewing them in the browser'
  task test: :environment do
    if ENV['TEST_EMAIL'].blank?
      puts "❌ Please provide a TEST_EMAIL environment variable"
      puts "Example: TEST_EMAIL=your@email.com rails mailer:test"
      exit 1
    end

    test_email = ENV['TEST_EMAIL']
    puts "🚀 Testing email templates..."
    
    begin
      # Création d'un utilisateur de test
      user = User.new(
        email: test_email,
        first_name: "Test",
        last_name: "User",
        password: "password123"
      )

      puts "\n1️⃣ Testing welcome email..."
      email = UserMailer.welcome_email(user)
      email.deliver_now
      puts "✅ Welcome email template generated!"

      puts "\n2️⃣ Testing password changed email..."
      email = UserMailer.password_changed(user)
      email.deliver_now
      puts "✅ Password changed email template generated!"

      # Création d'un template de test
      template = Template.new(
        name: "Test Template",
        description: "A test template",
        category: :other,
        active: true
      )

      # S'assurer que le dossier tmp/development existe
      tmp_dir = Rails.root.join('tmp', 'development', 'images')
      FileUtils.mkdir_p(tmp_dir) unless File.directory?(tmp_dir)
      
      test_image_path = tmp_dir.join('test_image.png')
      final_image_path = tmp_dir.join('test_image_final.png')

      begin
        # Création d'une image de test simple avec magick
        system("magick -size 400x600 xc:white -gravity center -pointsize 30 -annotate 0 'Test Template' #{test_image_path}")
        
        # Copier l'image pour avoir deux fichiers distincts
        FileUtils.cp(test_image_path, final_image_path)

        # Upload des images
        template.upload_preview_image(File.open(test_image_path))
        template.upload_background_image(File.open(final_image_path))

        # Vérifier que les URLs sont bien définies
        unless template.preview_image_url.present? && template.background_image_url.present?
          raise "Les URLs des images n'ont pas été correctement définies"
        end

        # Sauvegarder le template
        template.save!
        puts "✅ Template créé avec succès!"

        # Création d'une carte et invitation de test
        card = Card.create!(
          title: "Test Event",
          description: "A test event description",
          event_date: 1.month.from_now,
          event_type: :other,
          location: "Test Location",
          user: user,
          template: template
        )

        invitation = Invitation.new(
          email: test_email,
          card: card,
          guest_name: "Test Guest",
          status: :pending,
          token: SecureRandom.hex(20)
        )

        puts "\n3️⃣ Testing invitation email..."
        email = InvitationMailer.invitation_email(invitation)
        email.deliver_now
        puts "✅ Invitation email template generated!"

        puts "\n4️⃣ Testing reminder email..."
        email = InvitationMailer.reminder_email(invitation)
        email.deliver_now
        puts "✅ Reminder email template generated!"

        invitation.status = :accepted
        puts "\n5️⃣ Testing response notification email..."
        email = InvitationMailer.response_notification_email(invitation)
        email.deliver_now
        puts "✅ Response notification email template generated!"

      rescue => e
        puts "❌ Test failed with error: #{e.message}"
        puts e.backtrace
      ensure
        # Nettoyage
        File.delete(test_image_path) if File.exist?(test_image_path)
        File.delete(final_image_path) if File.exist?(final_image_path)
        template&.destroy if template&.persisted?
        card&.destroy if card&.persisted?
      end

      puts "\n✨ Test completed! Check your browser to preview the emails."
      puts "💡 Note: In development, emails will open in your browser using Letter Opener."
    end
  end
end
