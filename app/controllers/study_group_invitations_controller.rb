class StudyGroupInvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invitation, only: [:show, :accept, :decline]
  
  def index
    @pending_invitations = current_user.pending_study_group_invitations
                                      .includes(:study_group, :inviter)
                                      .recent
    @sent_invitations = current_user.sent_study_group_invitations
                                   .includes(:study_group, :invitee)
                                   .recent
                                   .limit(20)
  end
  
  def show
  end
  
  def accept
    if @invitation.accept!
      redirect_to @invitation.study_group, notice: "Welcome to #{@invitation.study_group.name}! You've successfully joined the study group."
    else
      redirect_to social_path, alert: 'Unable to accept invitation. You cannot be in more than one study group.'
    end
  end
  
  def decline
    @invitation.decline!
    redirect_to social_path, notice: 'Invitation declined.'
  end
  
  private
  
  def set_invitation
    @invitation = current_user.received_study_group_invitations.find(params[:id])
  end
end

