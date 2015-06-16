class Tournament < ActiveRecord::Base

	def sorting_time
		tour = Tournament.first
		solo_users = JSON.parse(tour.solo_input)
		duo_users = JSON.parse(tour.duo_input)

		Rails.logger.info "solo_users: #{solo_users}"
		Rails.logger.info "solo_users: #{duo_users}"

		if (solo_users.count + (duo_users.count*2)) == 40
			all_solo = solo_users
			all_duo = duo_users

			cand_teams = []
			cand_std = 2000

			st = Time.now.to_i
			run = 1
			while cand_std > 150

			solo_users = all_solo
			duo_users = all_duo

			teams = []
				8.times do |x|
				teams << []
			end

			duo_users.each do |duo_x, duo_y|
				team_num = rand(0..7)
				while teams[team_num].count >= 4
					team_num = rand(0..7)
				end

				teams[team_num] << duo_x
				teams[team_num] << duo_y
			end

			teams.each do |team|
				while team.count < 5
					solo_player = solo_users.sample(1)
					team << solo_player[0]
					solo_users = solo_users - solo_player
				end
			end

			team_sums = []
			while team_sums.count < 8
				team_sums << teams[team_sums.count].inject{|sum,x| sum + x }
			end

			team_mean = team_sums.inject{|sum,x| sum + x }/team_sums.count

			team_sums_sq = []
			team_sums.each do |x|
				team_sums_sq << (team_mean - x)**2
			end

			temp_std = (team_sums_sq.inject{|sum,x| sum + x }/(team_sums.count - 1))**0.5

			if temp_std < cand_std
				cand_teams = teams
				cand_std = temp_std
				Rails.logger.info "std: #{cand_std}, itteration: #{run}"
			end

			# Rails.logger.info run
			run = run += 1
			end
			tour.update(
				:balanced_teams => cand_teams.to_s)
			et = Time.now.to_i
			Rails.logger.info "time: #{et - st} Seconds"
		else
			Rails.logger.info "wrong plaer numbers"
		end
	end

	def test_values

		solo_users = []
		duo_users = []

		16.times do |x|
			solo_users << rand(1000..3000)
		end

		12.times do |x|
			q = []
			2.times do |y|
				q << rand(1000..3000)
			end
			duo_users << q
		end		
		Tournament.first.update(
			:solo_input => solo_users.to_s,
			:duo_input => duo_users.to_s)
		#duo 2154, 2300, 1874, 2838, 1447, 1544, 2920, 1420, 1887, 2804, 2688, 1054, 1290, 1823, 1619, 2536, 2744, 1416, 1363, 2034, 1839, 1170, 2841, 2378
		#solo 2093, 1780, 1959, 2076, 1437, 1135, 2775, 1781, 2925, 2818, 2300, 2480, 1823, 2541, 2872, 1455

		# Tournament.create(
		# :solo_input => "[]",
		# :duo_input => "[[]]",
		# :balanced_teams => "[]")
	end
end
