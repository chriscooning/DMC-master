class CreateUserTokens < ActiveRecord::Migration
  def change
    create_table :user_tokens do |t|
      t.references :account
      t.references :user
      t.string    :token
      t.datetime  :enable_at
      t.datetime  :expire_at
      t.string    :application # saleshub, collection

      t.integer :times_used, default: 0

      t.timestamps
    end
  end
end
