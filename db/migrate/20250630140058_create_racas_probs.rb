class CreateRacasProbs < ActiveRecord::Migration[7.2]
  def change
    create_table :racas_probs do |t|
      t.float :epsilon
      t.float :parda
      t.float :amarela
      t.float :branca
      t.float :preta
      t.float :indigena
      t.float :sim_parda
      t.float :sim_branca
      t.float :sim_amarela
      t.float :sim_preta
      t.float :sim_indigena

      t.timestamps
    end
  end
end
