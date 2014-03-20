# encoding: utf-8
require "open-uri"

class Politician < ActiveRecord::Base
  CollectingAndShowing = 1
  CollectingNotShowing = 2
  NotCollectingOrShowing = 3
  NotCollectingButShowing = 4

  before_validation :upcase_gender

  attr_accessible :twitter_id, :user_name, :party_id, :status, :state, :account_type_id,
                  :office_id, :first_name, :middle_name, :last_name, :suffix, :gender

  has_attached_file :avatar, { path: ':base_path/avatars/:filename',
                               url: "/assets/avatars/:filename",
                               default_url: '/assets/avatar_missing_male.png' }

  belongs_to :party
  belongs_to :office
    
  belongs_to :account_type

  has_many :tweets
  has_many :deleted_tweets
 
  has_many :account_links
  has_many :links, through: :account_links 
   
  scope :active, conditions: ["status = 1 OR status = 4"]
  scope :collecting, conditions: { status: [CollectingAndShowing, CollectingNotShowing] }
  scope :showing, conditions: { status: [NotCollectingOrShowing, NotCollectingButShowing] }
  
  validates :user_name, uniqueness: { case_sensitive: false }
  validates :user_name, presence: true
  validates :party_id, presence: true
  validates :gender, inclusion: ['H', 'M'], allow_nil: true

  comma do
    user_name              'user_name'
    twitter_id             'twitter_id'
    party    display_name: 'party_name'
    state                  'state'
    office          title: 'office_title'
    account_type    name:  'account_type'
    first_name             'first_name'
    middle_name            'middle_name'
    last_name              'last_name'
    suffix                 'suffix'
  end

  def self.by_username(username)
    Politician.where(user_name: username)
  end

  def self.duplicated_username?(username, id)
    !by_username(username).where("id != ?", id).empty?
  end

  def full_name
    [suffix, first_name, middle_name, last_name].join(' ').strip.gsub(/\s{2}/,' ')
  end

  def add_related_politicians (other_names)
    other_names.each do |other_name|
      if other_name != self.user_name
        if other_pol = Politician.find_by_user_name(other_name)
          self.links << other_pol
          self.save!
        end
      end
    end
  end

  def remove_related_politicians (other_names)
    other_names.each do |other_name|
      if not other_name.empty? && other_name != self.user_name
        other_pol = Politician.find_by_user_name(other_name)
        AccountLink.where(politician_id: self.id,
                          link_id: other_pol.id).destroy_all
        AccountLink.where(link_id: self.id,
                          politician_id: other_pol.id).destroy_all
      end
    end
  end

  def get_related_politicians
    links = AccountLink.where("politician_id = ? or link_id = ?", self.id, self.id)

    politician_ids = links.flat_map{ |l| [l.politician_id, l.link_id] }
                          .reject{ |pol_id| pol_id == self.id }
    Politician.where(id: politician_ids)
  end

  def relate_politicians(related)
    requested_names = Set.new(related.split(',').map(&:strip))
    existing_names = Set.new(get_related_politicians.map(&:user_name))
    remove_related_politicians (existing_names - requested_names)
    add_related_politicians (requested_names - existing_names)
  end

  def twoops
    deleted_tweets.where(approved: true)
  end

  def reset_avatar (options = {})
    begin
      image_url = twitter_image_url
      force_reset = options.fetch(:force, false)

      save_avatar(image_url) if should_reset_avatar(image_url, force_reset)
      return [true, nil]

    rescue Twitter::Error::Forbidden => e
      return [false, e.to_s]
    rescue Twitter::Error::NotFound
      return [false, "No such user name: #{user_name}"]
    end
  end

  def party_logo_url
    "/assets/party_flags/#{self.party.name}.png" unless Politwoops::Application.assets.find_asset("party_flags/#{self.party.name}.png").nil?
  end

  private

  def twitter_image_url
    twitter_user = FactoryTwitterClient.new_client.user(user_name).profile_image_url(:bigger)
  end

  def should_reset_avatar(image_url, force_reset)
    profile_image_url.nil? || (image_url != profile_image_url) || (profile_image_url != avatar.url) || force_reset
  end

  def save_avatar(image_url)
    uri = URI::parse(image_url)
    extension = File.extname(uri.path)

    uri.open do |remote_file|
      Tempfile.open(["#{self.twitter_id}_", extension]) do |tmpfile|
        tmpfile.puts remote_file.read().force_encoding('UTF-8')
        self.avatar = tmpfile
        self.profile_image_url = image_url
        self.save!
      end
    end
  end

  def upcase_gender
    self[:gender].upcase! if self[:gender]
  end
end
