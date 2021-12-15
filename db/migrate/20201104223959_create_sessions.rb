class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions do |t|
      t.references :resource,     null: false, index: true, polymorphic: true
      t.string     :token,        null: false, index: { unique: true }
      t.datetime   :expires_at,   null: false
      t.datetime   :last_active_at
      t.inet       :sign_in_ip
      t.inet       :current_ip

      t.timestamps
    end
  end
end
