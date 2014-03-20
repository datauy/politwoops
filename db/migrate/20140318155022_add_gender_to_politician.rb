class AddGenderToPolitician < ActiveRecord::Migration
  def change
    add_column :politicians, :gender, :string
  end
end
