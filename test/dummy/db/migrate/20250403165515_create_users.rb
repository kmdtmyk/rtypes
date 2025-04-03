class CreateUsers < ActiveRecord::Migration[6.0]
  def change

    create_table :users do |t|
      t.string :name

      t.timestamps
    end

    create_table :posts do |t|
      t.string :datetime
      t.string :title
      t.string :body
      t.references :user

      t.timestamps
    end

  end
end
