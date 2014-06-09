class AddTimezoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tz_name, :string
    add_column :users, :tz_offset, :string
  end
end
