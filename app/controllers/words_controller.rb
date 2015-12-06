class WordsController < ApplicationController
  def index
    @category = Category.find params[:category_id]
    @filter_state = params[:filter_state] || Settings.category_type.all_word
    @words = @category.words.send(@filter_state, current_user, @category)
    @words = @words.paginate page: params[:page], per_page: 20

    @categories_list = Category.all.collect{|category|
      [category.name, category_words_path(category)]}
    
    respond_to :html, :js
  end
end
