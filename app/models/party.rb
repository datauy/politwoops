# encoding: utf-8
class Party < ActiveRecord::Base
  has_many :politicians
  before_save :prepare_name

  validates :name, presence: true

  def tweets
    Tweet.for_party(self.id)
  end

  def deleted_tweets
    DeletedTweet.for_party(self.id)
  end

  def twoops
    DeletedTweet.twoops.for_party(self.id)
  end

  def party_name
    (self.display_name || self.name).titleize.gsub('-', ' ')
  end

  def party_logo_url
    "/assets/party_flags/#{self.name}.png" unless Politwoops::Application.assets.find_asset("party_flags/#{self.name}.png").nil?
  end

  def active_politicians
    politicians.active
  end

  def tweets_count
    Tweet.for_party(self.id).count
  end

  def deleted_tweets_count
    DeletedTweet.for_party(self.id).twoops.count
  end

  def deleted_tweets_percentage
    ((deleted_tweets_count.to_f * 100) / tweets_count.to_f).round(2)
  end

  def organization_percentage
    active_users = active_politicians

    male = male_percentage(active_users)
    female = female_percentage(active_users)
    organization = define_percentage((100 - male - female))

    {
      male: male,
      female: female,
      organization: organization
    }
  end

  def self.by_name(name)
    where(name: name).first
  end

  def self.active_politicians_of(name)
    by_name(name).politicians.active
  end

  private

  def prepare_name
    self.display_name = self.display_name || self.name
    self.name = self.name.parameterize
  end

  def male_percentage(active_users)
    define_percentage((active_users.male.count.to_i * 100) / active_users.count.to_i)
  end

  def female_percentage(active_users)
    define_percentage((active_users.female.count.to_i * 100) / active_users.count.to_i)
  end

  def define_percentage(percentage)
    if percentage <= 0
      1
    elsif percentage >= 99
      98
    else
      percentage
    end
  end
end
