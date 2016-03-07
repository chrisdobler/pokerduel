class StaticPagesController < ApplicationController

	def gameboard

		game = ScoreController.new
		@contents = game.evaluate

		
	end
end