class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAIL_FROM', 'noreply@upcard.com')
  layout "mailer"

  private

  def base_url
    Rails.application.config.action_mailer.default_url_options[:host]
  end
end
