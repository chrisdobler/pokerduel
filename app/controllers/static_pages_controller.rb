class StaticPagesController < ApplicationController

	def gameboard

		game = ScoreController.new
		game.parse "db/hands_db.txt"
		contents = game.evaluate

		@hands = contents[2]
		@scores = contents[1]
		@reasons = contents[0]
		@totals = contents[4]
	end
end