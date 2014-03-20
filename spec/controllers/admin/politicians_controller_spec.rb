require 'spec_helper'

describe Admin::PoliticiansController do
  let(:politician) {FactoryGirl.create :politician}
  let(:party) {FactoryGirl.create :party}

  before :each do
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('admin','admin')
  end

  context 'update' do
    before :each do
      FactoryGirl.create :politician, user_name: 'foobar'
    end

    it 'should not allow to update username if it does not exist' do
      put :update, {id: politician.id, user_name: 'foobar'}
      response.status.should eq 400
    end

    it 'should allow to update username if it exist' do
      VCR.use_cassette('twitter_user_info', allow_playback_repeats: true) do
        put :update, {id: politician.id, user_name: 'diablo_urbano'}
      end
      politician.reload
      politician.user_name.should eq 'diablo_urbano'
    end

    it 'should allow to update any attribute' do
      VCR.use_cassette('twitter_user_info', allow_playback_repeats: true) do
        put :update, {id: politician.id, party_id: party.id,
          first_name: 'foo', last_name: 'bar', user_name: 'diablo_urbano'
        }
      end
      politician.reload

      politician.first_name.should eq 'foo'
      politician.party.name.should eq party.name
    end

    it 'should allow to update related_links' do
      VCR.use_cassette('twitter_user_info', allow_playback_repeats: true) do
        put :update, {id: politician.id, user_name: 'diablo_urbano',
                      related: 'foobar, testbar, testfoo'}
      end
      politician.reload

      politician.links.count.should eq 1
    end
  end

  context 'create' do
    before :each do
      FactoryGirl.create :politician, user_name: 'foobar'
    end

    it 'should not allow to create if it exist' do
      post :create, {id: politician.id, user_name: 'foobar'}
      response.status.should eq 400
    end

    it 'should allow to create if it does not exist' do
      VCR.use_cassette('twitter_user_info', allow_playback_repeats: true) do
        post :create, {user_name: 'diablo_urbano', party_id: party.id}
      end
      Politician.last.user_name.should eq 'diablo_urbano'
    end

    it 'should allow to create any attribute' do
      VCR.use_cassette('twitter_user_info', allow_playback_repeats: true) do
        post :create, {party_id: party.id, user_name: 'diablo_urbano',
                       first_name: 'foo', last_name: 'bar'
        }
      end

      Politician.last.first_name.should eq 'foo'
      Politician.last.party.name.should eq party.name
    end

    it 'should allow to create related_links' do
      VCR.use_cassette('twitter_user_info', allow_playback_repeats: true) do
        post :create, {user_name: 'diablo_urbano', party_id: party.id,
                       related: 'foobar, testbar, testfoo'
        }
      end

      Politician.by_username('diablo_urbano').first.links.count.should eq 1
    end
  end
end
