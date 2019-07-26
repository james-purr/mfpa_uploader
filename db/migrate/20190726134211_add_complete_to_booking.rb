class AddCompleteToBooking < ActiveRecord::Migration[5.1]
  def change
    add_column :bookings, :complete, :boolean
  end
end
