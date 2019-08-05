class AddFieldsToBooking < ActiveRecord::Migration[5.1]
  def change
    add_column :bookings, :inspection_complete, :boolean
    add_column :bookings, :ready_to_load_complete, :boolean
    add_column :bookings, :loaded_complete, :boolean
  end
end
