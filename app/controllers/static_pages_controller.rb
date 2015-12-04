class StaticPagesController < ApplicationController
  before_action :logged_in_user, only: :home
  
  def home
    @activities = current_user.activities.reverse_order.paginate page: params[:page],
      per_page: 30
    @activities
    respond_to :html, :js
  end

  def help
    @users = User.all_admin
  end
end
