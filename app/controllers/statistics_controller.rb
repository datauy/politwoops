# encoding: utf-8
class StatisticsController < ApplicationController
  include ApplicationHelper
  before_filter :enable_pager

  def index
    @parties = Party.all
    @politicians = Politician.active.paginate(page: params[:page], per_page: @per_page)
  end
end
