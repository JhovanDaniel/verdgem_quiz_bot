class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    
    attachments["jade.jpg"] = File.read(Rails.root.join("app/assets/images/jade.jpg"))
    attachments["icons-white-check.png"] = File.read(Rails.root.join("app/assets/images/icons-white-check.png"))
    
    mail(
      to: @user.email,
      subject: "Welcome to Vergem Quiz!"
    )
  end
  
  def institution_welcome_email(user)
    @user = user
    
    attachments["jade.jpg"] = File.read(Rails.root.join("app/assets/images/jade.jpg"))
    attachments["icons-white-check.png"] = File.read(Rails.root.join("app/assets/images/icons-white-check.png"))
    
    mail(
      to: @user.email,
      subject: "Welcome to Vergem Quiz!"
    )
  end
  
  def teacher_welcome_email(user)
    @user = user
    
    attachments["jade.jpg"] = File.read(Rails.root.join("app/assets/images/jade.jpg"))
    attachments["icons-white-check.png"] = File.read(Rails.root.join("app/assets/images/icons-white-check.png"))
    
    mail(
      to: @user.email,
      subject: "Welcome to Vergem Quiz!"
    )
  end
end
