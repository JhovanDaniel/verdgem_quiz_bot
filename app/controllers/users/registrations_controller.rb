class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  
  def create
    super do |resource|
      # Only send email if the user was successfully created
      if resource.persisted?
        UserMailer.welcome_email(resource).deliver_later
      end
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :country,
    :quiz_attempts, :max_quiz_attempts, :nickname])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :country,
    :quiz_attempts, :max_quiz_attempts, :nickname])
  end
end