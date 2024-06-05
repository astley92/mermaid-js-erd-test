class CreateRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :roles do |t|
      t.string :type
      t.references :assignee, polymorphic: true
    end
  end
end
