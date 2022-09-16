class AddTokenExpirationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :token_expiration, :date
  end
end
