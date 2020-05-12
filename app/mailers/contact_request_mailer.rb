class ContactRequestMailer < ApplicationMailer
  def send_user_email(contact_request)
    @contact_request = contact_request
    mail(to: @contact_request.email,
         subject: 'Thank You For Contacting Us',
         template_path: 'contact_request_mailer',
         template_name: 'user')
  end

  def send_admin_email(contact_request, admin)
    @contact_request = contact_request
    mail(to: admin.email,
         subject: 'New Contact Request Received',
         template_path: 'contact_request_mailer',
         template_name: 'admin')
  end
end
