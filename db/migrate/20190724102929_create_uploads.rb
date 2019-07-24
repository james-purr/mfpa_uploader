class CreateUploads < ActiveRecord::Migration[5.1]
  def change
    create_table :uploads do |t|
      t.integer :booking_id
      t.string :original_file_name

      t.timestamps
    end
  end
end
