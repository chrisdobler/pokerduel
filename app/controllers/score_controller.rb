class ScoreController < ApplicationController

	def parse hands_db
		@players = 2
		file = File.open(hands_db, "r")

		@hands = {} # array of all hands hashed per player
		@hands_n = {} # array of numerical values of cards hashed for each player

		@scores = []
		@reasons = [] #array of reasons for the score outcome with each turn. format: includes: flush
		i = 0
		@contents = []

		@highs = {} # array of highest hand for each turn
		@pairs = {} # array of pairs hashes for each hand labeled as :pair, and :triple, :quad
		@pairs_highest = {} #array of the highest number for each pair, triple and quad match seperated by hash

		p=1
		while p <= @players
			@hands[p] = []
			@hands_n[p] = []
			@highs[p] = []
			@pairs[p] = []
			@pairs_highest[p] = []
			p +=1
		end

   	while !file.eof?
			line = file.readline
			cards = line.split(" ")

			@hands[1].push cards[0..4]
			@hands[2].push cards[5..9]

		  @hands_n[1].push get_number_value_for @hands[1][i]
		  @hands_n[2].push get_number_value_for @hands[2][i]

	  #check for highest number card
			@highs[1].push get_highest_from @hands_n[1][i]
			@highs[2].push get_highest_from @hands_n[2][i]

		#check for pairs, double pairs and triples
			@pairs[1].push get_pairs_for(get_duplicate_table_for(@hands_n[1][i]),1,i)
			@pairs[2].push get_pairs_for(get_duplicate_table_for(@hands_n[2][i]),2,i)

			i = i+1
		end
	end

	def evaluate()

	#loop to handle scoring for each set of hands
		i = 0
		while i < @hands[1].count
			compare(i,max=10)
			i = i+1
		end

	#tally scores
		totals = Hash.new(0)
		# iterate over the array, counting duplicate entries
		@scores.each do |v|
		  totals[v] += 1
		end

		[@reasons, @scores, @hands, @pairs_highest, totals]
	end

	def compare(i,max=10)
		#set defaults
			@reasons[i] = "tie"
			@scores[i] = 0

		#update score for highest card
			if max > 0 then
				@reasons[i] = "highest"
				@scores[i] = get_highest_for(i)
			end

		#update score for pairs
			if max > 1 then
				p=1
				while p <= @players
					if @pairs[p][i][:pair] == 1 then
						if @reasons[i] != "pair" then
							@reasons[i] = "pair"
							@scores[i] = p
						else 
							beat = false
							pl = 1
							while pl <= @players
								if @pairs_highest[pl][i][:pair] > @pairs_highest[p][i][:pair] && @pairs[pl][i][:pair] == 1 then beat = true end
								# if @pairs_highest[pl][i][:pair] == @pairs_highest[p][i][:pair] && @pairs[pl][i][:pair] == 1 then self.compare(i,max=1) end
								pl +=1
							end 
							if beat == false then
								@scores[i] = p
							end
						end
					end
					p +=1
				end
			end

		#updates score for two pairs
			if max > 2 then
				p=1
				while p <= @players
					if @pairs[p][i][:pair] == 2 then
						if @reasons[i] != "two_pair" then
							@reasons[i] = "two_pair"
							@scores[i] = p
						else
							beat = false
							pl = 1
							while pl <= @players
								if @pairs_highest[pl][i][:pair] > @pairs_highest[p][i][:pair] && @pairs[pl][i][:pair] == 2 then beat = true end
								# if @pairs_highest[pl][i][:pair] == @pairs_highest[p][i][:pair] && @pairs[pl][i][:pair] == 2 then self.compare(i,max=1) end
								pl +=1
							end 
							if beat == false then
								@scores[i] = p
							end
						end
					end
					p +=1
				end
			end

		#update score for 3ofaKind
			if max > 3 then
				p=1
				while p <= @players
					if @pairs[p][i][:triple] == 1 then
						if @reasons[i] != "3_of_kind" then
							@reasons[i] = "3_of_kind"
							@scores[i] = p
						else 
							beat = false
							pl = 1
							while pl <= @players
								if @pairs_highest[pl][i][:triple] > @pairs_highest[p][i][:triple] then beat = true end
								# if @pairs_highest[pl][i][:triple] == @pairs_highest[p][i][:triple] then self.compare(i,max=3) end
								pl +=1
							end 
							if beat == false then
								@scores[i] = p
							end
						end
					end
					p +=1
				end
			end


		#update score for straight matches: All cards are consecutive values.
			if max > 4 then
				p=1
				while p <= @players
					if is_straight? @hands_n[p][i] 
						if @reasons[i] != "straight" then
							@reasons[i] = "straight"
							@scores[i] = p
						else
							if @hands_n[p][i].max > @hands_n[@scores[i]][i].max then
								@scores[i] = p
							elsif @hands_n[p][i].max == @hands_n[@scores[i]][i].max then
								self.compare(i,max=4) 
							end
						end
					end
					p +=1
				end
			end

		#update score for flushes: All cards of the same suit.
			if max > 5 then
				p=1
				while p <= @players
					if is_flush? @hands[p][i]
						if @reasons[i] != "flush" then
							@reasons[i] = "flush"
							@scores[i] = p
						else 
							if @highs[p][i] > @highs[@scores[i]][i] then
								@scores[i] = p
							elsif @highs[p][i] == @highs[@scores[i]][i] then
								self.compare(i,max=5)
							end
						end
					end
					p +=1
				end
			end

		#updates score for full house
			if max > 6 then
				p=1
				while p <= @players
					if @pairs[p][i][:triple] == 1 && @pairs[p][i][:pair] == 1 then
						if @reasons[i] != "full_house" then
							@reasons[i] = "full_house"
							@scores[i] = p
						else self.evaluate(i,max=6) end
					end
					p +=1
				end
			end

		#updates score for 4 of a kind
			if max > 7 then
				p=1
				while p <= @players
					if @pairs[p][i][:quad] == 1 then
						if @reasons[i] != "4_of_kind" then
							@reasons[i] = "4_of_kind"
							@scores[i] = p
						else self.evaluate(i,max=7) end
					end
					p +=1
				end
			end

		#updates score for straight flush: All cards are consecutive values of same suit.
			if max > 8 then
				p=1
				while p <= @players
					if is_flush? @hands[p][i] and is_straight? @hands_n[p][i]
						if @reasons[i] != "straight_flush" then
							@reasons[i] = "straight_flush"
							@scores[i] = p
						else self.evaluate(i,max=8) end
					end
					p +=1
				end
			end

		#updates score for royal flush: Ten, Jack, Queen, King, Ace, in same suit.
			if max > 9 then
				p=1
				while p <= @players
					if is_flush? @hands[p][i] and is_royal? @hands_n[p][i]
						if @reasons[i] != "royal_flush" then
							@reasons[i] = "royal_flush"
							@scores[i] = p
						else self.evaluate(i,max=9) end
					end
					p +=1
				end
			end


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

	def is_royal?(hand)
		sorted = hand.uniq.sort
	  if sorted.length < 5
	    # cant form a straight with duplicates
	    false
	  else
  		if sorted.first == 10 then
  			if sorted.first + 4 == sorted.last then true end
  		end
		end
	end

	def get_pairs_for duplicate_hand_table, player, turn
			pairs_hand = {:pair => 0, :triple => 0, :quad => 0}
			@pairs_highest[player][turn] = {:pair => 0, :triple => 0, :quad => 0}
			duplicate_hand_table.each do |k,v|
				if v == 2 then 
					pairs_hand[:pair] += 1 
					if k > @pairs_highest[player][turn][:pair] then @pairs_highest[player][turn][:pair] = k end
				end
				if v == 3 then 
					pairs_hand[:triple] += 1 
					if k > @pairs_highest[player][turn][:triple] then @pairs_highest[player][turn][:triple] = k end
				end
				if v >= 4 then 
					pairs_hand[:quad] += 1 
					if k > @pairs_highest[player][turn][:quad] then @pairs_highest[player][turn][:quad] = k end
				end
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
