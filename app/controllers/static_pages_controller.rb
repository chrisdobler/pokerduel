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

		dups_p1 = [] # array of duplicates for each hand
		dups_p2 = []

		pairs_p1 = [] # array of pairs hashes for each hand labeled as :pair, and :triple
		pairs_p2 = []

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

		#update the duplicate table
			dups_p1.push get_duplicate_table_for p1_n[i]
			dups_p2.push get_duplicate_table_for p2_n[i]

		#check for pairs, double pairs and triples
			pairs_p1.push get_pairs_for dups_p1[i]
			pairs_p2.push get_pairs_for dups_p2[i]

		   i = i+1
		end
		@contents = scores
	end

	def get_pairs_for duplicate_hand_table
			pairs_hand = {:pair => 0, :triple => 0}
			duplicate_hand_table.each do |k,v|
				if v == 2 then pairs_hand[:pair] += 1 end
				if v == 3 then pairs_hand[:triple] += 1 end
			end 
			pairs_hand
	end

	def get_duplicate_table_for hand
		hand_dup_table = Hash.new(0)
		hand.each{ |e| hand_dup_table[e] += 1 }
		hand_dup_table
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
