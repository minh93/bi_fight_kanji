class UserGoal < ActiveRecord::Base
  include ActivityLog
  after_create :create_goal_log
  belongs_to :user
  has_many :activities, as: :targetable

  def create_goal_log
    create_log self, self.user_id, Settings.activity_type.create_goal
  end
end
