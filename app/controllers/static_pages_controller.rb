class StaticPagesController < ApplicationController

	def gameboard
		file = File.open("db/hands_db.txt", "r")
		p1 = [] # array of all hands for player 1
		p2 = []
		scores = []
		i = 0
		@contents = []
	   	while !file.eof?
			line = file.readline
			cards = line.split(" ")
			p1.push cards[0..4]
		    p2.push cards[5..9]

		   i = i+1
		end
	end
end
