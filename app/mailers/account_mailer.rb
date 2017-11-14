class AccountMailer < Devise::Mailer
  default template_path: 'devise/mailer'

  def reconfirmation_instructions(record, token, opts={})
    @token = token
    opts[:to]       ||= record.email
    opts[:subject]  ||= 'Request to change e-mail address'
    devise_mail(record, :reconfirmation_instructions, opts)
  end

  def new_user_created(record, token, opts={})
    @token = token
    devise_mail(record, :new_user_created, opts)
  end
end
