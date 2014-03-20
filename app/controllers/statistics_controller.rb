# encoding: utf-8
class StatisticsController < ApplicationController

  def index
    @parties = Party.all
  end
end
