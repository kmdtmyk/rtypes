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

    create_table :books do |t|
      t.string :title, comment: 'タイトル'
      t.integer :price, comment: '価格'
      t.date :release_date, comment: '発売日'
      t.decimal :file_size, comment: 'ファイルサイズ'

      t.timestamps
    end

    create_table :samples do |t|
      t.string :string
      t.text :text
      t.integer :integer
      t.decimal :decimal
      t.date :date
      t.datetime :datetime
      t.boolean :boolean, null: false, default: false
      t.boolean :boolean_without_not_null

      t.timestamps
    end

  end
end
