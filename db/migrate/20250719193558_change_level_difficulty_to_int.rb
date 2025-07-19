class ChangeLevelDifficultyToInt < ActiveRecord::Migration[7.1]
  def change
    remove_column :levels, :difficulty
    
    add_column :levels, :difficulty, :integer
  end
end
