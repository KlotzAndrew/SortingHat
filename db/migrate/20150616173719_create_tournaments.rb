class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
    	t.string :name
    	t.string :solo_input
    	t.string :duo_input
    	t.string :balanced_teams
      t.timestamps
    end
  end
end
