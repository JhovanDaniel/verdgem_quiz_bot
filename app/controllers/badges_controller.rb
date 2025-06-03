class BadgesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_badge, only: [:show, :edit, :update, :destroy]
  
  def index
    @badges = Badge.all
    
  end
  
  def show
    @users_with_badge = @badge.user_badges.recent.includes(:user).limit(20)
    @badge_stats = {
      total_earned: @badge.earned_count,
      percentage_earned: @badge.earned_percentage,
      recent_earners: @badge.user_badges.where('earned_at > ?', 7.days.ago).count
    }
  end
  
  def new
    @badge = Badge.new
    @badge.conditions = {}
  end
  
  def create
    @badge = Badge.new(badge_params)
    
    if @badge.save
      redirect_to badge_path(@badge), notice: 'Badge was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @badge.update(badge_params)
      redirect_to badge_path(@badge), notice: 'Badge was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @badge.destroy
    redirect_to admin_badges_path, notice: 'Badge was successfully deleted.'
  end
  
  def award_badge
    @badge = Badge.find(params[:id])
    @user = User.find(params[:user_id])
    
    unless @user.has_badge?(@badge)
      @user.user_badges.create!(
        badge: @badge,
        earned_at: Time.current
      )
      redirect_back(fallback_location: admin_badge_path(@badge), 
                   notice: "Badge awarded to #{@user.email}!")
    else
      redirect_back(fallback_location: admin_badge_path(@badge), 
                   alert: "User already has this badge!")
    end
  end
  
  def test_conditions
    @badge = Badge.find(params[:id])
    @test_results = []
    
    # Test against a sample of users
    User.joins(:quiz_sessions).distinct.limit(10).each do |user|
      result = BadgeService.evaluate_conditions(user, @badge.conditions, nil)
      @test_results << {
        user: user,
        would_earn: result,
        current_stats: user_stats_for_badge(user, @badge)
      }
    end
    
    render :test_conditions
  end
  
  private
  
  def set_badge
    @badge = Badge.find(params[:id])
  end
  
  def badge_params
    params.require(:badge).permit(
      :name, :description, :active, :category, :rarity, :badge_image,
      :conditions  # Change this from `conditions: {}` to just `:conditions`
    ).tap do |badge_params|
      # Parse the conditions JSON string into a hash
      if badge_params[:conditions].present?
        begin
          badge_params[:conditions] = JSON.parse(badge_params[:conditions])
        rescue JSON::ParserError => e
          # If JSON is invalid, add an error and set to empty hash
          badge_params[:conditions] = {}
        end
      else
        badge_params[:conditions] = {}
      end
    end
  end
  
  def ensure_admin!
    redirect_to root_path, alert: 'Access denied.' unless current_user.admin?
  end
  
  def user_stats_for_badge(user, badge)
    {
      quiz_count: user.quiz_sessions.completed.count,
      total_points: user.quiz_sessions.completed.sum(:total_score),
      perfect_scores: user.quiz_sessions.completed.where('total_score = max_score').count,
      average_score: user.quiz_sessions.completed.average(:total_score)&.round(2) || 0
    }
  end
end