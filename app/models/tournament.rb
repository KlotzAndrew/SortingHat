class Tournament < ActiveRecord::Base

	def sorting_time
		tour = Tournament.first
		solo_users = JSON.parse(tour.solo_input)
		duo_users = JSON.parse(tour.duo_input)

		all_users = []
		all_users << solo_users
		all_users << duo_users
		all_users_flat = all_users.flatten

		user_count = solo_users.flatten.count + duo_users.flatten.count

		#build traunch sizes
		traunch_count = (user_count/40.to_f).ceil
		traunch_sizes = []
		t_size_remainer = user_count
		t_remainder = traunch_count

		traunch_count.times do |x|
			traunch_sizes << (t_size_remainer/t_remainder - t_size_remainer/t_remainder % 5)
			t_size_remainer = t_size_remainer - traunch_sizes.last
			t_remainder = t_remainder - 1
		end

		
		#build traunch players!
		traunch_solo = []
		traunch_duo = []
		traunch_count.times do |x|
			traunch_solo << []
			traunch_duo << []
		end

		Rails.logger.info "traunch_solo: #{traunch_solo}"
		Rails.logger.info "traunch_duo: #{traunch_duo}"
		duop = 0
		duo_users.sort_by(&:sum).each do |x|
			if duop == traunch_count-1
				duop = 0
			else
				duop = duop += 1
			end
			Rails.logger.info "traunch_duo[duop]: #{traunch_duo[duop]}"
			Rails.logger.info "x: #{x}"
			traunch_duo[duop] << x
		end

		solop = 0
		solo_users.sort_by(&:to_i).each do |x|
			if solop == traunch_count-1
				solop = 0
			else
				solop = solop += 1
			end	

			while traunch_solo[solop].count == traunch_sizes[solop]
				solop = solop += 1
				if solop == traunch_count-1
					solop = 0
				end
			end

			traunch_solo[solop] << x

		end

		Rails.logger.info "user_count: #{user_count}"
		Rails.logger.info "traunch_sizes: #{traunch_sizes}"
		Rails.logger.info "traunch_count: #{traunch_count}"
		Rails.logger.info "traunch_solo: #{traunch_solo}"
		Rails.logger.info "traunch_duo: #{traunch_duo}"
		Rails.logger.info "t1 flat: #{traunch_duo.first.flatten.count + traunch_solo.first.flatten.count}"
		Rails.logger.info "t2 flat: #{traunch_duo.last.flatten.count + traunch_solo.last.flatten.count}"

		Rails.logger.info "user_count <= 40: #{user_count <= 40}"
		Rails.logger.info "user_count % 5 == 0: #{user_count % 5 == 0}"
		Rails.logger.info "all_users_flat.select{|item| all_users_flat.count(item) > 1}.uniq: #{all_users_flat.select{|item| all_users_flat.count(item) > 1}.uniq}"
		if user_count <= 400 && user_count % 5 == 0 && all_users_flat.select{|item| all_users_flat.count(item) > 1}.uniq.size == 0
			all_solo = solo_users
			all_duo = duo_users

			total_teams = user_count/5
			Rails.logger.info "total_teams: #{total_teams}"
			cand_teams = []
			cand_std = 2000

			st = Time.now.to_i
			run = 1

			while Time.now.to_i - st < 20 #cand_std > 120

			solo_users = all_solo
			duo_users = all_duo

			teams = []
				total_teams.times do |x|
				teams << []
			end

			duo_users.each do |duo_x, duo_y|
				team_num = rand(0..total_teams-1)
				while teams[team_num].count >= 4
					team_num = rand(0..total_teams-1)
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
			while team_sums.count < total_teams
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
			Rails.logger.info "time: #{et - st} Seconds, for #{run} runs"
		else
			Rails.logger.info "wrong player numbers"
			tour.update(
				:balanced_teams => "[]")
		end
	end

	def test_values

		all_uniq = 0

		while all_uniq == 0
			solo_users = []
			duo_users = []

			summoner_count = 20 + 5*rand(4..5)
			duo_count = rand(0..summoner_count/3.round(0))
			solo_count = summoner_count - duo_count*2

			solo_count.times do |x|
				solo_users << rand(1000..3000)
			end

			duo_count.times do |x|
				q = []
				2.times do |y|
					q << rand(1000..3000)
				end
				duo_users << q
			end

			test_users = []
			test_users << solo_users
			test_users << duo_users
			test_users_flat = test_users.flatten
			Rails.logger.info "all_users_flat: #{test_users_flat}"
			if test_users_flat.select{|item| test_users_flat.count(item) > 1}.uniq.size == 0
				all_uniq = 1
			else
				Rails.logger.info "team duplicates: #{test_users_flat.select{|item| test_users_flat.count(item) > 1}.uniq.size}"
			end
			Rails.logger.info "built a team of: #{summoner_count}, uniq: #{all_uniq}"
		end

		Tournament.first.update(
			:solo_input => solo_users.to_s,
			:duo_input => duo_users.to_s,
			:balanced_teams => nil)
		#duo 2154, 2300, 1874, 2838, 1447, 1544, 2920, 1420, 1887, 2804, 2688, 1054, 1290, 1823, 1619, 2536, 2744, 1416, 1363, 2034, 1839, 1170, 2841, 2378
		#solo 2093, 1780, 1959, 2076, 1437, 1135, 2775, 1781, 2925, 2818, 2300, 2480, 1823, 2541, 2872, 1455

	# Tournament.create(
	# :solo_input => "[]",
	# :duo_input => "[[]]",
	# :balanced_teams => "[]")
	end
end
