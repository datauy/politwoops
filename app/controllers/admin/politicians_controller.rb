# encoding: utf-8
class Admin::PoliticiansController < Admin::AdminController 
  include ApplicationHelper

  before_filter :prepare_politician, only: [:create, :update]

  def index
    @per_page_options = [10, 20, 50]
    @per_page = closest_value((params.fetch :per_page, 0).to_i, @per_page_options)
    @page = [params[:page].to_i, 1].max

    @politicians = Politician.all
    respond_to do |format|
      format.html {
        @politicians = Politician.paginate(:page => params[:page], :per_page => @per_page)
        render
      } 
    end
  end

  def show
    @politician = Politician.find(params[:id]) || raise("not found")
    common_form_elements_for('edit', :put)
    @path_to_use = admin_user_path(@politician.id)
    @related = @politician.get_related_politicians().sort_by(&:user_name)
    
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  def new
    @politician = Politician.new
    common_form_elements_for('new', :post)
    @path_to_use = admin_users_path
    @related = []

    respond_to do |format|
      format.html { render 'form' }
    end
  end

  def create
    twitter = FactoryTwitterClient.new_client.user(params[:politician][:user_name])
    @politician = Politician.create(twitter_id: twitter.id, user_name: params[:politician].delete(:user_name))
    update_politician(new_admin_user_path)
  end

  def update
    if @politician
      update_politician(admin_user_path(@politician.id))
    else
      flash[:error] = "No existe el político que buscas"
      redirect_to :index
    end
  end
  
  def update_politician(user_path)
    related = params[:politician].delete(:related)

    if @politician.update_attributes(params[:politician])
      @politician.reset_avatar
      @politician.relate_politicians(related) if related

      redirect_to admin_user_path(@politician.id)
    else
      flash[:errors] = @politician.errors
      redirect_to user_path, status: 500
    end
  end

  private

  def prepare_politician
    if Politician.duplicated_username?(params[:politician][:user_name], params[:id])
      flash[:error] = "Ya existe ese usuario de twitter"
      return redirect_to admin_user_path(params[:id]), status: 400
    else
      @politician = Politician.find(params[:id]) if params[:id]
    end
  end

  def common_form_elements_for(action, method)
    @parties = Party.all
    @use_form_elements = "#{action}_form_elements"
    @method_to_use = method
    @gender = @politician.gender || nil
  end
end
