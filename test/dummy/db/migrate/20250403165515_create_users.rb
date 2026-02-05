class CreateUsers < ActiveRecord::Migration[6.0]
  def change

    create_table :users do |t|
      t.string :name, comment: '氏名'
      t.boolean :admin, null: false, default: false, comment: '管理者'

      t.timestamps
    end

    create_table :posts do |t|
      t.string :datetime, comment: '日時'
      t.string :title, comment: 'タイトル'
      t.string :body, comment: '本文'
      t.references :user
      t.references :delete_user

      t.timestamps
    end

    create_table :comments do |t|
      t.references :post
      t.datetime :datetime
      t.string :author, comment: '著者'
      t.string :body, comment: '本文'

      t.timestamps
    end

  end
end
