# encoding: utf-8
require 'spec_helper'

describe 'Admin::Politicians' do
  let(:last_politician) { Politician.last }

  before :each do
    5.times { FactoryGirl.create :politician }
    if page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:basic_authorize)
      page.driver.browser.basic_authorize('admin', 'admin')
    elsif page.driver.respond_to?(:basic_authorize)
      page.driver.basic_authorize('admin', 'admin')
    elsif page.driver.respond_to?(:basic_auth)
      page.driver.basic_auth('admin', 'admin')
    end
  end

  context 'index' do
    before(:each) { visit "/admin/users" }

    it 'should display list of politicians' do
      all('.section').count.should eq 5
    end

    it 'should go to user info' do
      first('.section .content a').click

      politician = find('.politician-info form#admin-politician h3.display-label').text
      Politician.all.map(&:full_name).include?(politician).should eq true
    end
  end

  context 'show' do
    before(:each) { visit "/admin/users/#{last_politician.id}" }

    it 'should allow to view user info' do
      politician = find('.politician-info form#admin-politician h3.display-label').text
      last_politician.full_name.should eq politician
    end

    it 'should keep new values for user_name', js: true do
      within('form#admin-politician') do
        find('.username .display-label a.edit-input').click
        fill_in 'politician[user_name]', with: 'foobar'
        find('.username .input-controls a.edit-input').click
        find('.username .display-label').text.should eq 'foobar'
      end
    end
  end
end
