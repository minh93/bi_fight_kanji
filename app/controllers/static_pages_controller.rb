class StaticPagesController < ApplicationController
  before_action :logged_in_user, only: :home
  
  def home
    @activities = current_user.activities.reverse_order.paginate page: params[:page],
      per_page: 30
    @tmp_top =(User.joins('LEFT OUTER JOIN user_logs ON user_logs.user_id = users.id')).select('users.*, SUM(number_of_word) AS total_word ').group('users.id').order('total_word DESC').limit 10
    @top_ranges=(@tmp_top)
    respond_to :html, :js
  end

  def help
    @users = User.all_admin
  end
end
