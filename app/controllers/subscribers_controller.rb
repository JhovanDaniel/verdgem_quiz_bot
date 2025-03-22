class SubscribersController < ApplicationController
    skip_before_action :authenticate_user!, only: [:create], if: -> { respond_to?(:authenticate_user!) }
  
  def create
    @subscriber = Subscriber.new(subscriber_params)
    
    respond_to do |format|
      if @subscriber.save
        format.html { redirect_back fallback_location: root_path, notice: "Thanks for subscribing to our newsletter!" }
        format.json { render json: { success: true } }
        format.turbo_stream { flash.now[:notice] = "Thanks for subscribing to our newsletter!" }
      else
        format.html { redirect_back fallback_location: root_path, alert: @subscriber.errors.full_messages.join(", ") }
        format.json { render json: { success: false, errors: @subscriber.errors.full_messages } }
        format.turbo_stream { flash.now[:alert] = @subscriber.errors.full_messages.join(", ") }
      end
    end
  end
  
  private
  
  def subscriber_params
    params.require(:subscriber).permit(:email)
  end
end
