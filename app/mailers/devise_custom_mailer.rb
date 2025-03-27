class DeviseCustomMailer < Devise::Mailer
  helper :application # Include all helpers
  include Devise::Controllers::UrlHelpers # For URL generation
  default template_path: 'devise/mailer'
  
  def confirmation_instructions(record, token, opts={})
    @first_name = record.first_name
    
    attachments["jade.jpg"] = File.read(Rails.root.join("app/assets/images/jade.jpg"))
    attachments["icons-white-check.png"] = File.read(Rails.root.join("app/assets/images/icons-white-check.png"))
    super
  end
end
