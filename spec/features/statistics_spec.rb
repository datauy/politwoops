# encoding: utf-8
require 'spec_helper'

describe 'politicians' do
  before :each do
    3.times do
      party = FactoryGirl.create :party

      5.times do
        female = FactoryGirl.create :politician, party: party, gender: 'M'
        male = FactoryGirl.create :politician, party: party, gender: 'H'

        3.times do
          FactoryGirl.create :tweet, politician: female
          FactoryGirl.create :tweet, politician: male
        end

        [male, female].each do |politician|
          last_politician_tweet = Tweet.where(politician_id: politician).last
          deleted_tweet = DeletedTweet.create(last_politician_tweet.attributes)
          deleted_tweet.update_attributes(approved: true)
        end
      end
    end
  end

  it 'should see "Estadísticas por partido"' do
    visit '/statistics'

    find('.by-party h2.statistics-by-party').text.should eq 'Estadísticas por partido/gobierno'
    all('.by-party .section').count.should eq 3
    first('.by-party .section .group-count').text.should eq '10 cuentas monitoreadas'
    first('.by-party .section .tweets-statistics .written').text.should eq '30 tweets'
    first('.by-party .section .tweets-statistics .deleted').text.should eq '10 borrados (33.33%)'
  end
end
