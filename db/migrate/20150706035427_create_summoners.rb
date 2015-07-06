class CreateSummoners < ActiveRecord::Migration
  def change
    create_table :summoners do |t|
    	t.string :email
    	t.string :name
    	t.string :ign
    	t.integer :elo_op

      t.timestamps
    end
  end
end
