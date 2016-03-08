class StaticPagesController < ApplicationController

	def gameboard

		game = ScoreController.new
		game.parse "db/hands_db.txt"
		@contents = game.evaluate

		
	end
end