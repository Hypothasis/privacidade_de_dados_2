class CreateAnimals < ActiveRecord::Migration[7.2]
  def change
    create_table :animals do |t|
      t.float :epsilon
      t.string :animal
      t.float :count

      t.timestamps
    end
  end
end
