require 'spec_helper'

describe 'Politician' do

  let(:politician) { Politician.last }
  let(:party) { FactoryGirl.create :party }

  describe 'validations' do

    it 'should allow unique usernames' do
      FactoryGirl.create(:politician)

      new_politician = Politician.new(user_name: politician.user_name)
      new_politician.valid?.should eq false
    end

    it 'should not allow if username is empty' do
      new_politician = Politician.new(party_id: 'foo_party')
      new_politician.valid?.should eq false
    end

    it 'should not allow if politician has empty party' do
      new_politician = Politician.new(user_name: 'foobar', party: nil)
      new_politician.valid?.should eq false
    end

    context 'Gender' do
      it 'should allow only H for gender' do
        male_politician = Politician.new(user_name: 'foobar', party_id: party.id, gender: 'H')
        male_politician.valid?.should eq true
      end

      it 'should allow only M for gender' do
        female_politician = Politician.new(user_name: 'foobar', party_id: party.id, gender: 'M')
        female_politician.valid?.should eq true
      end

      it 'should allow only h for gender' do
        male_politician = Politician.new(user_name: 'foobar', party_id: party.id, gender: 'h')
        male_politician.valid?.should eq true
      end

      it 'should allow only m for gender' do
        female_politician = Politician.new(user_name: 'foobar', party_id: party.id, gender: 'm')
        female_politician.valid?.should eq true
      end

      it 'should allow only H/M for gender' do
        new_politician = Politician.new(user_name: 'foobar', party_id: party.id, gender: 'Hombre')
        new_politician.valid?.should eq false
      end

      it 'should allow blank for gender' do
        female_politician = Politician.new(user_name: 'foobar', party_id: party.id)
        female_politician.valid?.should eq true
      end
    end
  end

  describe 'full name' do
    it 'should return full name with everything' do
      FactoryGirl.create(:politician)

      full_name = "#{politician.suffix} #{politician.first_name} #{politician.middle_name} #{politician.last_name}"
      Politician.last.full_name.should eq full_name
    end

    it 'should include correctly existing fields' do
      FactoryGirl.create(:politician, middle_name: nil)

      full_name = "#{politician.suffix} #{politician.first_name} #{politician.last_name}"
      Politician.last.full_name.should eq full_name
    end

    it 'should include correctly without sufix' do
      FactoryGirl.create(:politician, suffix: nil, middle_name: nil)

      full_name = "#{politician.first_name} #{politician.last_name}"
      Politician.last.full_name.should eq full_name
    end
  end

  describe 'TwitterClient' do
    
    it 'should reset avatar' do
      FactoryGirl.create(:politician, user_name: 'diablo_urbano', twitter_id: 22808228)

      politician.avatar.url.should eq '/assets/avatar_missing_male.png'

      VCR.use_cassette('twitter_user_info') do
        politician.reset_avatar
        politician.avatar.url.should_not eq '/assets/avatar_missing_male.png'
      end
    end
  end

  describe 'Party Relationship' do

    before(:each) { FactoryGirl.create :politician }

    it 'should belong to a party' do
      politician.party.name.should eq Party.last.name
    end
  end

  describe 'related links' do
    let(:politician1) { FactoryGirl.create :politician }
    let(:politician2) { FactoryGirl.create :politician }
    let(:politician3) { FactoryGirl.create :politician }

    it 'should add existent politicias as related' do
      politician1.add_related_politicians([politician2.user_name, politician3.user_name])
      politician1.reload
      politician1.links.count.should eq 2
    end

    it 'should not add inexistent politicias as related' do
      politician1.add_related_politicians([politician2.user_name, 'foobar'])
      politician1.reload
      politician1.links.count.should eq 1
    end

    it 'should not add empty string' do
      politician1.add_related_politicians([politician2.user_name, 'foobar', ""])
      politician1.reload
      politician1.links.count.should eq 1
    end
  end
end
