# Preview all emails at http://localhost:3000/rails/mailers/contact_mailer
class ContactMailerPreview < ActionMailer::Preview
  def order_application
    ContactMailer.with({
      contact: Session.last.resource,
      session: Session.last,
    }).order_application
  end
end
