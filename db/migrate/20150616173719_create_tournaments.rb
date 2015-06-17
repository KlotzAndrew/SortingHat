class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
    	t.string :name
    	t.text :solo_input
    	t.text :duo_input
    	t.text :balanced_teams
      t.timestamps
    end
  end
end
