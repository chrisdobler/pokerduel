require 'spec_helper'

describe "Static pages" do

  subject { page }

  describe "Gameboard" do
    before do
      visit root_path
      game = ScoreController.new
      game.parse "db/hands_db.txt"
      contents = game.evaluate
      @hands = contents[2]
      @scores = contents[1]
      @reasons = contents[0]
      @totals = contents[4]
      @pairs_highest = contents[3]
    end

    it { should have_title('PokerProject') }

    it "should pick a winner" do 
      should have_content("WINNER")
    end

    it "should render a list of all the hands" do
      @hands.each do |hand|
      end
      expect(page).to have_selector('.hand_shelf', count: @hands[1].count)
    end

  end

end
