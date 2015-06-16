class TournamentsController < ApplicationController
	def team_builder

		tour = Tournament.find(1)
		@tournament = tour
		@name = tour.name
		@solo_players = JSON.parse(tour.solo_input)
		@duo_players = JSON.parse(tour.duo_input)
		@min_solo = JSON.parse(tour.solo_input).count
		@min_duo = @min = JSON.parse(tour.duo_input).count
		@balanced_teams = JSON.parse(tour.balanced_teams)
		@player_count = (@solo_players.count + (@duo_players.count*2))

		#HELPERS

		#get team averages + std
		if @balanced_teams != [] && !@balanced_teams.nil?
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
		sp1 = players.split(",")
		sp2 = [[]]
		pairs = 0
		sp1.each do |x|
			x1 = x.gsub(" ", "")
			Rails.logger.info "length #{x1.length}"
			Rails.logger.info "regex #{x1 =~ /[0-9]/} "
			if x1.length >= 3 && x1 =~ /[0-9]/
				if sp2[pairs].count == 2
					sp2 << []
					pairs = pairs += 1
				end
				sp2[pairs] << x1.to_i
				Rails.logger.info "added #{x1}"
			end
		end

		Rails.logger.info "SP2: #{sp2}"
		tour.update(
			:duo_input => sp2.to_s)
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

