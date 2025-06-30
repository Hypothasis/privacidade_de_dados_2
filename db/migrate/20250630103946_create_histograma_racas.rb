class CreateHistogramaRacas < ActiveRecord::Migration[7.2]
  def change
    create_table :histograma_racas do |t|
      t.float :epsilon
      t.string :cidade

      t.float :parda_count
      t.float :amarela_count
      t.float :branca_count
      t.float :preta_count
      t.float :indigena_count

      t.timestamps
    end
  end
end
