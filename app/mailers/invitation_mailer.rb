class InvitationMailer < ApplicationMailer
  def invitation_email(invitation)
    @invitation = invitation
    @card = invitation.card
    @user = @card.user
    @invitation_url = invitation_url(@invitation.token, host: base_url)
    
    mail(
      to: @invitation.email,
      subject: I18n.t('mailers.invitation.invite.subject', 
        event: @card.title,
        host: @user.full_name
      )
    )
  end

  def reminder_email(invitation)
    @invitation = invitation
    @card = invitation.card
    @user = @card.user
    @invitation_url = invitation_url(@invitation.token, host: base_url)
    
    mail(
      to: @invitation.email,
      subject: I18n.t('mailers.invitation.reminder.subject',
        event: @card.title
      )
    )
  end

  def response_notification_email(invitation)
    @invitation = invitation
    @card = invitation.card
    @guest = invitation.guest_name
    
    mail(
      to: @card.user.email,
      subject: I18n.t('mailers.invitation.response.subject',
        guest: @guest,
        status: @invitation.status
      )
    )
  end
end
