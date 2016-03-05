class StaticPagesController < ApplicationController

	def gameboard
		file = File.open("db/hands_db.txt", "r")
		p1 = [] # array of all hands for player 1
		p2 = []

		p1_n = [] # array of numerical values of cards
		p2_n = []

		scores = []
		i = 0
		@contents = []

		high_p1 = [] # array of highest hand for each turn
		high_p2 = [] # array of highest hand for each turn

   	while !file.eof?
			line = file.readline
			cards = line.split(" ")
			p1.push cards[0..4]
			p2.push cards[5..9]

		  p1_n.push get_number_value_for p1[i]
		  p2_n.push get_number_value_for p2[i]

	  #check for highest number card
			high_p1.push get_highest_from p1_n[i]
			high_p2.push get_highest_from p2_n[i]
			if high_p1[i] > high_p2[i] then scores[i]=1 else scores[i]=2 end

		   i = i+1
		end
		@contents = scores
	end

	def get_number_value_for hand
		v = [] #array of numerical values for this hand
		hand.each do |card|
				case card[0]
					when "1".."9"
						v.push card[0].to_i
					when "T"
						v.push 10
					when "J"
						v.push 11
					when "Q"
						v.push 12
					when "K"
						v.push 13
					when "A"
						v.push 14
				end
		end
		v
	end

	def get_highest_from hand
		hand.max
	end
end
