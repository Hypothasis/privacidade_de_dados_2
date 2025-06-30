class CreateHistrogramaGerals < ActiveRecord::Migration[7.2]
  def change
    create_table :histrograma_gerals do |t|
      t.float :epsilon
      t.float :decada_10
      t.float :decada_20
      t.float :decada_30
      t.float :decada_40
      t.float :decada_50
      t.float :decada_60
      t.float :decada_70
      t.float :decada_80
      t.float :decada_90
      t.float :decada_2000
      t.float :decada_2010
      t.float :decada_2020
      t.float :soma_total

      t.timestamps
    end
  end
end
