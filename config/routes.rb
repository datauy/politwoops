Politwoops::Application.routes.draw do

  root :to => "tweets#index"
  
  match "index(.:format)" => "tweets#index", :as => :index
  match "tweet/:id" => "tweets#show", :as => :tweet
  match "tweet/:tweet_id/thumb/:basename.:format" => "tweets#thumbnail"
  match "user/:id" => "politicians#show", :as => :politician
  match "users/" => "politicians#index", :as => :all_politicians
  match "party/:name" => "parties#show", :as => :party

  namespace :admin do
    match "status" => "system#status"
    match "restart" => "system#restart"
    match "report" => "system#report"

    match "review" => "tweets#index", :reviewed => false, :approved => false, :as => "review"
    match "unapproved" => "tweets#index", :reviewed => true, :approved => false, :as => "unapproved"
    match "approved" => "tweets#index", :reviewed => true, :approved => true, :as => "approved"

    resources :users, except: [:destroy, :edit], controller: :politicians

    match "offices" => "offices#list", :as => "list_offices"   
    match "offices/add" => "offices#add", :as => "add_office"
    match "offices/save" => "offices#save", :as => "save_office"

    match "offices/:id" => "offices#edit", :as => "edit_office"
    match "review/:rss_secret.rss" => "tweets#index", :reviewed => false, :approved => false, :as => "review_rss", :format => "rss"

    match "review/:id" => "tweets#review", :via => [:post], :as => "review_tweet"
    match "is_hit/:id" => "tweets#is_hit", :via => [:put], :as => "update_is_hit"

    match "reports/annual/:year" => "reports#annual", :as => "annual_report"
    match "reports/annual" => "reports#annual", :as => "annual_report"
  end
 
  match "5xx", :to => "errors#down"
  match "404", :to => "errors#not_found"    
  match "*anything", :to => "errors#not_found"    

end
