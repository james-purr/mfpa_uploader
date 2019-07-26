class CreateBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :bookings do |t|
      t.integer :booking_id
      t.integer :missing_image_count
      t.integer :upload_count

      t.timestamps
    end
  end
end
