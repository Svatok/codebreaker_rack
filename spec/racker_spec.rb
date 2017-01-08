require 'spec_helper'

describe Racker do
  let(:app) { Rack::Builder.parse_file('config.ru').first }

  context 'get to /' do
    before { visit '/' }

    scenario 'returns the status 200' do
      expect(status_code).to be(200)
    end
    scenario 'displays CODEBREAKER on index page' do
      expect(page).to have_content 'CODEBREAKER'
    end
    scenario 'displays input for entering player name' do
      expect(page).to have_field('codebreaker_name')
    end
  end

  context 'unknown request' do
    before { visit '/wrong' }

    scenario 'returns the status 404' do
      expect(status_code).to be(404)
    end
    scenario 'returns page 404' do
      expect(page).to have_content '404 (NOT FOUND)'
    end
  end

  context 'game start' do
    before do
      visit '/'
      fill_in('codebreaker_name', with: 'Test')
      click_button('Break the code!')
    end

    scenario 'returns the status 200' do
      expect(status_code).to be(200)
    end
    scenario 'returns page with player name' do
      expect(page).to have_content 'Hello Test!'
    end
    scenario 'returns page with message about starting game' do
      expect(page).to have_content 'Game started. Enter guess:'
    end
    scenario 'returns page with 10 attempts' do
      expect(page).to have_content 'Attempts left: 10'
    end
    scenario 'returns page with menu links' do
      expect(page).to have_link('Hint')
      expect(page).to have_link('Score')
      expect(page).to have_link('Restart')
      expect(page).to have_link('Exit')
    end
    scenario 'returns page with input for entering guess' do
      expect(page).to have_field('guess')
    end
  end

  before do
    page.set_rack_session(game: WebGame.new('Test'))
    visit '/game'
  end

  context 'game step' do
    before do
      fill_in('guess', with: '1234')
      click_button('Ok')
    end
    scenario 'returns the status 200' do
      expect(status_code).to be(200)
    end
    scenario 'entered guess show in table of steps' do
      expect(page).to have_content '1234'
    end
    scenario '9 attempts left' do
      expect(page).to have_content 'Attempts left: 9'
    end
  end

  context 'show score' do
    before { click_link('Score') }

    scenario 'returns the status 200' do
      expect(status_code).to be(200)
    end
    scenario 'returns page with winner results' do
      expect(page).to have_current_path('/score')
    end
    scenario 'displays table with results' do
      expect(page).to have_css('table.attempts_history')
    end
  end

  context 'press exit game' do
    before { click_link('Exit') }

    scenario 'redirect to /' do
      expect(page).to have_current_path('/')
    end
  end

  context 'press restart game' do
    before { click_link('Restart') }

    scenario 'page with game include message about game restart' do
      expect(page).to have_content 'Game restarted. Enter guess:'
    end
    scenario 'returns page with 10 attempts' do
      expect(page).to have_content 'Attempts left: 10'
    end
  end

  context 'press hint' do
    before { click_link('Hint') }

    scenario 'show hint' do
      expect(page).to have_content 'Hint:'
    end
  end
end
