module StaticPagesHelper
	def to_suit letter
		case letter
		when "S"
			'♠'
		when "D"
			'♦'
		when "C"
			'♣'
		when "H"
			'♥'
		end
	end

	def to_suit_name letter
		case letter
		when "S"
			'spades'
		when "D"
			'diamonds'
		when "C"
			'clubs'
		when "H"
			'hearts'
		end
	end

	def ten_fixer var
		if var == "T"
			var = 10
		end
		var
	end
end
