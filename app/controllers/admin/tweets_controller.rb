class Admin::TweetsController < Admin::AdminController
  before_filter :load_tweet, :only => [:review, :message, :is_hit, :id_tweet]
  include ApplicationHelper

  # list either unreviewed
  def index
    @page = [params[:page].to_i, 1].max
    @politicians = Politician.active.all

    @tweets = DeletedTweet.in_order.where(:politician_id => @politicians)

    # filter to relevant subset of deleted tweets
    @tweets = @tweets.where :reviewed => params[:reviewed], :approved => params[:approved]

    # show unreviewed tweets oldest to newest
    if !params[:reviewed]
      @tweets = @tweets.reorder "modified ASC"
    end

    @per_page_options = [20, 50]
    @per_page = closest_value((params.fetch :per_page, 0).to_i, @per_page_options)

    @tweets = @tweets.includes(:politician => [:party]).paginate(:page => @page, :per_page => @per_page)
    @admin = true

    respond_to do |format|
      format.html # admin/tweets/index.html.erb
      format.rss do
        response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"
        render "tweets/index"
      end
    end

  end


  # approve or unapprove a tweet, mark it as reviewed either way
  def review
    review_message = (params[:review_message] || "").strip

    if ["Aprobar", "Desaprobar"].include?(params[:commit])
      approved = (params[:commit] == "Aprobar")

      #if !@tweet.reviewed? and approved and review_message.blank?
      #  flash[@tweet.id] = "No olvides incluir una nota con el porque apruebas el tweet."
      #  redirect_to params[:return_to]
      #  return false
      #end

      @tweet.approved = approved
      @tweet.reviewed = true
      @tweet.reviewed_at = Time.now
    end

    if not review_message.blank?
      @tweet.review_message = review_message
    end

    @tweet.save!
    expire_action :controller => '/tweets', :action => :index

    redirect_to params[:return_to]
  end

  def is_hit
    @tweet.is_hit = params[:is_hit]
    if @tweet.save
      render json: {result: 'tweet save'}
    else
      render json: {result: @tweet.errors}
    end
  end

  # filters

  def load_tweet
    unless params[:id] and (@tweet = DeletedTweet.find(params[:id]))
      render :nothing => true, :status => :not_found
      return false
    end
  end

end
