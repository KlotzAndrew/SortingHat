class TournamentsController < ApplicationController
	
	def team_builder
		tour = Tournament.find(1) #catches sill errors :p
		if tour.balanced_teams.nil?
			tour.update(
				:balanced_teams => "[]")
		end

		@tournament = tour
		@name = tour.name
		@solo_players = JSON.parse(tour.solo_input)
		@duo_players = JSON.parse(tour.duo_input)
		@min_solo = JSON.parse(tour.solo_input).count
		@min_duo = @min = JSON.parse(tour.duo_input).count
		@balanced_teams = JSON.parse(tour.balanced_teams)
		@player_count = @solo_players.flatten.count + @duo_players.flatten.count
		@summoners = Summoner.all

		all_players = []
		all_players << @duo_players
		all_players << @solo_players
		all_players = all_players.flatten
		@duplicates = all_players.select{|item| all_players.count(item) > 1}.uniq


		#show all summoners?

		#build team elo list
		@list_elo = []
		@list_name = []
		@list_email = []
		@list_ign = []
		@csv_teams2 = []
		@balanced_teams.each do |x|
			teambox = []
			list_elo = []
			list_name = []
			list_email = []
			list_ign = []
			y = x.sort_by(&:to_i)
			playerbox = []
			y.each do |z|
				summoner = @summoners.where("elo_op = ?", z).first
				if summoner.nil?
				else
					playerbox << summoner.elo_op
					playerbox << summoner.name
					playerbox << summoner.email
					playerbox << summoner.ign

					list_elo << summoner.elo_op
					list_name << summoner.name
					list_email << summoner.email
					list_ign << summoner.ign
				end
				teambox << playerbox
				playerbox = []
			end
			@csv_teams2 << teambox
			@list_elo << list_elo
			@list_name << list_name
			@list_email << list_email
			@list_ign << list_ign
		end

		#get team averages + std
		if @balanced_teams.count > 0
			team_sums = []
			@balanced_teams.each do |y|
				team_sums << y.inject{|sum,x| sum + x }
			end	
			@team_totals = team_sums

			team_mean = team_sums.inject{|sum,x| sum + x }/team_sums.count
			@team_mean = team_mean
			team_sums_sq = []
			team_sums.each do |x|
			team_sums_sq << (team_mean - x)**2
			end
			std = (team_sums_sq.inject{|sum,x| sum + x }/(team_sums.count - 1))**0.5
			@std = std.round(2)

			#mark duo players
			check = []
			@duo_players.each do |x,y|
				check << x
				check << y
			end
			@check = check
		end

		@tournaments = Tournament.all
		respond_to do |format|
			format.html
			format.csv { send_data Tournament.to_csv(@csv_teams2), filename: "Sorting_Hat-#{Date.today}.csv" }
		end
	end


	def update
		@tournament = Tournament.find(1)
		if params["commit"] == "Update Solo Players"
			Rails.logger.info "PARAMS_SOLO: #{params["tournament"]["solo_input"]}"
			add_solo(@tournament, params["tournament"]["solo_input"])
		elsif params["commit"] == "Update Duo Players"
			Rails.logger.info "PARAMS_SOLO: #{params["tournament"]["duo_input"]}"
			add_duo(@tournament, params["tournament"]["duo_input"])
		elsif params["commit"] == "Balance Teams"
			@tournament.sorting_time
		elsif params["commit"] == "Random Values"
			@tournament.test_values
		end

		redirect_to root_path
	end

	def add_duo(tour, players)
		clean_players = players.gsub("]", "").gsub("[", "").split(",")
		pair_container = [[]]
		pair = 0
		counter = 0
		clean_players.each do |player|
			if counter % 2 == 0 && counter > 0
				pair = pair += 1
				pair_container << []
			end
			clean_player = player.gsub(" ", "")
			Rails.logger.info "length #{clean_player.length}"
			Rails.logger.info "regex #{clean_player =~ /[0-9]/} "
			if clean_player.length >= 3 && clean_player =~ /[0-9]/
				counter = counter += 1
				pair_container[pair] << clean_player.to_i
				Rails.logger.info "added #{clean_player}"
			end
		end

		Rails.logger.info "SP2: #{pair_container}"
		tour.update(
			:duo_input => pair_container.to_s)
	end

	def add_solo(tour, players)
		sp1 = players.split(",")
		sp2 = []
		sp1.each do |x|
			x1 = x.gsub(" ", "")
			Rails.logger.info "length #{x1.length}"
			Rails.logger.info "regex #{x1 =~ /[0-9]/} "
			if x1.length >= 3 && x1 =~ /[0-9]/
				sp2 << x1.to_i
				Rails.logger.info "added #{x1}"
			end
		end

		Rails.logger.info "SP2: #{sp2}"
		tour.update(
			:solo_input => sp2.to_s)
	end
end

