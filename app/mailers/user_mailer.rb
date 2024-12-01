class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    @login_url = new_user_session_url(host: base_url)
    
    mail(
      to: @user.email,
      subject: I18n.t('mailers.user.welcome.subject')
    )
  end

  def password_changed(user)
    @user = user
    
    mail(
      to: @user.email,
      subject: I18n.t('mailers.user.password_changed.subject')
    )
  end
end
