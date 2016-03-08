class ScoreController < ApplicationController

	@highs
	@contents

	def evaluate

		players = 2
		file = File.open("db/hands_db_test.txt", "r")
		p1 = [] # array of all hands for player 1
		p2 = []
		hands = {} 

		p1_n = [] # array of numerical values of cards
		p2_n = []
		hands_n = {} # array of numerical values of cards hashed for each player

		scores = []
		reasons = [] #array of reasons for the score outcome with each turn. format: includes: flush
		i = 0
		@contents = []

		@highs = {1=>[],2=>[]} # array of highest hand for each turn

		dups_p1 = [] # array of duplicates for each hand
		dups_p2 = []

		pairs_p1 = [] # array of pairs hashes for each hand labeled as :pair, and :triple, :quad
		pairs_p2 = []
		pairs = {}

		straights_p1 = [] # array of straights
		straights_p2 = []

   	while !file.eof?
			line = file.readline
			cards = line.split(" ")
			p1.push cards[0..4]
			p2.push cards[5..9]

#temp
			hands[1] = p1
			hands[2] = p2

		  p1_n.push get_number_value_for p1[i]
		  p2_n.push get_number_value_for p2[i]

#temp
			hands_n[1] = p1_n
			hands_n[2] = p2_n

	  #check for highest number card
			@highs[1].push get_highest_from p1_n[i]
			@highs[2].push get_highest_from p2_n[i]
			scores[i] = get_highest_for(i)

		#update the duplicate table
			dups_p1.push get_duplicate_table_for p1_n[i]
			dups_p2.push get_duplicate_table_for p2_n[i]

		#check for pairs, double pairs and triples
			pairs_p1.push get_pairs_for dups_p1[i]
			pairs_p2.push get_pairs_for dups_p2[i]

#temp
			pairs[1] = pairs_p1
			pairs[2] = pairs_p2

		#update score for pairs
			if pairs_p1[i][:pair] > pairs_p2[i][:pair] then scores[i]=1 end
			if pairs_p2[i][:pair] > pairs_p1[i][:pair] then scores[i]=2 end

		#update score for triples
			if pairs_p1[i][:triple] > pairs_p2[i][:triple] then scores[i]=1 end
			if pairs_p2[i][:triple] > pairs_p1[i][:triple] then scores[i]=2 end

			i = i+1
		end

#loop to handle scoring for each set of hands
		i = 0
		while i < hands[1].count

		#set defaults
			reasons[i] = "unscored"
			scores[i] = 0

		#update score for straight matches
			p=1
			while p <= players
				if is_straight? hands_n[p][i] 
					if reasons[i] != "straight" then
						reasons[i] = "straight"
						scores[i] = p
					else scores[i] = get_highest_for(i) end
				end
				p +=1
			end

		#update score for flushes: All cards of the same suit.
			p=1
			while p <= players
				if is_flush? hands[p][i]
					if reasons[i] != "flush" then
						reasons[i] = "flush"
						scores[i] = p
					else scores[i] = get_highest_for(i) end
				end
				p +=1
			end

		#updates score for full house
			p=1
			while p <= players
				if pairs[p][i][:triple] == 1 && pairs[p][i][:pair] == 1 then
					if reasons[i] != "full_house" then
						reasons[i] = "full_house"
						scores[i] = p
					else scores[i] = get_highest_for(i) end
				end
				p +=1
			end

		#updates score for 4 of a kind
			p=1
			while p <= players
				if pairs[p][i][:quad] == 1 then
					if reasons[i] != "4_of_kind" then
						reasons[i] = "4_of_kind"
						scores[i] = p
					else scores[i] = get_highest_for(i) end
				end
				p +=1
			end

			i = i+1
		end

		@contents = reasons
	end

	def is_flush?(hand)
	  hand.all? { |x| x.last == hand.first.last }
	end

#checks which player wins for a given turn
	def get_highest_for(turn)
		if @highs[1][turn] > @highs[2][turn] then 1 else 2 end
	end

	def is_straight?(hand)    
	  sorted = hand.uniq.sort
	  if sorted.length < 5
	    # cant form a straight with duplicates
	    false
	  else
	    if sorted.first + 4 == sorted.last then true
	    elsif sorted[4] == 14 then 
	    	sorted.unshift(1).pop
	    	if sorted.first + 4 == sorted.last then true end
	    end
	  end
	end

	def get_pairs_for duplicate_hand_table
			pairs_hand = {:pair => 0, :triple => 0, :quad => 0}
			duplicate_hand_table.each do |k,v|
				if v == 2 then pairs_hand[:pair] += 1 end
				if v == 3 then pairs_hand[:triple] += 1 end
				if v >= 4 then pairs_hand[:quad] += 1 end
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
