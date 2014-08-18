class ChangeAuthentications < ActiveRecord::Migration
  def change
    drop_table "authentications"

    create_table "authentications", :force => true do |t|
      t.integer  "user_id"
      t.integer  "authentication_provider_id"
      t.string   "uid"
      t.string   "token"
      t.datetime "token_expires_at"
      t.text     "params"
      t.datetime "created_at",                 :null => false
      t.datetime "updated_at",                 :null => false
    end
    add_index "authentications", ["authentication_provider_id"], :name => "index_authentications_on_authentication_provider_id"
    add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"
  end
end

