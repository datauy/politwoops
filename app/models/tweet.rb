# encoding: utf-8
class Tweet < ActiveRecord::Base
  before_save :extract_retweet_fields
  
  belongs_to :politician

  has_many :tweet_images, foreign_key: "tweet_id"

  scope :in_order, order('modified DESC')
  scope :with_content, conditions: "content IS NOT NULL"
  scope :in_year, proc { |year|
    where(['created >= ? and created <= ?',
           Date.new(year, 1, 1), Date.new(year, 12, 31)])
  }

  scope :for_party, proc { |party_id|
    joins(:politician).where(politicians: { party_id: party_id })
  }

  def self.random
    reorder("RAND()").find(:first, limit: 1)
  end
    
  def details
    JSON.parse(tweet)
  end  

  def twitter_url
    "http://www.twitter.com/#{user_name}/status/#{id}"
  end

  ### TODO: refactor, use a serializer
  def format
    {
      created_at: created,
      updated_at: modified,
      id: (id and id.to_s),
      politician_id: politician_id,
      details: details,
      content: content,
      user_name: user_name
    }
  end
  ###

  private

  def extract_retweeted_status
    return nil if tweet.nil?
    orig_obj = JSON::parse(tweet) rescue nil
    
    return nil if orig_obj.nil? or !orig_obj.is_a?(Hash) or orig_obj["retweeted_status"].nil?
    return orig_obj["retweeted_status"]
  end

  def extract_retweet_fields (options = {})
    if retweeted_id.nil? || !options[:overwrite].nil?
      orig_hash = extract_retweeted_status
      if orig_hash
        self.retweeted_id = orig_hash["id"]
        self.retweeted_content = orig_hash["text"]
        self.retweeted_user_name = orig_hash["user"]["screen_name"]
      end
    end
  end
end
