class BadgeService
  def self.check_and_award(user, quiz_session)
    newly_earned = []
    
    Badge.active.each do |badge|
      next if user.badges.include?(badge)  # Skip if already earned
      
      if meets_conditions?(user, badge.conditions, quiz_session)
        user.user_badges.create!(
          badge: badge, 
          earned_at: Time.current,
          quiz_session: quiz_session
        )
        newly_earned << badge
      end
    end
    
    newly_earned
  end
  
  private
  
  def self.meets_conditions?(user, conditions, current_session)
    conditions.all? do |key, value|
      case key
      when 'quiz_count'
        user.quiz_sessions.completed.count >= value
        
      when 'perfect_scores'
        perfect_count = user.quiz_sessions.completed
                           .where('total_score = max_score').count
        perfect_count >= value
        
      when 'subject_id'
        # This would be combined with other conditions
        true  # Handle in combination logic
        
      when 'difficulty'
        # Count quizzes where majority of questions were this difficulty
        difficulty_quiz_count(user, value) >= conditions['quiz_count']
        
      when 'streak_days'
        calculate_streak_days(user) >= value
        
      when 'total_points'
        user.quiz_sessions.completed.sum(:total_score) >= value
        
      when 'score_percentage'
        # This would be used with quiz_count - handle in combination
        true
      end
    end
  end
end